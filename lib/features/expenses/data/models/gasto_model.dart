import 'categoria_gasto_model.dart';

/// Un gasto real registrado manualmente para un viaje (HU-13), tabla
/// `gastos`. Se diferencia de los campos "planeados" de `Trip`
/// (hospedaje, tours, etc. calculados al crear el viaje): esto es lo
/// que el turista realmente fue gastando durante el viaje.
class Gasto {
  final int id;
  final int viajeId;
  final int categoriaId;
  final String categoriaNombre;
  final String? descripcion;
  final double monto;
  final DateTime fecha;

  const Gasto({
    required this.id,
    required this.viajeId,
    required this.categoriaId,
    required this.categoriaNombre,
    this.descripcion,
    required this.monto,
    required this.fecha,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) {
    final categoria = map['categorias_gasto'] as Map<String, dynamic>?;
    return Gasto(
      id: map['id'] as int,
      viajeId: map['viaje_id'] as int,
      categoriaId: map['categoria_id'] as int,
      categoriaNombre: categoria?['nombre'] as String? ?? 'Otros',
      descripcion: map['descripcion'] as String?,
      monto: (map['monto'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }

  CategoriaGasto get categoria =>
      CategoriaGasto(id: categoriaId, nombre: categoriaNombre);
}
