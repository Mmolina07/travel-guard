import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../../data/trip_service.dart';

class ConfirmDeleteTripDialog extends StatelessWidget {
  final Trip viaje;
  final VoidCallback? onViajeEliminado;

  const ConfirmDeleteTripDialog({
    super.key,
    required this.viaje,
    this.onViajeEliminado,
  });

  static Future<void> mostrar(BuildContext context, Trip viaje, {VoidCallback? onSuccess}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => ConfirmDeleteTripDialog(
        viaje: viaje,
        onViajeEliminado: onSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar viaje'),
      content: Text(
        '¿Estás seguro de que deseas eliminar el viaje "${viaje.origen} ➔ ${viaje.destino}"? Esta acción se puede revertir desarchivando el viaje.',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Eliminar'),
          onPressed: () async {
            if (viaje.id == null) return;

            final exito = await TripService.archivarViaje(viaje.id!);

            if (context.mounted) {
              Navigator.of(context).pop();

              if (exito) {
                final tripProvider = Provider.of<TripProvider>(context, listen: false);
                
                // Si el viaje que se eliminó era el activo, limpiamos el estado global
                if (tripProvider.activeTrip?.id == viaje.id) {
                  tripProvider.clearActiveTrip();
                }

                if (onViajeEliminado != null) {
                  onViajeEliminado!();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viaje eliminado correctamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el viaje')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}