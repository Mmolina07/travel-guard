import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'pressable.dart';

/// Tarjeta de escritorio: al pasar el mouse, la sombra sube de `card` a
/// `raised` y el bloque se desplaza -2px en Y, 160ms `easeOutCubic` —
/// ver "Interacción propia de web" en `WEB_LAYOUT.md`. Sigue siendo
/// presionable (usa [Pressable] por dentro), así que sirve tanto para
/// tarjetas de acción como para tarjetas-target completas (viaje,
/// lugar) donde no hay un botón interno.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.radius = AppRadius.card,
    this.padding = const EdgeInsets.all(20),
    this.baseShadow = AppShadow.card,
    this.hoverShadow = AppShadow.raised,
    this.heroTag,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> baseShadow;
  final List<BoxShadow> hoverShadow;
  final Object? heroTag;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: _hovered ? widget.hoverShadow : widget.baseShadow,
      ),
      child: widget.child,
    );

    final content = widget.heroTag == null
        ? box
        : Hero(
            tag: widget.heroTag!,
            createRectTween: (a, b) => MaterialRectArcTween(begin: a, end: b),
            child: Material(color: Colors.transparent, child: box),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Pressable(onTap: widget.onTap, child: content),
    );
  }
}
