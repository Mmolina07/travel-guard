import '../../trips/presentation/pages/trip_model.dart';
import '../../trips/utils/budget_calculator.dart';
import '../data/models/gasto_model.dart';

/// Umbral a partir del cual se advierte que el día va justo (HU-11):
/// por debajo de esto no se muestra ninguna alerta.
const double dailyBudgetWarningPct = 75;

enum DailyBudgetLevel { ok, warning, exceeded }

/// Estado del presupuesto de un día puntual del viaje (HU-11, TG-276).
class DailyBudgetStatus {
  final DateTime date;

  /// Lo que se puede gastar ese día: lo que quedaba libre al empezar el
  /// día, repartido entre los días que faltan (incluido ese).
  final double dailyBudget;
  final double spent;

  const DailyBudgetStatus({
    required this.date,
    required this.dailyBudget,
    required this.spent,
  });

  double get remaining => dailyBudget - spent;

  double get percentage {
    if (dailyBudget <= 0) return spent > 0 ? 100 : 0;
    return spent / dailyBudget * 100;
  }

  DailyBudgetLevel get level {
    if (percentage >= 100) return DailyBudgetLevel.exceeded;
    if (percentage >= dailyBudgetWarningPct) return DailyBudgetLevel.warning;
    return DailyBudgetLevel.ok;
  }

  /// Cómo quedaría el día si se registra un gasto más de [monto] —
  /// para advertir antes de guardar (TG-278).
  DailyBudgetStatus withExtra(double monto) =>
      DailyBudgetStatus(date: date, dailyBudget: dailyBudget, spent: spent + monto);
}

/// Calcula el presupuesto diario de un viaje a partir de sus gastos
/// reales de HU-13 (`gastos`), con la misma base que el resto de la app:
/// disponible = tope − lo planeado al crear el viaje − gastos reales.
///
/// El presupuesto de un día no se fija al crear el viaje: se recalcula
/// con lo que quedaba libre al inicio de ese día, así un día en que se
/// gastó de más reduce el de los días siguientes (y uno barato los sube).
class DailyBudgetCalculator {
  DailyBudgetCalculator({required this.trip, required this.gastos});

  final Trip trip;
  final List<Gasto> gastos;

  DateTime? get _start => parseDdMmYyyy(trip.startDate);
  DateTime? get _end => parseDdMmYyyy(trip.endDate);

  /// Si [date] cae dentro de las fechas del viaje — fuera de ellas no
  /// hay "presupuesto del día" que vigilar.
  bool isTripDay(DateTime date) {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return false;
    final day = _dateOnly(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  DailyBudgetStatus statusFor(DateTime date) {
    final day = _dateOnly(date);
    final start = _start;
    final end = _end;

    var spentBefore = 0.0;
    var spentOnDay = 0.0;
    for (final gasto in gastos) {
      final fecha = _dateOnly(gasto.fecha);
      if (fecha.isBefore(day)) {
        spentBefore += gasto.monto;
      } else if (fecha == day) {
        spentOnDay += gasto.monto;
      }
    }

    var daysLeft = 1;
    if (start != null && end != null && !end.isBefore(start)) {
      final from = day.isBefore(start) ? start : day;
      if (!from.isAfter(end)) daysLeft = end.difference(from).inDays + 1;
    }

    final available = trip.maxBudget - trip.getTotalSpent() - spentBefore;
    return DailyBudgetStatus(
      date: day,
      dailyBudget: available > 0 ? available / daysLeft : 0,
      spent: spentOnDay,
    );
  }

  DailyBudgetStatus get today => statusFor(DateTime.now());

  bool hasExpensesOn(DateTime date) {
    final day = _dateOnly(date);
    return gastos.any((g) => _dateOnly(g.fecha) == day);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
