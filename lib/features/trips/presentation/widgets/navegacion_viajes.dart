import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/trips/data/models/trip_model.dart';
import 'features/trips/providers/trip_provider.dart';
import 'features/trips/presentation/widgets/navegacion_viajes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Guard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Gestión de Viajes'),
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
  // Lista simulada de viajes del usuario para probar el componente
  final List<Trip> listaViajesPrueba = [
    Trip(id: 1, origen: 'Bogotá', destino: 'Medellín', usuarioId: 1),
    Trip(id: 2, origen: 'Cali', destino: 'Cartagena', usuarioId: 1),
    Trip(id: 3, origen: 'Santa Marta', destino: 'San Andrés', usuarioId: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final activeTrip = Provider.of<TripProvider>(context).activeTrip;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Componente de navegación por tabs/chips
          NavegacionViajes(viajes: listaViajesPrueba),
          const Divider(),
          Expanded(
            child: Center(
              child: activeTrip != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Viaje Seleccionado actualmente:'),
                        Text(
                          '${activeTrip.origen} -> ${activeTrip.destino}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    )
                  : const Text('Por favor selecciona un viaje'),
            ),
          ),
        ],
      ),
    );
  }
}