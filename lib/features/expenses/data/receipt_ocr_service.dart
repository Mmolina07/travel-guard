import 'package:flutter/foundation.dart';

import 'receipt_ocr_service_stub.dart'
    if (dart.library.io) 'receipt_ocr_service_mlkit.dart' as impl;

/// OCR de recibos 100% en el dispositivo (Google ML Kit, sin internet ni
/// APIs pagas). Solo Android: en web e iOS el escaneo no se ofrece.
abstract final class ReceiptOcrService {
  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Texto del recibo en [imagePath], una fila por línea (cada fila
  /// reconstruida de izquierda a derecha, para que "TOTAL" y su monto
  /// queden juntos aunque el OCR los lea como bloques separados).
  static Future<String> recognize(String imagePath) => impl.recognizeText(imagePath);
}
