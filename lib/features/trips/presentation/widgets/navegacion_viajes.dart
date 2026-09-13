import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trip_data_loader.dart';

class NavegacionViajes extends StatelessWidget {
  final List<Trip> viajes;

  const NavegacionViajes({
    super.key,
    required this.viajes,
  });

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final viajeActivo = tripProvider.activeTrip;

    if (viajes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay viajes disponibles'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: viajes.map((viaje) {
          final isSelected = viajeActivo?.id == viaje.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text('${viaje.origen} ➔ ${viaje.destino}'),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              onSelected: (bool selected) {
                if (selected && viaje.id != null) {
                  // 1. Actualizar viaje activo en el estado global
                  tripProvider.setActiveTrip(viaje);

                  // 2. Disparar carga dinámica de presupuesto, gastos y actividades
                  TripDataLoader.cargarDatosDelViaje(context, viaje.id!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}