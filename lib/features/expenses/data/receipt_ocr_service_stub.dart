/// Web: ML Kit no existe en el navegador (ver [ReceiptOcrService.isSupported]).
Future<String> recognizeText(String imagePath) =>
    throw UnsupportedError('El escaneo de recibos solo está disponible en Android.');
