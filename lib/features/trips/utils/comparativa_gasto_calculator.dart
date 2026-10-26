import '../data/models/gasto_model.dart'; // Ajusta según la ruta de tus modelos
import '../presentation/pages/trip_model.dart';

class ComparativaDiaItem {
  final DateTime fecha;
  final double presupuestoDiario;
  final double gastoReal;
  
  ComparativaDiaItem({
    required this.fecha,
    required this.presupuestoDiario,
    required this.gastoReal,
  });

  double get diferencia => presupuestoDiario - gastoReal; // Positivo = Ahorro, Negativo = Exceso
  double get porcentaje => presupuestoDiario > 0 ? (gastoReal / presupuestoDiario) * 100 : 0;
}

class ComparativaCategoriaItem {
  final String categoria;
  final double presupuestado;
  final double gastoReal;

  ComparativaCategoriaItem({
    required this.categoria,
    required this.presupuestado,
    required this.gastoReal,
  });

  double get diferencia => presupuestado - gastoReal;
  bool get esAhorro => diferencia >= 0;
}