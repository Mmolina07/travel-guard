import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelguard/core/notifications/app_notice_center.dart';
import 'package:travelguard/core/settings/currency_provider.dart';
import 'package:travelguard/features/expenses/presentation/widgets/budget_notifications_listener.dart';
import 'package:travelguard/features/expenses/utils/daily_budget_calculator.dart';
import 'package:travelguard/features/expenses/utils/reminder_planner.dart';
import 'package:travelguard/features/trips/presentation/pages/trip_model.dart';
import 'package:travelguard/l10n/app_localizations.dart';

final _trip = Trip(
  id: 7,
  name: 'Cartagena',
  destination: 'Cartagena',
  startDate: '01/10/2026',
  endDate: '10/10/2026',
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<List<AppNotice>> noticesFor(
    WidgetTester tester,
    List<DailyBudgetStatus> days, {
    List<BudgetReminder> reminders = const [],
  }) async {
    final out = <AppNotice>[];
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CurrencyProvider(),
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(builder: (context) {
            for (final d in days) {
              out.add(buildBudgetNotice(context, _trip, d));
            }
            for (final r in reminders) {
              out.add(buildReminderNotice(context, r));
            }
            return const SizedBox();
          }),
        ),
      ),
    );
    return out;
  }

  testWidgets('el aviso al registrar dice a qué % llegó el día (HU-11)', (tester) async {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final notices = await noticesFor(tester, [
      DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 80000),
      DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 90000),
      DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 110000),
      DailyBudgetStatus(date: DateTime(2026, 10, 3), dailyBudget: 100000, spent: 76000),
    ]);

    expect(notices[0].tone, AppNoticeTone.warning);
    expect(notices[0].title, 'Has gastado el 80% de tu presupuesto diario');
    expect(notices[0].message, startsWith('¡Cuidado! Cartagena: te quedan'));
    expect(notices[0].message, endsWith('para hoy.'));

    expect(notices[1].tone, AppNoticeTone.nearLimit);
    expect(notices[1].title, startsWith('Te quedan'));
    expect(notices[1].title, endsWith('de presupuesto para hoy'));

    expect(notices[2].tone, AppNoticeTone.danger);
    expect(notices[2].title, 'Has alcanzado tu límite diario');
    expect(notices[2].message, contains('110%'));

    // Gasto con otra fecha: el aviso nombra ese día, no "hoy".
    expect(notices[3].message, isNot(contains('hoy')));
    expect(notices[3].message, contains('3 oct'));

    // Todos llevan al viaje.
    expect(notices.every((n) => n.route == '/viajes/7'), isTrue);
  });

  testWidgets('textos de los recordatorios (CA5, CA6, CA8, CA9)', (tester) async {
    final day = DateTime(2026, 10, 5);
    final n = await noticesFor(tester, const [], reminders: [
      BudgetReminder(kind: ReminderKind.noExpenses, key: 'a', trip: _trip, hoursWithoutExpenses: 4),
      BudgetReminder(
        kind: ReminderKind.dailySummary,
        key: 'b',
        trip: _trip,
        day: DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 30000),
      ),
      BudgetReminder(
        kind: ReminderKind.dayClosing,
        key: 'c',
        trip: _trip,
        tripDayNumber: 5,
        day: DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 60000),
      ),
      BudgetReminder(
        kind: ReminderKind.dayClosing,
        key: 'd',
        trip: _trip,
        tripDayNumber: 6,
        day: DailyBudgetStatus(date: day, dailyBudget: 100000, spent: 120000),
      ),
      BudgetReminder(kind: ReminderKind.upcomingTrip, key: 'e', trip: _trip, daysUntil: 3),
      BudgetReminder(kind: ReminderKind.upcomingTrip, key: 'f', trip: _trip, daysUntil: 1),
    ]);
    expect(n[0].title, '¿Tuviste gastos hoy que no hayas registrado?');
    expect(n[0].message, contains('4 horas'));
    expect(n[1].title, matches(RegExp(r'^Gasto de hoy: .+30\.000\. Presupuesto restante: .+70\.000$')));
    expect(n[2].title, matches(RegExp(r'^Día 5: Presupuesto .+ \| Gastaste .+ \| Ahorro .+40\.000$')));
    expect(n[3].title, contains('Exceso'));
    expect(n[4].title, 'Tu viaje a Cartagena inicia en 3 días');
    expect(n[4].message, '¿Quieres revisar tu presupuesto?');
    expect(n[5].title, 'Tu viaje a Cartagena inicia en 1 día');
  });
}
