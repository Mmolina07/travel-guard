// lib/models/trip_model.dart
class Trip {
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
  final double tours;
  final double restaurants;
  final double discotheque;
  final double souvenirs;
  final double paidActivities;
  final double emergencyMoney;

  Trip({
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
    required this.tours,
    required this.restaurants,
    required this.discotheque,
    required this.souvenirs,
    required this.paidActivities,
    required this.emergencyMoney,
  });

  double getTotalSpent() {
    return advancePayment + lodgingCost + tours + 
           restaurants + discotheque + souvenirs + 
           paidActivities + emergencyMoney;
  }

  double getRemainingBudget() {
    return maxBudget - getTotalSpent();
  }

  double getBudgetPercentage() {
    return (getTotalSpent() / maxBudget * 100);
  }
}

class Expense {
  final String category;
  final double amount;
  final String description;

  Expense({
    required this.category,
    required this.amount,
    this.description = '',
  });
}