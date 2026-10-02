import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/l10n/language_provider.dart';
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/settings/currency_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/app_auth_provider.dart';
import 'features/expenses/presentation/widgets/expense_reminder_listener.dart';
import 'features/expenses/providers/budget_alerts_provider.dart';
import 'features/trips/providers/trip_provider.dart';
import 'l10n/app_localizations.dart';
import 'shell/app_shortcuts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TG-97/TG-102: sesión con Firebase Authentication (Google).
  await FirebaseBootstrap.initialize();

  // TG-92: persistencia del turista en Supabase.
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        // HU-11: % del presupuesto diario en segundo plano + recordatorio
        // de las 11:00 PM; sigue la sesión de `AppAuthProvider`.
        ChangeNotifierProxyProvider<AppAuthProvider, BudgetAlertsProvider>(
          create: (_) => BudgetAlertsProvider(),
          update: (_, auth, alerts) => alerts!..updateAuth(auth),
        ),
      ],
      child: _RoutedApp(),
    );
  }
}

/// Necesita su propio `context` (por debajo de `MultiProvider`) para
/// leer `AppAuthProvider` al construir el `AppRouter` — antes esto
/// vivía directo en `MyApp.build`, pero `Provider.of` ahí arriba del
/// `MultiProvider` no encuentra nada.
class _RoutedApp extends StatefulWidget {
  const _RoutedApp();

  @override
  State<_RoutedApp> createState() => _RoutedAppState();
}

class _RoutedAppState extends State<_RoutedApp> {
  late final AppRouter _appRouter = AppRouter(context.read<AppAuthProvider>());

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;

    return MaterialApp.router(
      title: 'Travel Guard',
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      locale: locale,
      supportedLocales: LanguageProvider.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _appRouter.router,
      builder: (context, child) => AppShortcuts(
        router: _appRouter.router,
        child: ExpenseReminderListener(
          router: _appRouter.router,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
