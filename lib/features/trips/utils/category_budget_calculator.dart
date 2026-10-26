import '../../expenses/data/models/gasto_model.dart';
import '../data/limits_repository.dart';

/// Niveles de umbrales de alerta por categoría (HU-19)
enum CategoryBudgetLevel { ok, warning50, warning75, exceeded100 }

class CategoryBudgetStatus {
  final int categoriaId;
  final double limite;
  final double gastado;

  const CategoryBudgetStatus({
    required this.categoriaId,
    required this.limite,
    required this.gastado,
  });

  double get porcentaje => limite > 0 ? (gastado / limite) * 100 : 0;
  double get diferencia => limite - gastado; // Positivo = disponible, Negativo = excedido

  CategoryBudgetLevel get level {
    final pct = porcentaje;
    if (pct >= 100) return CategoryBudgetLevel.exceeded100;
    if (pct >= 75) return CategoryBudgetLevel.warning75;
    if (pct >= 50) return CategoryBudgetLevel.warning50;
    return CategoryBudgetLevel.ok;
  }
}

class CategoryBudgetCalculator {
  CategoryBudgetCalculator({
    required this.limits,
    required this.gastos,
  });

  final Map<int, double> limits; // categoriaId -> límite máximo
  final List<Gasto> gastos;

  /// Calcula el gasto total acumulado agrupado por categoría
  Map<int, double> get spentByCategory {
    final map = <int, double>{};
    for (final g in gastos) {
      if (g.categoriaId != null) {
        map[g.categoriaId!] = (map[g.categoriaId!] ?? 0.0) + g.monto;
      }
    }
    return map;
  }

  /// Obtiene el estado y porcentaje de una categoría específica
  CategoryBudgetStatus statusForCategory(int categoriaId) {
    final limite = limits[categoriaId] ?? 0.0;
    final spent = spentByCategory[categoriaId] ?? 0.0;
    return CategoryBudgetStatus(
      categoriaId: categoriaId,
      limite: limite,
      gastado: spent,
    );
  }
}