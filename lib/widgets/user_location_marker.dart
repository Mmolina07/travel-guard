import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/app_theme.dart';

/// Ícono del turista en el mapa (TG-145/155: "indicador distinto"):
/// halo ámbar translúcido, anillo `paper` y punto [AppColors.userLocation],
/// con la etiqueta fija [label] ("Tú estás aquí") debajo. Ámbar porque
/// el mapa es petróleo oscuro (`mapInkStyle`) y los pines de lugares
/// usan rojo, naranja, verdes, azules y violetas.
class UserLocationIcon {
  const UserLocationIcon(this.icon, this.anchor);

  final BitmapDescriptor icon;

  /// Apunta al centro del punto (la coordenada GPS real), no al centro
  /// de todo el ícono, que incluye la etiqueta.
  final Offset anchor;

  static Future<UserLocationIcon?> build(String label) async {
    const double dpr = 2.5; // nitidez en pantallas de alta densidad.
    const double haloDiameter = 40 * dpr;
    const double margin = 4 * dpr;
    const double gap = 2 * dpr;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: AppText.ui(10 * dpr, weight: FontWeight.w700, color: AppColors.ink),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const pillPaddingH = 9.0 * dpr;
    const pillPaddingV = 3.0 * dpr;
    final pillWidth = textPainter.width + pillPaddingH * 2;
    final pillHeight = textPainter.height + pillPaddingV * 2;

    final totalWidth = (haloDiameter > pillWidth ? haloDiameter : pillWidth) + margin * 2;
    final totalHeight = haloDiameter + gap + pillHeight + margin * 2;
    final center = Offset(totalWidth / 2, margin + haloDiameter / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

    // Halo de precisión.
    canvas.drawCircle(
      center,
      haloDiameter / 2,
      Paint()..color = AppColors.userLocation.withValues(alpha: 0.28),
    );
    // Sombra + anillo + punto.
    canvas.drawCircle(
      center.translate(0, 1.5 * dpr),
      9.5 * dpr,
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3 * dpr),
    );
    canvas.drawCircle(center, 9.5 * dpr, Paint()..color = AppColors.paper);
    canvas.drawCircle(center, 6.5 * dpr, Paint()..color = AppColors.userLocation);

    // Etiqueta "Tú estás aquí".
    final pillRect = Rect.fromCenter(
      center: Offset(totalWidth / 2, margin + haloDiameter + gap + pillHeight / 2),
      width: pillWidth,
      height: pillHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(pillHeight / 2)),
      Paint()..color = AppColors.userLocation,
    );
    textPainter.paint(canvas, Offset(pillRect.left + pillPaddingH, pillRect.top + pillPaddingV));

    final image = await recorder.endRecording().toImage(totalWidth.ceil(), totalHeight.ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    return UserLocationIcon(
      BitmapDescriptor.bytes(bytes.buffer.asUint8List(), imagePixelRatio: dpr),
      Offset(0.5, center.dy / totalHeight),
    );
  }

  /// Respaldo mientras se dibuja el ícono: pin amarillo (hue 45),
  /// tampoco usado por ninguna categoría.
  static BitmapDescriptor get fallback => BitmapDescriptor.defaultMarkerWithHue(45);
}
