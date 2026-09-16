import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Envoltura táctil: escala 1 → 0.96 al presionar. Reemplaza a
/// `InkWell`/`ElevatedButton` para el feedback de toda la app (el
/// splash de Material está desactivado — ver `AppTheme.light()`).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        child: Listener(
          onPointerDown: (_) => _set(true),
          onPointerUp: (_) => _set(false),
          onPointerCancel: (_) => _set(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _down ? widget.scale : 1,
              duration: AppMotion.pressIn,
              curve: AppMotion.press,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta interactiva simple (sin hover) — para escritorio usa
/// [HoverCard] en su lugar, que además eleva la sombra al pasar el
/// mouse. Esta queda para contextos donde no hace falta ese estado
/// (p.ej. dentro de una tarjeta que ya está en hover por su padre).
class PressableCard extends StatelessWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.radius = AppRadius.cardLg,
    this.padding = const EdgeInsets.all(20),
    this.shadow = AppShadow.card,
    this.heroTag,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final List<BoxShadow> shadow;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: AppMotion.toggle,
      curve: AppMotion.press,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: child,
    );

    final content = heroTag == null
        ? box
        : Hero(
            tag: heroTag!,
            createRectTween: (a, b) => MaterialRectArcTween(begin: a, end: b),
            child: Material(color: Colors.transparent, child: box),
          );

    return Pressable(onTap: onTap, child: content);
  }
}
