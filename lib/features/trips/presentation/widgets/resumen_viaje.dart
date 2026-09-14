import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart'; // Ajustar la ruta al modelo

class ResumenViaje extends StatelessWidget {
  final Trip viaje;

  const ResumenViaje({
    super.key,
    required this.viaje,
  });

  @override
  Widget build(BuildContext context) {
    final String titulo = viaje.nombre ?? '${viaje.origen} ➔ ${viaje.destino}';
    final String fechaInicioStr = viaje.fechaInicio != null 
        ? '${viaje.fechaInicio!.day}/${viaje.fechaInicio!.month}/${viaje.fechaInicio!.year}'
        : 'Por definir';
    final String fechaFinStr = viaje.fechaFin != null 
        ? '${viaje.fechaFin!.day}/${viaje.fechaFin!.month}/${viaje.fechaFin!.year}'
        : 'Por definir';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del viaje
            Text(
              titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Fechas del viaje
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  '$fechaInicioStr - $fechaFinStr',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Cantidad de personas
            Row(
              children: [
                const Icon(Icons.people, size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  '${viaje.cantidadPersonas ?? 1} personas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Presupuesto total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Presupuesto Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(viaje.presupuestoTotal ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}