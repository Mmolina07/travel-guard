import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Chips de filtro: color + radio animados, con rebote elástico corto.
/// En escritorio/tablet se acomodan en `Wrap` (caben); en móvil van en
/// scroll horizontal — ver "Comercios" en `WEB_LAYOUT.md`.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.alignment = WrapAlignment.start,
    this.forceScrollable = false,
    this.duration = AppMotion.chip,
    this.curve = AppMotion.bouncy,
    this.fontSize = 13,
  });

  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final WrapAlignment alignment;

  /// Fuerza el scroll horizontal (como en móvil) aunque no se esté en
  /// breakpoint móvil — útil cuando la lista de opciones es larga y un
  /// `Wrap` quedaría descuadrado en el espacio disponible.
  final bool forceScrollable;

  /// Duración/curva del cambio de chip. Por defecto la tabla del README
  /// (380 ms `elasticOut`); el panel de comercio usa 300 ms
  /// `easeOutBack` (`PROMPT_COMERCIO.md` Fase 6).
  final Duration duration;
  final Curve curve;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (var i = 0; i < items.length; i++)
        _Chip(
          label: items[i],
          active: i == selected,
          onTap: () => onSelect(i),
          duration: duration,
          curve: curve,
          fontSize: fontSize,
        ),
    ];

    if (context.isMobile || forceScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              chips[i],
              if (i != chips.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: alignment,
      children: chips,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.duration,
    required this.curve,
    required this.fontSize,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Duration duration;
  final Curve curve;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: active ? 1 : 0, end: active ? 1 : 0),
          duration: duration,
          curve: curve,
          builder: (context, t, _) => Transform.scale(
            scale: 1 + 0.04 * t,
            child: AnimatedContainer(
              duration: duration,
              curve: AppMotion.press,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.ink : Colors.transparent,
                border:
                    Border.all(color: active ? AppColors.ink : AppColors.hair),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: AnimatedDefaultTextStyle(
                duration: duration,
                style: AppText.ui(
                  fontSize,
                  weight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.mint : AppColors.textMuted,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
