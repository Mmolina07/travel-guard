import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../utils/daily_budget_calculator.dart';

/// Tarjeta del presupuesto diario de hoy (HU-11): barra con el % ya
/// consumido y, a partir del 75%, la advertencia correspondiente
/// (preventiva en ámbar, límite superado en rojo).
///
/// Con [compact] solo se dibuja cuando hay algo que advertir — para
/// Inicio, donde una tarjeta "vas bien" en cada visita sería ruido.
class BudgetAlertCard extends StatelessWidget {
  const BudgetAlertCard({
    super.key,
    required this.status,
    this.tripName,
    this.compact = false,
  });

  final DailyBudgetStatus status;
  final String? tripName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final level = status.level;
    if (compact && level == DailyBudgetLevel.ok) return const SizedBox.shrink();

    final (Color accent, Color background, IconData icon, String title, String message) = switch (level) {
      DailyBudgetLevel.exceeded => (
          AppColors.error,
          AppColors.errorWash,
          Icons.error_outline_rounded,
          context.l10n.dailyBudgetExceededTitle,
          context.l10n.dailyBudgetExceededMessage(context.formatMoney(status.remaining.abs())),
        ),
      DailyBudgetLevel.warning => (
          AppColors.warning,
          AppColors.warningWash,
          Icons.warning_amber_rounded,
          context.l10n.dailyBudgetWarningTitle,
          context.l10n.dailyBudgetWarningMessage(
            status.percentage.round(),
            context.formatMoney(status.remaining),
          ),
        ),
      DailyBudgetLevel.ok => (
          AppColors.inkSoft,
          AppColors.surface,
          Icons.today_outlined,
          context.l10n.dailyBudgetTodayTitle,
          context.l10n.dailyBudgetOkMessage(context.formatMoney(status.remaining)),
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: level == DailyBudgetLevel.ok ? null : Border.all(color: accent, width: 1.2),
        boxShadow: level == DailyBudgetLevel.ok ? AppShadow.card : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tripName == null ? title : '$title · $tripName',
                        style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.ink),
                      ),
                    ),
                    Text(
                      '${status.percentage.round()}%',
                      style: AppText.ui(14, weight: FontWeight.w700, color: accent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: AppText.ui(13, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: (status.percentage / 100).clamp(0.0, 1.0)),
                    duration: AppMotion.meter,
                    curve: AppMotion.meterCurve,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      color: accent,
                      backgroundColor: AppColors.line,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.dailyBudgetSpentOf(
                    context.formatMoney(status.spent),
                    context.formatMoney(status.dailyBudget),
                  ),
                  style: AppText.label(10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
