import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'features/auth/presentation/Pages/welcome_home.dart';
import 'features/auth/providers/app_auth_provider.dart';
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const WelcomeHome(),
      ),
    );
  }
}
