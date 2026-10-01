import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../theme/app_theme.dart';

class StepProgress extends StatelessWidget {
  final int step;
  final int total;
  final Axis direction;

  const StepProgress({
    Key? key,
    required this.step,
    required this.total,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return _buildVertical(context);
    }
    return _buildHorizontal();
  }

  Widget _buildHorizontal() {
    return Row(
      children: List.generate(total, (index) {
        final isCompleted = index < step;
        final isCurrent = index == step;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            child: Column(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.ink
                        : AppColors.paperDeep,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVertical(BuildContext context) {
    final stepLabels = [
      context.l10n.stepProgressStep1,
      context.l10n.stepProgressStep2,
      context.l10n.stepProgressStep3,
    ];
    return Column(
      children: List.generate(total, (index) {
        final isCompleted = index < step;
        final isCurrent = index == step;
        final isLast = index == total - 1;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? AppColors.ink
                            : AppColors.paperDeep,
                        border: isCurrent
                            ? Border.all(
                                color: AppColors.ink,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: AppText.label(
                                  10,
                                  weight: FontWeight.w700,
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.stepProgressLabel,
                        style: AppText.label(
                          9,
                          weight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stepLabels[index],
                        style: AppText.ui(
                          13,
                          weight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    color: AppColors.line,
                    width: 1,
                    thickness: 1,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}