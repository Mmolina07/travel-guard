import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'core/network/firebase_bootstrap.dart';
import 'core/network/supabase_client.dart';
import 'features/auth/presentation/Pages/welcome_home.dart';
import 'features/auth/providers/app_auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TG-97/TG-102: sesión con Firebase Authentication (Google).
  await FirebaseBootstrap.initialize();

  // TG-92: persistencia del turista en Supabase.
  await SupabaseConfig.initialize();

  runApp(const MyApp());
=======
import 'features/trips/providers/trip_provider.dart'; // Importa el provider que creaste

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const MyApp(),
    ),
  );
>>>>>>> origin/simon
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppAuthProvider())],
      child: MaterialApp(
        title: 'Travel Guard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
=======
    return MaterialApp(
      title: 'Travel Guard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Travel Guard Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
>>>>>>> origin/simon
        ),
        home: const WelcomeHome(),
      ),
    );
  }
}