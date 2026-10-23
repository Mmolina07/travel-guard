import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/app_auth_provider.dart';
import '../../trips/data/checklist_repository.dart';
import '../../trips/data/trip_repository.dart';
import '../../trips/presentation/pages/trip_model.dart';
import '../../trips/utils/budget_calculator.dart';
import '../data/expense_repository.dart';
import '../data/models/gasto_model.dart';
import '../utils/daily_budget_calculator.dart';
import '../utils/reminder_planner.dart';
import 'notification_prefs_provider.dart';

/// Viaje en curso con su estado de presupuesto de hoy (HU-11).
class TripDailyBudget {
  final Trip trip;
  final DailyBudgetStatus today;
  final bool hasExpensesToday;

  const TripDailyBudget({
    required this.trip,
    required this.today,
    required this.hasExpensesToday,
  });
}

/// Umbral del presupuesto de hoy que un viaje acaba de cruzar (HU-11
/// CA1/CA2/CA7) — lo convierte en notificación `BudgetNotificationsListener`.
class BudgetThresholdAlert {
  final Trip trip;
  final DailyBudgetLevel level;
  final DailyBudgetStatus today;

  const BudgetThresholdAlert({required this.trip, required this.level, required this.today});
}

/// HU-11 — alertas y recordatorios del presupuesto diario.
///
/// - TG-276: recalcula en segundo plano el % del presupuesto diario
///   consumido de los viajes en curso (al iniciar sesión, cada
///   [_refreshEvery], al cambiar de día y cuando una pantalla registra o
///   borra un gasto vía [refresh]).
/// - CA5/CA6/CA8/CA9 (y TG-279) y los pendientes de HU-26: deja en
///   [pendingReminders] lo que [planReminders] decida que toca ahora;
///   `BudgetNotificationsListener` lo muestra y llama [consumeReminders]
///   para no repetirlo. Además del refresco periódico, hay timers a las
///   7:00 AM (HU-26), 11:00 PM, 11:59 PM y 12:01 AM.
class BudgetAlertsProvider extends ChangeNotifier {
  BudgetAlertsProvider({
    TripRepository? tripRepository,
    ExpenseRepository? expenseRepository,
    ChecklistRepository? checklistRepository,
  }) : _tripRepository = tripRepository ?? TripRepository(),
       _expenseRepository = expenseRepository ?? ExpenseRepository(),
       _checklistRepository = checklistRepository ?? ChecklistRepository();

  static const Duration _refreshEvery = Duration(minutes: 15);
  static const String _prefsLevelPrefix = 'hu11_level_notified_';
  static const String _prefsShownReminders = 'hu11_reminders_shown';
  static const String _prefsLastNudgePrefix = 'hu11_last_nudge_';
  static const int _maxShownKeys = 300;

  final TripRepository _tripRepository;
  final ExpenseRepository _expenseRepository;
  final ChecklistRepository _checklistRepository;

  int? _turistaId;
  Timer? _refreshTimer;
  Timer? _reminderTimer;
  bool _disposed = false;

  List<TripDailyBudget> _activeTrips = const [];
  List<BudgetThresholdAlert> _pendingAlerts = const [];
  List<BudgetReminder> _pendingReminders = const [];

  // Preferencias de HU-11 (las pasa `updatePrefs`).
  int _reminderHours = 4;
  bool _dailySummary = false;
  bool _tripReminder = true;
  bool _checklistReminder = true;

  /// Recordatorios que tocan ahora (CA5, CA6, CA8, CA9), pendientes de
  /// mostrar.
  List<BudgetReminder> get pendingReminders => _pendingReminders;

  /// Lo llama `ChangeNotifierProxyProvider2` cuando cambian las
  /// preferencias de recordatorios: se recalcula de una vez.
  void updatePrefs(NotificationPrefsProvider prefs) {
    final changed = prefs.reminderHours != _reminderHours ||
        prefs.dailySummary != _dailySummary ||
        prefs.tripReminder != _tripReminder ||
        prefs.checklistReminder != _checklistReminder;
    _reminderHours = prefs.reminderHours;
    _dailySummary = prefs.dailySummary;
    _tripReminder = prefs.tripReminder;
    _checklistReminder = prefs.checklistReminder;
    if (changed && _turistaId != null) Future.microtask(refresh);
  }

