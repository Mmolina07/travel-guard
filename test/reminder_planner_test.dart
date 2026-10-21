import 'package:flutter_test/flutter_test.dart';
import 'package:travelguard/features/expenses/data/models/gasto_model.dart';
import 'package:travelguard/features/expenses/utils/reminder_planner.dart';
import 'package:travelguard/features/trips/presentation/pages/trip_model.dart';

Trip _trip({int id = 1, String start = '01/10/2026', String end = '10/10/2026'}) => Trip(
      id: id,
      name: 'Cartagena',
      destination: 'Cartagena',
      startDate: start,
      endDate: end,
      persons: 2,
      tripType: 'vacaciones',
      maxBudget: 1000000,
      advancePayment: 0,
      lodgingType: 'Hotel',
      lodgingCost: 0,
      includedServices: const [],
      startTransport: 'vuelo',
      duringTransport: 'uber',
      emergencyMoney: 0,
    );

Gasto _gasto(DateTime fecha, double monto, {DateTime? createdAt}) => Gasto(
      id: 1,
      viajeId: 1,
      categoriaId: 1,
      categoriaNombre: 'Comida',
      monto: monto,
      fecha: fecha,
      createdAt: createdAt,
    );

List<BudgetReminder> _plan(
  DateTime now, {
  List<(Trip, List<Gasto>)>? trips,
  int hours = 4,
  bool summary = false,
  bool tripReminder = true,
  Set<String> shown = const {},
  Map<int, DateTime> lastNudge = const {},
}) =>
    planReminders(
      now: now,
      trips: trips ?? [(_trip(), const <Gasto>[])],
      reminderHours: hours,
      dailySummary: summary,
      tripReminder: tripReminder,
      shownKeys: shown,
      lastNudge: lastNudge,
    );

Iterable<BudgetReminder> _of(List<BudgetReminder> r, ReminderKind k) => r.where((x) => x.kind == k);

void main() {
  final day = DateTime(2026, 10, 5);
  DateTime at(int h, [int m = 0]) => DateTime(2026, 10, 5, h, m);

  group('CA5 — X horas sin registrar gastos', () {
    test('pregunta a las 4 h desde las 8 AM si no hay gastos', () {
      expect(_of(_plan(at(11, 59)), ReminderKind.noExpenses), isEmpty);
      final r = _of(_plan(at(12)), ReminderKind.noExpenses).single;
      expect(r.hoursWithoutExpenses, 4);
      expect(r.endOfDay, isFalse);
    });

    test('cuenta desde el último gasto registrado', () {
      final trips = [(_trip(), [_gasto(day, 10000, createdAt: at(10))])];
      expect(_of(_plan(at(13), trips: trips), ReminderKind.noExpenses), isEmpty);
      expect(_of(_plan(at(14), trips: trips), ReminderKind.noExpenses), hasLength(1));
    });

    test('respeta la preferencia de horas y no repite antes de tiempo', () {
      expect(_of(_plan(at(10), hours: 2), ReminderKind.noExpenses), hasLength(1));
      final nudged = {1: at(12)};
      expect(_of(_plan(at(15), lastNudge: nudged), ReminderKind.noExpenses), isEmpty);
      expect(_of(_plan(at(16), lastNudge: nudged), ReminderKind.noExpenses), hasLength(1));
    });

    test('no pregunta fuera del horario (8 AM – 10 PM) ni fuera del viaje', () {
      expect(_of(_plan(at(22, 30)), ReminderKind.noExpenses).where((r) => !r.endOfDay), isEmpty);
      expect(_of(_plan(DateTime(2026, 10, 20, 15)), ReminderKind.noExpenses), isEmpty);
    });

    test('a las 11 PM, si el día terminó sin gastos, avisa una vez (TG-279)', () {
      final r = _of(_plan(at(23)), ReminderKind.noExpenses).single;
      expect(r.endOfDay, isTrue);
      expect(_of(_plan(at(23), shown: {r.key}), ReminderKind.noExpenses), isEmpty);
      final withExpense = [(_trip(), [_gasto(day, 5000)])];
      expect(_of(_plan(at(23), trips: withExpense), ReminderKind.noExpenses), isEmpty);
    });
  });

  group('CA6 — resumen de las 11 PM', () {
    test('solo si está activado, una vez, con lo gastado hoy', () {
      final trips = [(_trip(), [_gasto(day, 30000)])];
      expect(_of(_plan(at(23), trips: trips), ReminderKind.dailySummary), isEmpty);
      final r = _of(_plan(at(23), trips: trips, summary: true), ReminderKind.dailySummary).single;
      expect(r.day!.spent, 30000);
      // Día 5: 1M libre entre los 6 días que faltan (incluido hoy) − 30k.
      expect(r.day!.remaining, closeTo(1000000 / 6 - 30000, 0.01));
      expect(_of(_plan(at(23), trips: trips, summary: true, shown: {r.key}), ReminderKind.dailySummary), isEmpty);
      expect(_of(_plan(at(22, 59), trips: trips, summary: true), ReminderKind.dailySummary), isEmpty);
    });
  });

  group('CA8 — cierre del día', () {
    test('a las 11:59 PM con el número de día del viaje', () {
      final trips = [(_trip(), [_gasto(day, 60000)])];
      final today = _of(_plan(at(23, 59), trips: trips), ReminderKind.dayClosing)
          .firstWhere((r) => r.day!.date == day);
      expect(today.tripDayNumber, 5);
      expect(today.day!.dailyBudget, closeTo(1000000 / 6, 0.01));
      expect(today.day!.remaining, closeTo(1000000 / 6 - 60000, 0.01)); // ahorro
      expect(_of(_plan(at(23, 58), trips: trips), ReminderKind.dayClosing).where((r) => r.day!.date == day), isEmpty);
    });

    test('si la app estaba cerrada, sale al abrirla al día siguiente', () {
      final r = _of(_plan(DateTime(2026, 10, 6, 9)), ReminderKind.dayClosing).single;
      expect(r.day!.date, day);
      expect(_of(_plan(DateTime(2026, 10, 6, 9), shown: {r.key}), ReminderKind.dayClosing), isEmpty);
    });

    test('no hay cierre de días fuera del viaje', () {
      expect(_of(_plan(DateTime(2026, 10, 12, 9)), ReminderKind.dayClosing), isEmpty);
    });
  });

  group('CA9 — viaje próximo', () {
    final future = [(_trip(id: 2, start: '20/10/2026', end: '25/10/2026'), const <Gasto>[])];
    BudgetReminder? on(int d, {Set<String> shown = const {}, bool pref = true}) {
      final r = _of(_plan(DateTime(2026, 10, d, 10), trips: future, shown: shown, tripReminder: pref),
          ReminderKind.upcomingTrip);
      return r.isEmpty ? null : r.single;
    }

    test('avisa a 3 días y a 1 día', () {
      expect(on(15), isNull); // faltan 5
      expect(on(17)!.daysUntil, 3);
      expect(on(18, shown: {'trip3_2'}), isNull); // ya avisado el de 3 días
      expect(on(18)!.daysUntil, 2); // si no abrió la app a los 3
      expect(on(19)!.daysUntil, 1);
      expect(on(19, shown: {'trip1_2'}), isNull);
      expect(on(20), isNull); // ya empezó
    });

    test('respeta la preferencia', () {
      expect(on(17, pref: false), isNull);
    });
  });
}
