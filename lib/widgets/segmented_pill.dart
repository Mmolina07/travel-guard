import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Toggle de dos opciones (p.ej. Turista/Comercio en Login).
/// `AnimatedAlign` mueve el thumb con `easeOutBack`.
class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  }) : assert(labels.length == 2);

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final thumbWidth = (c.maxWidth - 10) / 2;
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.paperDeep,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppMotion.toggle,
                curve: AppMotion.enter,
                alignment:
                    index == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: thumbWidth,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: SizedBox(
                            height: 44,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: AppMotion.toggle,
                                curve: AppMotion.press,
                                style: AppText.ui(
                                  14,
                                  weight: i == index
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: i == index
                                      ? AppColors.paper
                                      : AppColors.textMuted,
                                ),
                                child: Text(labels[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