  /// El listener ya mostró (o descartó) [reminders]: no se repiten.
  Future<void> consumeReminders(List<BudgetReminder> reminders) async {
    if (reminders.isEmpty) return;
    final keys = {for (final r in reminders) r.key};
    _pendingReminders = _pendingReminders.where((r) => !keys.contains(r.key)).toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getStringList(_prefsShownReminders) ?? const [];
      final next = [...shown, ...keys.where((k) => !k.startsWith('nudge_'))];
      await prefs.setStringList(
        _prefsShownReminders,
        next.length > _maxShownKeys ? next.sublist(next.length - _maxShownKeys) : next,
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final r in reminders) {
        if (r.kind == ReminderKind.noExpenses && !r.endOfDay) {
          await prefs.setInt('$_prefsLastNudgePrefix${r.trip.id}', now);
        }
      }
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider.consumeReminders error: $e\n$st');
    }
  }

  /// Umbrales recién cruzados hoy, pendientes de mostrar. Cada umbral
  /// sale una sola vez por viaje y día; si se saltan varios de golpe
  /// (p. ej. de 50% a 110%), solo el más alto.
  List<BudgetThresholdAlert> get pendingAlerts => _pendingAlerts;

  /// Niveles ya avisados en esta sesión (viaje → nivel), además de los
  /// guardados en disco: evita que el chequeo en segundo plano repita un
  /// aviso que acaba de salir al registrar el gasto.
  final Map<String, int> _notifiedNow = {};

  /// Al registrar un gasto ya se avisó [level] para [tripId] en [day].
  Future<void> markNotified(int? tripId, DateTime day, DailyBudgetLevel level) async {
    final key = _levelKey(day, tripId);
    if ((_notifiedNow[key] ?? 0) >= level.index) return;
    _notifiedNow[key] = level.index;
    _pendingAlerts = _pendingAlerts.where((a) => a.trip.id != tripId || !_isSameDay(day, DateTime.now())).toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getInt(key) ?? 0) < level.index) await prefs.setInt(key, level.index);
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider.markNotified error: $e\n$st');
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// El listener ya mostró (o descartó) las alertas pendientes: no se
  /// repiten hasta que el viaje cruce un umbral más alto hoy.
  Future<void> consumeAlerts() async {
    final alerts = _pendingAlerts;
    if (alerts.isEmpty) return;
    _pendingAlerts = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      for (final a in alerts) {
        await prefs.setInt(_levelKey(now, a.trip.id), a.level.index);
      }
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider.consumeAlerts error: $e\n$st');
    }
  }

  /// Viajes cuyo día de hoy está dentro de sus fechas.
  List<TripDailyBudget> get activeTrips => _activeTrips;

  /// Lo llama `ChangeNotifierProxyProvider` cada vez que cambia la sesión.
  void updateAuth(AppAuthProvider auth) {
    final usuario = auth.usuario;
    final turistaId = auth.isAuthenticated && usuario?.tipoUsuario == 'turista'
        ? usuario!.id
        : null;
    if (turistaId == _turistaId) return;
    _turistaId = turistaId;

    _refreshTimer?.cancel();
    _reminderTimer?.cancel();
    _activeTrips = const [];
    _pendingAlerts = const [];
    _pendingReminders = const [];

    // Esto corre dentro del `update` del ProxyProvider (en pleno build):
    // notificar ahí mismo revienta, así que se difiere un microtask.
    if (turistaId == null) {
      Future.microtask(() {
        if (!_disposed) notifyListeners();
      });
      return;
    }
    _refreshTimer = Timer.periodic(_refreshEvery, (_) => refresh());
    _scheduleReminder();
    Future.microtask(refresh);
  }

  Future<void> refresh() async {
    final turistaId = _turistaId;
    if (turistaId == null) return;
    try {
      final trips = await _tripRepository.fetchTripsByTurista(turistaId);
      final now = DateTime.now();
      final ids = [
        for (final t in trips)
          if (t.id != null) t.id!,
      ];
      final gastosPorViaje = await _expenseRepository.fetchGastosDeViajes(ids);
      if (_disposed || turistaId != _turistaId) return;

      final active = <TripDailyBudget>[];
      for (final trip in trips) {
        if (trip.id == null) continue;
        final calc = DailyBudgetCalculator(
          trip: trip,
          gastos: gastosPorViaje[trip.id] ?? const [],
        );
        if (!calc.isTripDay(now)) continue;
        active.add(
          TripDailyBudget(
            trip: trip,
            today: calc.today,
            hasExpensesToday: calc.hasExpensesOn(now),
          ),
        );
      }
      _activeTrips = active;
      await _checkThresholds(active, now);
      await _planReminders(trips, gastosPorViaje, now);
      if (_disposed || turistaId != _turistaId) return;
      notifyListeners();
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider.refresh error: $e\n$st');
    }
  }

  TripDailyBudget? statusForTrip(int? tripId) {
    if (tripId == null) return null;
    for (final t in _activeTrips) {
      if (t.trip.id == tripId) return t;
    }
    return null;
  }

  /// Vuelve a calcular en los momentos fijos: 7:00 AM (pendientes del día
  /// de salida, HU-26), 11:00 PM (CA6 y chequeo final de gastos),
  /// 11:59 PM (CA8) y 12:01 AM (cambio de día).
  void _scheduleReminder() {
    _reminderTimer?.cancel();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidates = [
      today.add(const Duration(hours: ReminderSchedule.checklistMorningHour)),
      today.add(const Duration(hours: ReminderSchedule.summaryHour)),
      today.add(const Duration(
        hours: ReminderSchedule.closingHour,
        minutes: ReminderSchedule.closingMinute,
      )),
      today.add(const Duration(days: 1, minutes: 1)),
    ];
    final next = candidates.firstWhere((t) => t.isAfter(now));
    _reminderTimer = Timer(next.difference(now), () async {
      await refresh();
      _scheduleReminder();
    });
  }

  Future<void> _planReminders(
    List<Trip> trips,
    Map<int, List<Gasto>> gastosPorViaje,
    DateTime now,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingKeys = {for (final r in _pendingReminders) r.key};
      final checklistPending = await _fetchChecklistPending(trips, now);
      final planned = planReminders(
        now: now,
        trips: [
          for (final t in trips)
            if (t.id != null) (t, gastosPorViaje[t.id] ?? const <Gasto>[]),
        ],
        reminderHours: _reminderHours,
        dailySummary: _dailySummary,
        tripReminder: _tripReminder,
        checklistReminder: _checklistReminder,
        checklistPending: checklistPending,
        shownKeys: {...?prefs.getStringList(_prefsShownReminders)},
        lastNudge: {
          for (final t in trips)
            if (t.id != null && prefs.getInt('$_prefsLastNudgePrefix${t.id}') != null)
              t.id!: DateTime.fromMillisecondsSinceEpoch(prefs.getInt('$_prefsLastNudgePrefix${t.id}')!),
        },
      );
      // Un recordatorio de registro por viaje a la vez.
      _pendingReminders = [
        ..._pendingReminders,
        for (final r in planned)
          if (!pendingKeys.contains(r.key) &&
              !(r.kind == ReminderKind.noExpenses &&
                  !r.endOfDay &&
                  _pendingReminders.any((p) => p.kind == r.kind && p.trip.id == r.trip.id && !p.endOfDay)))
            r,
      ];
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider._planReminders error: $e\n$st');
    }
  }

  /// HU-26: pendientes sin marcar de los viajes que empiezan en los
  /// próximos 3 días (los únicos que pueden tener recordatorio). Si falla,
  /// esos recordatorios simplemente no salen.
  Future<Map<int, int>> _fetchChecklistPending(List<Trip> trips, DateTime now) async {
    final turistaId = _turistaId;
    if (!_checklistReminder || turistaId == null) return const {};
    final today = DateTime(now.year, now.month, now.day);
    final ids = [
      for (final t in trips)
        if (t.id != null)
          if (parseDdMmYyyy(t.startDate) case final start?)
            if (!start.isBefore(today) && start.difference(today).inDays <= 3) t.id!,
    ];
    try {
      return await _checklistRepository.fetchPendingCounts(userId: turistaId, tripIds: ids);
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider._fetchChecklistPending error: $e\n$st');
      return const {};
    }
  }

  /// Compara el nivel de hoy de cada viaje con el último ya notificado
  /// (guardado por día en `SharedPreferences`) y deja pendientes los que
  /// subieron. Se marcan como notificados recién en [consumeAlerts].
  Future<void> _checkThresholds(List<TripDailyBudget> active, DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int notified(int? tripId) {
        final key = _levelKey(now, tripId);
        final stored = prefs.getInt(key) ?? 0;
        final memory = _notifiedNow[key] ?? 0;
        return stored > memory ? stored : memory;
      }

      _pendingAlerts = [
        for (final t in active)
          if (t.today.level.index > notified(t.trip.id))
            BudgetThresholdAlert(trip: t.trip, level: t.today.level, today: t.today),
      ];
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider._checkThresholds error: $e\n$st');
    }
  }

  String _levelKey(DateTime day, int? tripId) =>
      '$_prefsLevelPrefix${day.year}-${day.month}-${day.day}_$tripId';

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }
}
