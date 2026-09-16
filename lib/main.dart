import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/app_auth_provider.dart';
import 'features/trips/providers/trip_provider.dart';
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
    return MaterialApp.router(
      title: 'Travel Guard',
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: _appRouter.router,
      builder: (context, child) => AppShortcuts(
        router: _appRouter.router,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
