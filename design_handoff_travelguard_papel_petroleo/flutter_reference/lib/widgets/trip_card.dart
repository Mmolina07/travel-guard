import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../theme/app_theme.dart';
import 'budget_bar.dart';
import 'pressable.dart';

/// Tarjeta de viaje: toda la tarjeta es el objetivo táctil (sin botón "Ver").
/// El thumb comparte Hero con la cabecera del detalle.
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, this.onTap});

  final Trip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: trip.name,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'trip-thumb-${trip.id}',
              child: Container(
                width: 62,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.wash,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(6),
                child: Text('FOTO', style: AppText.label(7)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'trip-title-${trip.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(trip.name,
                          style: AppText.ui(16, weight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(trip.rangeLabel,
                      style: AppText.label(11, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  BudgetBar(progress: trip.progress),
                  const SizedBox(height: 6),
                  Text(trip.budgetLabel,
                      style: AppText.ui(11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
