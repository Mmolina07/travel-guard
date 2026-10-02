import 'package:flutter/foundation.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseProvider with ChangeNotifier {
  final List<ExpenseEntity> _expenses = [];
  
  // Presupuesto diario base en COP
  double _dailyBudget = 50000.0;
  
  // Interruptor para activar/silenciar las alertas de presupuesto (HU11 - Escenario 4)
  bool _notificationsEnabled = true;

  // --- GETTERS ---
  List<ExpenseEntity> get expenses => _expenses;
  double get dailyBudget => _dailyBudget;
  bool get notificationsEnabled => _notificationsEnabled;

  // --- MÉTODOS DE CONFIGURACIÓN ---
  
  /// Permite ajustar el presupuesto diario desde la pantalla de Ajustes
  void setDailyBudget(double budget) {
    _dailyBudget = budget;
    notifyListeners();
  }

  /// Activa o silencia las notificaciones y alertas de presupuesto
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // --- LÓGICA DE NEGOCIO Y CÁLCULOS (HU11) ---

  /// Total gastado en la fecha de hoy
  double get totalSpentToday {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Presupuesto disponible restante para el día de hoy
  double get remainingBudgetToday => _dailyBudget - totalSpentToday;

  /// Porcentaje gastado del presupuesto diario
  double get spentPercentage =>
      _dailyBudget > 0 ? (totalSpentToday / _dailyBudget) * 100 : 0.0;

  /// Retorna true si un nuevo gasto ingresado superará el presupuesto disponible
  bool exceedsBudget(double newAmount) {
    return (totalSpentToday + newAmount) > _dailyBudget;
  }

  /// Retorna true si el usuario no ha registrado ningún gasto hoy (útil para el recordatorio de las 11:00 PM)
  bool get hasNoExpensesToday => totalSpentToday == 0.0;

  // --- OPERACIONES ---

  /// Agrega un nuevo gasto a la lista
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