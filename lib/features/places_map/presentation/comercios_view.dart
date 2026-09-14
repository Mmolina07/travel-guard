import 'package:flutter/material.dart';
import '../data/comercio_model.dart';

class ComerciosCercanosView extends StatelessWidget {
  final List<Comercio> comercios;

  const ComerciosCercanosView({super.key, required this.comercios});

  @override
  Widget build(BuildContext context) {
    // TG-154: Validación de estado vacío
    if (comercios.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No hay comercios cercanos',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // TG-153: Mostrar información en detalles (nombre, dirección, teléfono, calificación, horario)
    return ListView.builder(
      itemCount: comercios.length,
      itemBuilder: (context, index) {
        final comercio = comercios[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comercio.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Dirección: ${comercio.direccion}'),
                Text('Teléfono: ${comercio.telefono}'),
                Text('Horario: ${comercio.horario}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text('${comercio.calificacion}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}