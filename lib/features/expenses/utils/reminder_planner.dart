import '../../trips/presentation/pages/trip_model.dart';
import '../../trips/utils/budget_calculator.dart';
import '../data/models/gasto_model.dart';
import 'daily_budget_calculator.dart';

/// Tipos de recordatorio de HU-11.
enum ReminderKind {
  /// CA5: pasaron X horas sin registrar gastos (y el chequeo de las
  /// 11 PM si el día terminó sin ninguno — TG-279).
  noExpenses,

  /// CA6: resumen de las 11 PM (opcional).
  dailySummary,

  /// CA8: cierre del día a las 11:59 PM (o al abrir la app al día
  /// siguiente si estaba cerrada).
  dayClosing,

  /// CA9: el viaje empieza en 3 días / mañana.
  upcomingTrip,
}

/// Un recordatorio listo para mostrar. [key] identifica el aviso para
/// no repetirlo (se guarda al mostrarlo).
class BudgetReminder {
  const BudgetReminder({
    required this.kind,
    required this.key,
    required this.trip,
    this.day,
    this.tripDayNumber,
    this.daysUntil,
    this.hoursWithoutExpenses,
    this.endOfDay = false,
  });

  final ReminderKind kind;
  final String key;
  final Trip trip;

  /// Presupuesto del día (resumen y cierre).
  final DailyBudgetStatus? day;

  /// "Día X" del viaje (cierre del día).
  final int? tripDayNumber;

  /// Días que faltan para el viaje (viaje próximo).
  final int? daysUntil;

  /// Horas sin registrar (recordatorio de registro durante el día).
  final int? hoursWithoutExpenses;

  /// Recordatorio de registro de las 11 PM (el día terminó sin gastos).
  final bool endOfDay;
}

/// Horario de HU-11.
abstract final class ReminderSchedule {
  /// CA5: solo se pregunta entre las 8 AM y las 10 PM.
  static const dayStartHour = 8;
  static const dayEndHour = 22;

  /// CA6 y chequeo final de gastos del día: 11 PM.
  static const summaryHour = 23;

  /// CA8: 11:59 PM.
  static const closingHour = 23;
  static const closingMinute = 59;

  /// CA9: avisos 3 días y 1 día antes.
  static const tripReminderDays = [3, 1];
}

/// Decide qué recordatorios tocan ahora (HU-11 CA5, CA6, CA8, CA9).
/// Función pura: el proveedor le pasa los viajes con sus gastos, las
/// preferencias y lo que ya se mostró, y muestra lo que devuelva.
///
/// - [shownKeys]: claves de recordatorios ya mostrados.
/// - [lastNudge]: último recordatorio de registro mostrado por viaje
///   (CA5 vuelve a preguntar cada [reminderHours] horas, no una vez).
List<BudgetReminder> planReminders({
  required DateTime now,
  required List<(Trip, List<Gasto>)> trips,
  required int reminderHours,
  required bool dailySummary,
  required bool tripReminder,
  required Set<String> shownKeys,
  required Map<int, DateTime> lastNudge,
}) {
  final today = _date(now);
  final yesterday = today.subtract(const Duration(days: 1));
  final out = <BudgetReminder>[];

  for (final (trip, gastos) in trips) {
    final id = trip.id;
    if (id == null) continue;
    final calc = DailyBudgetCalculator(trip: trip, gastos: gastos);
    final start = parseDdMmYyyy(trip.startDate);

    if (calc.isTripDay(now)) {
      final hasExpensesToday = calc.hasExpensesOn(now);

      // CA5: X horas sin registrar, entre las 8 AM y las 10 PM. Se mide
      // desde lo último que pasó: el último gasto registrado, el último
      // recordatorio o el inicio del horario de hoy.
      if (now.hour >= ReminderSchedule.dayStartHour && now.hour < ReminderSchedule.dayEndHour) {
        var since = DateTime(now.year, now.month, now.day, ReminderSchedule.dayStartHour);
        for (final g in gastos) {
          final created = g.createdAt;
          if (created != null && created.isAfter(since)) since = created;
        }
        final nudged = lastNudge[id];
        if (nudged != null && nudged.isAfter(since)) since = nudged;
        if (now.difference(since) >= Duration(hours: reminderHours)) {
          out.add(BudgetReminder(
            kind: ReminderKind.noExpenses,
            key: 'nudge_${id}_${now.millisecondsSinceEpoch}',
            trip: trip,
            hoursWithoutExpenses: reminderHours,
          ));
        }
      }

      if (now.hour >= ReminderSchedule.summaryHour) {
        // TG-279: el día está por terminar y no hay ningún gasto.
        final nightKey = 'night_${_k(today)}_$id';
        if (!hasExpensesToday && !shownKeys.contains(nightKey)) {
          out.add(BudgetReminder(
            kind: ReminderKind.noExpenses,
            key: nightKey,
            trip: trip,
            endOfDay: true,
          ));
        }

        // CA6: resumen de las 11 PM.
        final summaryKey = 'summary_${_k(today)}_$id';
        if (dailySummary && !shownKeys.contains(summaryKey)) {
          out.add(BudgetReminder(
            kind: ReminderKind.dailySummary,
            key: summaryKey,
            trip: trip,
            day: calc.statusFor(today),
          ));
        }
      }
    }

    // CA8: cierre del día. El de hoy a las 11:59 PM; el de ayer, si la
    // app estaba cerrada a esa hora.
    final closingDays = [
      if (now.hour > ReminderSchedule.closingHour ||
          (now.hour == ReminderSchedule.closingHour && now.minute >= ReminderSchedule.closingMinute))
        today,
      yesterday,
    ];
    for (final day in closingDays) {
      if (!calc.isTripDay(day) || start == null) continue;
      final key = 'closing_${_k(day)}_$id';
      if (shownKeys.contains(key)) continue;
      out.add(BudgetReminder(
        kind: ReminderKind.dayClosing,
        key: key,
        trip: trip,
        day: calc.statusFor(day),
        tripDayNumber: day.difference(start).inDays + 1,
      ));
    }

    // CA9: viaje próximo — un aviso a 3 días (o 2, si no abrió la app
    // ese día) y otro el día antes.
    if (tripReminder && start != null && start.isAfter(today)) {
      final daysUntil = start.difference(today).inDays;
      final bucket = daysUntil == 1 ? 1 : (daysUntil <= 3 ? 3 : null);
      final key = 'trip${bucket}_$id';
      if (bucket != null && !shownKeys.contains(key)) {
        out.add(BudgetReminder(
          kind: ReminderKind.upcomingTrip,
          key: key,
          trip: trip,
          daysUntil: daysUntil,
        ));
      }
    }
  }
  return out;
}

DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);
String _k(DateTime d) => '${d.year}-${d.month}-${d.day}';
