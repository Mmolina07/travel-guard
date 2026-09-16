import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/money_formatter.dart';
import '../features/trips/presentation/pages/trip_model.dart';
import 'budget_bar.dart';
import 'hover_card.dart';

/// Tarjeta de viaje: toda la tarjeta es el objetivo táctil (sin botón
/// "Ver detalles"). Sin `Hero` hacia el detalle — Fase 6: en escritorio
/// cada pantalla monta su propio `AppShell` con sidebar fijo, así que
/// un Hero de tarjeta anima dos sidebars superpuestos; la transición de
/// entrada al detalle (fade + 12px) vive a nivel de ruta en
/// `app_router.dart`.
class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.thumbWidth = 62,
    this.thumbHeight = 72,
  });

  final Trip trip;
  final VoidCallback? onTap;
  final double thumbWidth;
  final double thumbHeight;

  @override
  Widget build(BuildContext context) {
    final spent = trip.getTotalSpent();
    final progress =
        trip.maxBudget > 0 ? (spent / trip.maxBudget).clamp(0.0, 1.0) : 0.0;

    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: AppRadius.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: thumbWidth,
            height: thumbHeight,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(6),
            child: Text('FOTO', style: AppText.label(7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(16, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.startDate} – ${trip.endDate}',
                  style: AppText.label(11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                BudgetBar(progress: progress),
                const SizedBox(height: 6),
                Text(
                  '${formatCOP(spent)} gastado de ${formatCOP(trip.maxBudget)}',
                  style: AppText.ui(11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
