import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Envoltura táctil: escala 1 -> 0.96 y sombra que se recoge al presionar.
/// Reemplaza a InkWell/ElevatedButton en toda la app.
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

  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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

/// Tarjeta interactiva: sustituye a los botones sueltos del Home.
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
