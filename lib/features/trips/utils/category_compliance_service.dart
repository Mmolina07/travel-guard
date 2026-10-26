import '../../expenses/data/models/categoria_gasto_model.dart';
import '../../expenses/data/models/gasto_model.dart';

/// Modelo que representa la fila consolidada del reporte final de cumplimiento por categoría (HU-19)
class CategoryComplianceItem {
  final CategoriaGasto categoria;
  final double limite;
  final double gastoReal;

  const CategoryComplianceItem({
    required this.categoria,
    required this.limite,
    required this.gastoReal,
  });

  /// Diferencia entre el límite y lo gastado (Positivo = Ahorro / Disponible, Negativo = Exceso)
  double get diferencia => limite - gastoReal;

  /// Porcentaje de cumplimiento o ejecución del presupuesto de la categoría
  double get porcentaje => limite > 0 ? (gastoReal / limite) * 100 : (gastoReal > 0 ? 100.0 : 0.0);

  /// Indica si se ha excedido el límite de la categoría
  bool get estaExcedido => gastoReal > limite;
}

class CategoryComplianceService {
  /// Consolida el reporte final cruzando categorías, límites y la lista de gastos del viaje.
  static List<CategoryComplianceItem> generateReport({
    required List<CategoriaGasto> categorias,
    required Map<int, double> limitsMap, // categoriaId -> límite máximo
    required List<Gasto> gastos,
  }) {
    // 1. Agrupar los gastos reales sumados por cada categoría
    final Map<int, double> spentMap = {};
    for (final gasto in gastos) {
      if (gasto.categoriaId != null) {
        spentMap[gasto.categoriaId!] = (spentMap[gasto.categoriaId!] ?? 0.0) + gasto.monto;
      }
    }

    // 2. Construir la lista consolidada combinando los datos
    final List<CategoryComplianceItem> report = [];
    for (final cat in categorias) {
      final double limite = limitsMap[cat.id] ?? 0.0;
      final double gastoReal = spentMap[cat.id] ?? 0.0;

      report.add(
        CategoryComplianceItem(
          categoria: cat,
          limite: limite,
          gastoReal: gastoReal,
        ),
      );
    }

    return report;
  }
}