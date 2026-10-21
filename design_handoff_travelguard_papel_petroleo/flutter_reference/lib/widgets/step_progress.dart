import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Progreso de "Crear viaje" (3 pasos). Cada tramo se rellena con easeOutBack.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, this.total = 3});

  final int step; // 0-based
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.step,
              curve: AppMotion.enter,
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.inkSoft : AppColors.hair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
