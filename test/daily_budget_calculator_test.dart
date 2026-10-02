import 'package:flutter_test/flutter_test.dart';
import 'package:travelguard/features/expenses/data/models/gasto_model.dart';
import 'package:travelguard/features/expenses/utils/daily_budget_calculator.dart';
import 'package:travelguard/features/trips/presentation/pages/trip_model.dart';

Trip _trip({double maxBudget = 1000000, double lodging = 0}) => Trip(
      id: 1,
      name: 'Cartagena',
      destination: 'Cartagena',
      startDate: '01/10/2026',
      endDate: '10/10/2026', // 10 días
      persons: 2,
      tripType: 'vacaciones',
      maxBudget: maxBudget,
      advancePayment: 0,
      lodgingType: 'Hotel',
      lodgingCost: lodging,
      includedServices: const [],
      startTransport: 'vuelo',
      duringTransport: 'uber',
      emergencyMoney: 0,
    );

int _nextId = 1;
Gasto _gasto(DateTime fecha, double monto) => Gasto(
      id: _nextId++,
      viajeId: 1,
      categoriaId: 1,
      categoriaNombre: 'Comida',
      monto: monto,
      fecha: fecha,
    );

void main() {
  test('reparte lo disponible entre los días del viaje', () {
    final calc = DailyBudgetCalculator(trip: _trip(lodging: 500000), gastos: const []);
    final status = calc.statusFor(DateTime(2026, 10, 1));
    expect(status.dailyBudget, 50000); // (1M - 500k) / 10 días
    expect(status.percentage, 0);
    expect(status.level, DailyBudgetLevel.ok);
  });

  test('el % del día solo cuenta los gastos de ese día', () {
    final calc = DailyBudgetCalculator(trip: _trip(), gastos: [
      _gasto(DateTime(2026, 10, 1), 80000),
      _gasto(DateTime(2026, 10, 1), 0), // no suma
    ]);
    final status = calc.statusFor(DateTime(2026, 10, 1));
    expect(status.dailyBudget, 100000);
    expect(status.percentage, 80);
    expect(status.level, DailyBudgetLevel.warning);
  });

  test('gastar de más un día reduce el presupuesto de los siguientes', () {
    final calc = DailyBudgetCalculator(trip: _trip(), gastos: [
      _gasto(DateTime(2026, 10, 1), 190000),
    ]);
    expect(calc.statusFor(DateTime(2026, 10, 1)).level, DailyBudgetLevel.exceeded);
    // Quedan 810k para 9 días.
    expect(calc.statusFor(DateTime(2026, 10, 2)).dailyBudget, 90000);
  });

  test('withExtra proyecta un gasto nuevo (TG-278)', () {
    final calc = DailyBudgetCalculator(trip: _trip(), gastos: [
      _gasto(DateTime(2026, 10, 1), 60000),
    ]);
    final projected = calc.statusFor(DateTime(2026, 10, 1)).withExtra(50000);
    expect(projected.level, DailyBudgetLevel.exceeded);
    expect(projected.remaining, -10000);
  });

  test('sin presupuesto libre, cualquier gasto ya supera el día', () {
    final calc = DailyBudgetCalculator(trip: _trip(lodging: 1000000), gastos: const []);
    final status = calc.statusFor(DateTime(2026, 10, 5)).withExtra(1);
    expect(status.dailyBudget, 0);
    expect(status.level, DailyBudgetLevel.exceeded);
  });

  test('isTripDay y hasExpensesOn (recordatorio TG-279)', () {
    final calc = DailyBudgetCalculator(trip: _trip(), gastos: [
      _gasto(DateTime(2026, 10, 2), 10000),
    ]);
    expect(calc.isTripDay(DateTime(2026, 10, 10, 23)), isTrue);
    expect(calc.isTripDay(DateTime(2026, 10, 11)), isFalse);
    expect(calc.hasExpensesOn(DateTime(2026, 10, 2, 23)), isTrue);
    expect(calc.hasExpensesOn(DateTime(2026, 10, 3)), isFalse);
  });
}
