import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/Pages/welcome_home.dart';
import 'features/auth/providers/app_auth_provider.dart';
import 'features/places_map/presentation/home_screen_comercio.dart';
import 'features/trips/presentation/pages/home_screen_client.dart';
import 'features/trips/providers/trip_provider.dart';

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
      child: MaterialApp(
        title: 'Travel Guard',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      ),
    );
  }
}

/// Restaura la sesión al recargar la página (antes se ignoraba el
/// estado de [AppAuthProvider] y siempre se mostraba [WelcomeHome],
/// obligando a iniciar sesión de nuevo aunque Firebase/Supabase ya
/// tuvieran la sesión persistida en el navegador).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        if (auth.comercio != null) return const HomeScreenComercio();
        if (auth.tourist != null) return const HomeScreenClient();
        // Sesión confirmada pero el perfil (turista/comercio) todavía
        // se está resolviendo desde Supabase.
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const WelcomeHome();
    }
  }
}
