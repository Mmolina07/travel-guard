import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Insignia de marca "avión + escudo" de TravelGuard — versión
/// compartida y parametrizable (tamaño, color, animación) de la
/// insignia originalmente dibujada en `WelcomeHome`, para poder usarla
/// también como logo en `LoginScreen` y `HomeScreenClient` sin duplicar
/// la lógica de animación en cada pantalla.
class TravelGuardBadge extends StatefulWidget {
  const TravelGuardBadge({
    super.key,
    this.size = 72,
    this.animate = true,
    this.iconColor = Colors.white,
    this.ringColor,
  });

  final double size;
  final bool animate;
  final Color iconColor;
  final Color? ringColor;

  @override
  State<TravelGuardBadge> createState() => _TravelGuardBadgeState();
}

class _TravelGuardBadgeState extends State<TravelGuardBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.ringColor ?? widget.iconColor.withValues(alpha: 0.55);
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final orbitAngle = t * 2 * math.pi;
          final floatOffset = math.sin(t * 2 * math.pi) * (size * 0.045);
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: orbitAngle,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _DashedOrbitPainter(color: ring),
                ),
              ),
              Container(
                width: size * 0.72,
                height: size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.iconColor.withValues(alpha: 0.16),
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.7),
                    width: math.max(1.2, size * 0.016),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Icon(
                    Icons.flight,
                    size: size * 0.33,
                    color: widget.iconColor,
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.03,
                right: size * 0.03,
                child: Container(
                  padding: EdgeInsets.all(math.max(3, size * 0.045)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.inkSoft,
                    border: Border.all(
                      color: AppColors.ink,
                      width: math.max(1.2, size * 0.016),
                    ),
                  ),
                  child: Icon(
                    Icons.shield,
                    size: math.max(10, size * 0.115),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Anillo punteado — evoca una ruta de vuelo alrededor de la insignia.
class _DashedOrbitPainter extends CustomPainter {
  _DashedOrbitPainter({required this.color});

  final Color color;
  static const int _dashCount = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < _dashCount; i++) {
      final startAngle = (i / _dashCount) * 2 * math.pi;
      final sweep = (2 * math.pi / _dashCount) * 0.55;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
