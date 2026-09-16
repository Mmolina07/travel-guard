import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Barra de presupuesto: crece desde 0 con `easeOutQuart` al montar.
class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.progress,
    this.height = 5,
    this.track = AppColors.line,
    this.fill = AppColors.inkSoft,
  });

  final double progress; // 0..1
  final double height;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: AppMotion.meter,
        curve: AppMotion.meterCurve,
        builder: (context, v, _) => Stack(
          children: [
            Container(height: height, color: track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(height: height, color: fill),
            ),
          ],
        ),
      ),
    );
  }
}
