/// Una categoría de presupuesto personalizable dentro de un viaje
/// (p.ej. "Tours", "Transporte interno", o cualquier nombre que el
/// turista defina) — reemplaza los 5 campos fijos que tenía `Trip`
/// antes (tours/restaurants/discotheque/souvenirs/paidActivities), que
/// no dejaban agregar ni quitar categorías.
///
/// [categoriaGastoId] es un vínculo **opcional** a `categorias_gasto`
/// (la lista fija que usa HU-13 para clasificar gastos reales): sin
/// esto, no habría forma de saber qué gastos reales corresponden a
/// esta categoría planeada, porque los nombres son libres y no
/// coinciden con los de `categorias_gasto` por texto.
class TripBudgetCategory {
  final int? id;
  final String nombre;
  final double monto;
  final int? categoriaGastoId;
  final String? categoriaGastoNombre;

  const TripBudgetCategory({
    this.id,
    required this.nombre,
    required this.monto,
    this.categoriaGastoId,
    this.categoriaGastoNombre,
  });

  TripBudgetCategory copyWith({
    int? id,
    String? nombre,
    double? monto,
    int? categoriaGastoId,
    String? categoriaGastoNombre,
  }) {
    return TripBudgetCategory(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      monto: monto ?? this.monto,
      categoriaGastoId: categoriaGastoId ?? this.categoriaGastoId,
      categoriaGastoNombre: categoriaGastoNombre ?? this.categoriaGastoNombre,
    );
  }
}
