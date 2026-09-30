import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/trip_model.dart'; // Ajustar la ruta según la estructura

class DesglosePresupuesto extends StatelessWidget {
  final Trip viaje;

  const DesglosePresupuesto({
    super.key,
    required this.viaje,
  });

  Widget _buildItemCategoria(
    BuildContext context, {
    required String titulo,
    required double? monto,
    required IconData icon,
    required Color color,
  }) {
    final double valor = monto ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 18,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.desglosePresupuestoTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildItemCategoria(
              context,
              titulo: context.l10n.desglosePresupuestoHospedaje,
              monto: viaje.presupuestoHospedaje,
              icon: Icons.hotel,
              color: Colors.indigo,
            ),
            _buildItemCategoria(
              context,
              titulo: context.l10n.desglosePresupuestoTransporte,
              monto: viaje.presupuestoTransporte,
              icon: Icons.directions_car,
              color: Colors.orange,
            ),
            _buildItemCategoria(
              context,
              titulo: context.l10n.desglosePresupuestoComidas,
              monto: viaje.presupuestoComidas,
              icon: Icons.restaurant,
              color: AppColors.inkSoft,
            ),
            _buildItemCategoria(
              context,
              titulo: context.l10n.desglosePresupuestoActividades,
              monto: viaje.presupuestoActividades,
              icon: Icons.local_activity,
              color: Colors.purple,
            ),
            _buildItemCategoria(
              context,
              titulo: context.l10n.desglosePresupuestoEmergencias,
              monto: viaje.presupuestoEmergencias,
              icon: Icons.warning_amber_rounded,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}