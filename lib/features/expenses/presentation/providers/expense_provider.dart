import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseProvider with ChangeNotifier {
  final List<ExpenseEntity> _expenses = [];
  double _dailyBudget = 50000.0; // Presupuesto diario base en pesos colombianos

  List<ExpenseEntity> get expenses => _expenses;
  double get dailyBudget => _dailyBudget;

  // Modifica el presupuesto diario según el viaje o configuración
  void setDailyBudget(double budget) {
    _dailyBudget = budget;
    notifyListeners();
  }

  // Total gastado en la fecha actual
  double get totalSpentToday {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Saldo disponible restante para el día de hoy
  double get remainingBudgetToday => _dailyBudget - totalSpentToday;

  // Porcentaje gastado del presupuesto diario
  double get spentPercentage =>
      _dailyBudget > 0 ? (totalSpentToday / _dailyBudget) * 100 : 0.0;

  // Evalúa si un nuevo gasto que se intenta ingresar superará el presupuesto disponible
  bool exceedsBudget(double newAmount) {
    return (totalSpentToday + newAmount) > _dailyBudget;
  }

  // Verifica si el usuario no ha registrado gastos en el día de hoy (para HU11)
  bool get hasNoExpensesToday => totalSpentToday == 0.0;

  // Método para registrar un nuevo gasto
  void addExpense(String title, double amount, String category) {
    final newExpense = ExpenseEntity(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
    );
    _expenses.add(newExpense);
    notifyListeners();
  }
}