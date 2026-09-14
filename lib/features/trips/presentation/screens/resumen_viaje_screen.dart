import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../widgets/resumen_viaje.dart';
import '../widgets/desglose_presupuesto.dart';

class ResumenViajeScreen extends StatelessWidget {
  const ResumenViajeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final viajeActivo = tripProvider.activeTrip;

    // TG-246: Implementar estado vacío
    if (!tripProvider.hasActiveTrip || viajeActivo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_travel,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay viajes creados',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comienza creando tu primer viaje para planificar tu presupuesto y detalles.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Crear Nuevo Viaje'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Navegar al formulario de creación de viaje
                  Navigator.pushNamed(context, '/crear-viaje');
                },
              ),
            ],
          ),
        ),
      );
    }

    // TG-245: Vista integrada cuando existe un viaje activo
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ResumenViaje(viaje: viajeActivo),
          const SizedBox(height: 8),
          DesglosePresupuesto(viaje: viajeActivo),
        ],
      ),
    );
  }
}