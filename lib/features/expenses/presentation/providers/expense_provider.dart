import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseProvider with ChangeNotifier {
  final List<ExpenseEntity> _expenses = [];
  double _dailyBudget = 50000.0; // Ejemplo de presupuesto diario en pesos colombianos

  List<ExpenseEntity> get expenses => _expenses;
  double get dailyBudget => _dailyBudget;

  double get totalSpentToday {
    final today = DateTime.now();
    return _expenses
        .where((e) => e.date.year == today.year && e.date.month == today.month && e.date.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Método para agregar un gasto
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

  // Validación de porcentaje gastado (HU11)
  double get spentPercentage => (totalSpentToday / _dailyBudget) * 100;
}