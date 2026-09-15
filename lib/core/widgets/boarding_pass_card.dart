import 'package:flutter/material.dart';

/// Tarjeta con silueta de "pase de abordar" — dos muescas circulares en
/// los bordes y una línea punteada que separan una franja compacta
/// (`leading`, p.ej. un icono o una fecha, como el talón de un tiquete)
/// del contenido principal. Sin `leading` se comporta como una tarjeta
/// simple con el mismo lenguaje visual (borde + radio), para que el
/// formulario de login y las tarjetas de viaje/función compartan una
/// sola identidad en vez de estilos de `Card` genéricos distintos.
class BoardingPassCard extends StatelessWidget {
  const BoardingPassCard({
    super.key,
    required this.child,
    this.leading,
    this.leadingWidth = 76,
    this.padding = const EdgeInsets.all(20),
    this.leadingPadding = const EdgeInsets.all(12),
    this.color,
    this.borderColor,
    this.borderRadius = 18,
  });

  final Widget child;
  final Widget? leading;
  final double leadingWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry leadingPadding;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = color ?? theme.colorScheme.surface;
    final border = borderColor ?? theme.dividerColor;
    final hasLeading = leading != null;

    final content = Container(
      decoration: BoxDecoration(color: background, border: Border.all(color: border)),
      child: hasLeading
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: leadingWidth,
                    child: Padding(
                      padding: leadingPadding,
                      child: Center(child: leading),
                    ),
                  ),
                  Expanded(child: Padding(padding: padding, child: child)),
                ],
              ),
            )
          : Padding(padding: padding, child: child),
    );

    return ClipPath(
      clipper: _BoardingPassClipper(
        notchOffset: hasLeading ? leadingWidth : 0,
        radius: borderRadius,
      ),
      child: hasLeading
          ? CustomPaint(
              foregroundPainter: _PerforationPainter(offset: leadingWidth, color: border),
              child: content,
            )
          : content,
    );
  }
}

class _BoardingPassClipper extends CustomClipper<Path> {
  _BoardingPassClipper({required this.notchOffset, this.radius = 18, this.notchRadius = 9});

  final double notchOffset;
  final double radius;
  final double notchRadius;

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));

    if (notchOffset <= 0 || notchOffset >= size.width) return base;

    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(notchOffset, 0), radius: notchRadius))
      ..addOval(Rect.fromCircle(center: Offset(notchOffset, size.height), radius: notchRadius));

    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(covariant _BoardingPassClipper oldClipper) =>
      oldClipper.notchOffset != notchOffset ||
      oldClipper.radius != radius ||
      oldClipper.notchRadius != notchRadius;
}

/// Línea punteada vertical que marca la separación del "talón" — dibujada
/// aparte del clip para no depender de que el notch la corte con precisión.
class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.offset, required this.color});

  final double offset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    const dashHeight = 4.0;
    const gap = 4.0;
    var y = 13.0;
    while (y < size.height - 13) {
      canvas.drawLine(Offset(offset, y), Offset(offset, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.color != color;
}
