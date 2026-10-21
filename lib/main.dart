import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/l10n/language_provider.dart';
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'core/notifications/app_notice_center.dart';
import 'core/notifications/app_notice_overlay.dart';
import 'core/router/app_router.dart';
import 'core/settings/currency_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/app_auth_provider.dart';
import 'features/expenses/presentation/widgets/budget_notifications_listener.dart';
import 'features/expenses/providers/budget_alerts_provider.dart';
import 'features/expenses/providers/notification_prefs_provider.dart';
import 'features/places_map/providers/comercio_panel_provider.dart';
import 'features/subscriptions/providers/subscription_provider.dart';
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
        // La moneda elegida solo aplica al turista (comercio: pesos).
        ChangeNotifierProxyProvider<AppAuthProvider, CurrencyProvider>(
          create: (_) => CurrencyProvider(),
          update: (_, auth, currency) => currency!..updateAuth(auth),
        ),
        // HU-11: "Mostrar alertas" y demás preferencias de recordatorios.
        ChangeNotifierProvider(create: (_) => NotificationPrefsProvider()),
        // Notificaciones dentro de la app (alertas y recordatorios HU-11).
        ChangeNotifierProvider(create: (_) => AppNoticeCenter()),
        // HU-11: % del presupuesto diario y recordatorios en segundo
        // plano; sigue la sesión y las preferencias de recordatorios.
        ChangeNotifierProxyProvider2<AppAuthProvider, NotificationPrefsProvider, BudgetAlertsProvider>(
          create: (_) => BudgetAlertsProvider(),
          update: (_, auth, prefs, alerts) => alerts!
            ..updatePrefs(prefs)
            ..updateAuth(auth),
        ),
        // HU-22/HU-24: si el usuario es Premium (suscripción vigente).
        ChangeNotifierProxyProvider<AppAuthProvider, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
          update: (_, auth, subs) => subs!..updateAuth(auth),
        ),
        // Panel del comercio: perfil, menús y actividades compartidos
        // entre `/comercio`, `/comercio/actividades` y `/comercio/menu`.
        ChangeNotifierProxyProvider<AppAuthProvider, ComercioPanelProvider>(
          create: (_) => ComercioPanelProvider(),
          update: (_, auth, panel) => panel!..updateAuth(auth),
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
        child: AppNoticeOverlay(
          router: _appRouter.router,
          child: BudgetNotificationsListener(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
