import 'dart:math' as math;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// ML Kit devuelve el texto por bloques: en un recibo la columna de
/// descripciones y la de precios salen como bloques distintos, y "TOTAL"
/// queda lejos de su monto. Aquí se rearman las filas: líneas cuyo
/// centro cae a la misma altura se unen de izquierda a derecha.
///
/// La altura se mide sobre el eje del recibo, no de la foto: en una foto
/// inclinada el lado derecho de una fila queda más arriba que el
/// izquierdo, y sin corregirlo "TOTAL" y su monto caían en filas
/// distintas.
Future<String> recognizeText(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(InputImage.fromFilePath(imagePath));
    final lines = [for (final block in result.blocks) ...block.lines];
    if (lines.isEmpty) return '';

    // Inclinación del recibo: mediana del ángulo del borde superior de
    // cada línea (robusta a una que otra línea mal detectada).
    final angles = [for (final l in lines) _angle(l)]..sort();
    final skew = angles[angles.length ~/ 2];
    final cos = math.cos(skew), sin = math.sin(skew);

    final items = [
      for (final l in lines)
        _Line(
          text: l.text,
          // Centro rotado por -skew: x a lo largo de la fila, y a lo alto.
          x: cos * l.boundingBox.center.dx + sin * l.boundingBox.center.dy,
          y: -sin * l.boundingBox.center.dx + cos * l.boundingBox.center.dy,
          height: _height(l),
        ),
    ]..sort((a, b) => a.y.compareTo(b.y));

    final rows = <List<_Line>>[];
    for (final line in items) {
      final row = rows.isEmpty ? null : rows.last;
      if (row != null) {
        final ref = row.first;
        // Misma fila si los centros están a menos de media altura.
        final tolerance = math.min(ref.height, line.height) / 2;
        if ((line.y - ref.y).abs() <= tolerance) {
          row.add(line);
          continue;
        }
      }
      rows.add([line]);
    }

    return rows.map((row) {
      row.sort((a, b) => a.x.compareTo(b.x));
      return row.map((l) => l.text).join(' ');
    }).join('\n');
  } finally {
    await recognizer.close();
  }
}

class _Line {
  const _Line({required this.text, required this.x, required this.y, required this.height});

  final String text;
  final double x;
  final double y;
  final double height;
}

/// Ángulo (radianes) del borde superior: esquina 0 → esquina 1.
double _angle(TextLine line) {
  final p = line.cornerPoints;
  if (p.length < 2) return 0;
  return math.atan2((p[1].y - p[0].y).toDouble(), (p[1].x - p[0].x).toDouble());
}

/// Alto real de la línea (esquina 0 → esquina 3), sin la parte que
/// agrega la inclinación al `boundingBox`.
double _height(TextLine line) {
  final p = line.cornerPoints;
  if (p.length < 4) return line.boundingBox.height;
  final dx = (p[3].x - p[0].x).toDouble(), dy = (p[3].y - p[0].y).toDouble();
  return math.sqrt(dx * dx + dy * dy);
}
