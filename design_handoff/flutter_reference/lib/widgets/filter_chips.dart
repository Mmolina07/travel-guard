import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Chips de filtro: color + radio animados, con rebote elástico corto.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _Chip(
              label: items[i],
              active: i == selected,
              onTap: () => onSelect(i),
            ),
            if (i != items.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: active ? 1 : 0, end: active ? 1 : 0),
        duration: AppMotion.chip,
        curve: AppMotion.bouncy,
        builder: (context, t, _) => Transform.scale(
          scale: 1 + 0.04 * t,
          child: AnimatedContainer(
            duration: AppMotion.chip,
            curve: AppMotion.press,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.ink : Colors.transparent,
              border: Border.all(color: active ? AppColors.ink : AppColors.hair),
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppMotion.chip,
              style: AppText.ui(
                13,
                weight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.mint : AppColors.textMuted,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
