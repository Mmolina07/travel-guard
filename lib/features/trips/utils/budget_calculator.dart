/// Cálculos derivados del presupuesto de un viaje (mejora "gestor de
/// presupuesto"): cuánto hay disponible por día y por persona, en vez
/// de solo el total — la diferencia real entre un formulario y una
/// herramienta que ayuda a planear el gasto diario.
class BudgetBreakdown {
  final double perDay;
  final double perPerson;
  final double perPersonPerDay;
  final int days;

  const BudgetBreakdown({
    required this.perDay,
    required this.perPerson,
    required this.perPersonPerDay,
    required this.days,
  });
}

/// [maxBudget] es el presupuesto a repartir (normalmente el máximo del
/// viaje, o lo que quede disponible después de lo ya estimado/gastado).
/// [start]/[end] son las fechas del viaje; si son `null` o inválidas, se
/// asume 1 día para no dividir entre cero. [persons] se acota a mínimo 1
/// por la misma razón.
BudgetBreakdown calculateBudgetBreakdown({
  required double maxBudget,
  required DateTime? start,
  required DateTime? end,
  required int persons,
}) {
  var days = 1;
  if (start != null && end != null && !end.isBefore(start)) {
    days = end.difference(start).inDays + 1; // Inclusivo: mismo día = 1.
  }
  final safePersons = persons < 1 ? 1 : persons;

  return BudgetBreakdown(
    perDay: maxBudget / days,
    perPerson: maxBudget / safePersons,
    perPersonPerDay: maxBudget / (days * safePersons),
    days: days,
  );
}

/// Parsea el formato `dd/MM/yyyy` que usan los controllers de fecha de
/// esta feature. Retorna `null` si el texto no tiene ese formato.
DateTime? parseDdMmYyyy(String text) {
  final parts = text.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  try {
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}
