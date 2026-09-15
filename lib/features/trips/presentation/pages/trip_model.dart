// lib/models/trip_model.dart
import '../../data/models/trip_budget_category.dart';
import '../../utils/budget_calculator.dart';

class Trip {
  final int? id;
  final String name;
  final String destination;
  final String startDate;
  final String endDate;
  final int persons;
  final String tripType;
  final double maxBudget;
  final double advancePayment;
  final String lodgingType;
  final double lodgingCost;
  final List<String> includedServices;
  final String startTransport;
  final String duringTransport;
  // Categorías de presupuesto personalizables (antes eran 5 campos fijos:
  // tours/restaurants/discotheque/souvenirs/paidActivities). El usuario
  // puede agregar, renombrar o quitar categorías libremente.
  final List<TripBudgetCategory> categories;
  final double emergencyMoney;
  // TG-141 / HU-05 Escenarios 8-9: si se creó con campos opcionales vacíos.
  final bool datosCompletos;

  Trip({
    this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.persons,
    required this.tripType,
    required this.maxBudget,
    required this.advancePayment,
    required this.lodgingType,
    required this.lodgingCost,
    required this.includedServices,
    required this.startTransport,
    required this.duringTransport,
    this.categories = const [],
    required this.emergencyMoney,
    this.datosCompletos = true,
  });

  Trip copyWith({
    int? id,
    double? maxBudget,
    double? advancePayment,
    double? lodgingCost,
    List<TripBudgetCategory>? categories,
    double? emergencyMoney,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      persons: persons,
      tripType: tripType,
      maxBudget: maxBudget ?? this.maxBudget,
      advancePayment: advancePayment ?? this.advancePayment,
      lodgingType: lodgingType,
      lodgingCost: lodgingCost ?? this.lodgingCost,
      includedServices: includedServices,
      startTransport: startTransport,
      duringTransport: duringTransport,
      categories: categories ?? this.categories,
      emergencyMoney: emergencyMoney ?? this.emergencyMoney,
      datosCompletos: datosCompletos,
    );
  }

  double get categoriesTotal =>
      categories.fold(0.0, (sum, c) => sum + c.monto);

  double getTotalSpent() {
    return advancePayment + lodgingCost + categoriesTotal + emergencyMoney;
  }

  double getRemainingBudget() {
    return maxBudget - getTotalSpent();
  }

  double getBudgetPercentage() {
    return (getTotalSpent() / maxBudget * 100);
  }

  /// Presupuesto disponible por día / por persona (mejora "gestor de
  /// presupuesto"): calculado sobre lo que aún queda libre, no sobre el
  /// total, para que sea útil una vez el viaje ya tiene gastos.
  BudgetBreakdown get budgetBreakdown => calculateBudgetBreakdown(
        maxBudget: getRemainingBudget(),
        start: parseDdMmYyyy(startDate),
        end: parseDdMmYyyy(endDate),
        persons: persons,
      );
}
