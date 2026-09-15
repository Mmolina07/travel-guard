import 'package:flutter/material.dart';

/// Fondo decorativo de "rutas de vuelo" — un par de curvas punteadas con
/// waypoints, muy sutiles, que refuerzan la identidad de marca (misma
/// idea del anillo punteado de [TravelGuardBadge]) detrás de heroes con
/// fondo oscuro/gradiente, en vez de un color plano sin textura.
class RoutePatternBackground extends StatelessWidget {
  const RoutePatternBackground({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.12,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RoutePainter(color: color.withValues(alpha: opacity)),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(-20, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.02,
        size.width * 0.7,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.44,
        size.width + 20,
        size.height * 0.2,
      );
    _drawDashedPath(canvas, path1, linePaint);

    final path2 = Path()
      ..moveTo(-20, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.98,
        size.width * 0.62,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.56,
        size.width + 20,
        size.height * 0.86,
      );
    _drawDashedPath(canvas, path2, linePaint);

    final dotPaint = Paint()..color = color;
    for (final t in [0.16, 0.52, 0.86]) {
      canvas.drawCircle(
        Offset(size.width * t, size.height * (0.16 + 0.12 * t)),
        2.6,
        dotPaint,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.color != color;
}
