import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import '../../../expenses/data/models/gasto_model.dart'; // Ruta de tus gastos

class ComparativaPresupuestoWidget extends StatelessWidget {
  final Trip viaje;
  final List<Gasto> gastos;

  const ComparativaPresupuestoWidget({
    super.key,
    required this.viaje,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Cálculo general de ejemplo para demostración de la estructura
    double totalGastado = gastos.fold(0.0, (sum, g) => sum + g.monto);
    double presupuestoTotal = viaje.maxBudget;
    bool hayExceso = totalGastado > presupuestoTotal;
    double diferenciaTotal = (presupuestoTotal - totalGastado).abs();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparativa Presupuesto vs Real',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Indicador visual de Ahorro o Exceso (CA4 y CA5)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hayExceso ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hayExceso ? Colors.red : Colors.green),
              ),
              child: Row(
                children: [
                  Icon(
                    hayExceso ? Icons.warning_amber_rounded : Icons.savings_rounded,
                    color: hayExceso ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hayExceso
                          ? 'Excediste por \$${diferenciaTotal.toStringAsFixed(2)} el presupuesto total.'
                          : '¡Bien! Ahorraste \$${diferenciaTotal.toStringAsFixed(2)} en total.',
                      style: TextStyle(
                        color: hayExceso ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Análisis de Categoría con mayor gasto (CA7)
            Text(
              'Análisis de Hábitos de Consumo',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              leading: const Icon(Icons.pie_chart_outline),
              title: const Text('Categoría con más gasto:'),
              subtitle: const Text('Alimentación (45%) - Transporte (30%)'),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Top 3 Establecimientos:'),
              subtitle: const Text('1. Restaurante El Corral\n2. Hotel Caribe\n3. Éxito Express'),
            ),
          ],
        ),
      ),
    );
  }
}