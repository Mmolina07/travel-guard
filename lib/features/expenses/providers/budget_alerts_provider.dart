import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/app_auth_provider.dart';
import '../../trips/data/trip_repository.dart';
import '../../trips/presentation/pages/trip_model.dart';
import '../data/expense_repository.dart';
import '../utils/daily_budget_calculator.dart';

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

/// HU-11 — alertas y recordatorios del presupuesto diario.
///
/// - TG-276: recalcula en segundo plano el % del presupuesto diario
///   consumido de los viajes en curso (al iniciar sesión, cada
///   [_refreshEvery], al cambiar de día y cuando una pantalla registra o
///   borra un gasto vía [refresh]).
/// - TG-279: a las 11:00 PM revisa si hay viajes en curso sin ningún
///   gasto registrado hoy y deja un recordatorio en [pendingReminder]
///   (lo muestra `ExpenseReminderListener`). Si la app se abre después
///   de las 11:00 PM, el recordatorio sale de una vez. Se muestra una
///   sola vez por viaje y día.
class BudgetAlertsProvider extends ChangeNotifier {
  BudgetAlertsProvider({
    TripRepository? tripRepository,
    ExpenseRepository? expenseRepository,
  })  : _tripRepository = tripRepository ?? TripRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository();

  static const int reminderHour = 23;
  static const Duration _refreshEvery = Duration(minutes: 15);
  static const String _prefsReminderPrefix = 'hu11_reminder_shown_';

  final TripRepository _tripRepository;
  final ExpenseRepository _expenseRepository;

  int? _turistaId;
  Timer? _refreshTimer;
  Timer? _reminderTimer;
  bool _disposed = false;

  List<TripDailyBudget> _activeTrips = const [];
  List<Trip> _pendingReminder = const [];

  /// Viajes cuyo día de hoy está dentro de sus fechas.
  List<TripDailyBudget> get activeTrips => _activeTrips;

  /// Viajes en curso sin gastos hoy, pendientes de recordar (TG-279).
  List<Trip> get pendingReminder => _pendingReminder;

  /// Lo llama `ChangeNotifierProxyProvider` cada vez que cambia la sesión.
  void updateAuth(AppAuthProvider auth) {
    final usuario = auth.usuario;
    final turistaId =
        auth.isAuthenticated && usuario?.tipoUsuario == 'turista' ? usuario!.id : null;
    if (turistaId == _turistaId) return;
    _turistaId = turistaId;

    _refreshTimer?.cancel();
    _reminderTimer?.cancel();
    _activeTrips = const [];
    _pendingReminder = const [];

    if (turistaId == null) {
      if (!_disposed) notifyListeners();
      return;
    }
    _refreshTimer = Timer.periodic(_refreshEvery, (_) => refresh());
    _scheduleReminder();
    refresh();
  }

  Future<void> refresh() async {
    final turistaId = _turistaId;
    if (turistaId == null) return;
    try {
      final trips = await _tripRepository.fetchTripsByTurista(turistaId);
      final now = DateTime.now();
      final ids = [for (final t in trips) if (t.id != null) t.id!];
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
        active.add(TripDailyBudget(
          trip: trip,
          today: calc.today,
          hasExpensesToday: calc.hasExpensesOn(now),
        ));
      }
      _activeTrips = active;
      // Si ya registró algo después del recordatorio, se retira.
      _pendingReminder = _pendingReminder
          .where((t) => active.any((a) => a.trip.id == t.id && !a.hasExpensesToday))
          .toList();
      notifyListeners();

      if (now.hour >= reminderHour) await _checkReminder();
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

  /// El usuario cerró el recordatorio: no se vuelve a mostrar hoy.
  void dismissReminder() {
    _pendingReminder = const [];
    notifyListeners();
  }

  void _scheduleReminder() {
    _reminderTimer?.cancel();
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, reminderHour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    // Un minuto después de medianoche también sirve como "cambio de
    // día": el % de hoy arranca de cero, así que se recalcula.
    _reminderTimer = Timer(next.difference(now), () async {
      await refresh();
      _scheduleReminder();
    });
  }

  Future<void> _checkReminder() async {
    final today = DateTime.now();
    final key = '$_prefsReminderPrefix${today.year}-${today.month}-${today.day}';
    final candidates = [
      for (final t in _activeTrips)
        if (!t.hasExpensesToday) t.trip,
    ];
    if (candidates.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getStringList(key) ?? const [];
      final fresh = candidates.where((t) => !shown.contains('${t.id}')).toList();
      if (fresh.isEmpty || _disposed) return;
      await prefs.setStringList(key, [...shown, for (final t in fresh) '${t.id}']);
      _pendingReminder = fresh;
      notifyListeners();
    } catch (e, st) {
      debugPrint('BudgetAlertsProvider._checkReminder error: $e\n$st');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }
}
