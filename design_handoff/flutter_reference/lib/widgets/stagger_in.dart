import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Entrada escalonada de listas: y 16 -> 0 + fade, 60 ms por índice.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.listItem,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(AppMotion.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: AppMotion.press);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
