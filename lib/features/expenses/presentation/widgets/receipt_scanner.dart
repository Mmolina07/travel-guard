import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/paper_top_bar.dart';
import '../../data/receipt_ocr_service.dart';
import '../../utils/receipt_parser.dart';

/// Flujo "escanear recibo": cámara → vista previa (Retomar / Confirmar)
/// → "Analizando recibo..." (OCR en el dispositivo) → [ReceiptData].
///
/// Devuelve `null` si el usuario cancela. Si no se pudo leer nada, un
/// resultado con [ReceiptScanResult.error] (el formulario lo muestra:
/// un SnackBar quedaría detrás de la hoja). Si solo faltan algunos
/// campos, los datos encontrados y el formulario deja vacío el resto.
class ReceiptScanResult {
  final ReceiptData? data;
  final String? error;

  const ReceiptScanResult.data(ReceiptData this.data) : error = null;
  const ReceiptScanResult.error(String this.error) : data = null;
}

abstract final class ReceiptScanner {
  static Future<ReceiptScanResult?> scan(BuildContext context) async {
    final l10n = context.l10n;
    final picker = ImagePicker();

    while (true) {
      final XFile? photo;
      try {
        photo = await picker.pickImage(
          source: ImageSource.camera,
          // Suficiente para que el OCR lea bien sin procesar fotos de 12 MP.
          maxWidth: 2200,
          imageQuality: 92,
        );
      } catch (e) {
        debugPrint('ReceiptScanner.pickImage error: $e');
        return ReceiptScanResult.error(l10n.receiptCameraError);
      }
      if (photo == null || !context.mounted) return null;

      final bytes = await photo.readAsBytes();
      if (!context.mounted) return null;
      final action = await Navigator.of(context).push<_PreviewAction>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => _ReceiptPreview(bytes: bytes)),
      );
      if (action == _PreviewAction.retake) continue;
      if (action != _PreviewAction.confirm || !context.mounted) return null;

      final data = await _analyze(context, photo.path);
      if (data == null || data.isEmpty) return ReceiptScanResult.error(l10n.receiptReadError);
      return ReceiptScanResult.data(data);
    }
  }

  /// OCR con un diálogo de "Analizando recibo..." que no se puede cerrar.
  static Future<ReceiptData?> _analyze(BuildContext context, String path) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.inkSoft),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(ctx.l10n.receiptAnalyzing, style: AppText.ui(15, weight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      final text = await ReceiptOcrService.recognize(path);
      return text.trim().isEmpty ? null : ReceiptParser.parse(text);
    } catch (e) {
      debugPrint('ReceiptScanner OCR error: $e');
      return null;
    } finally {
      navigator.pop();
    }
  }
}

enum _PreviewAction { retake, confirm }

/// Vista previa a pantalla completa con Retomar / Confirmar.
class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: PaperTopBar(
        eyebrow: l10n.receiptScanButton,
        title: l10n.receiptPreviewTitle,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.receiptPreviewHint, style: AppText.ui(13, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppRadius.cardLg),
                    boxShadow: AppShadow.card,
                  ),
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InkButton(
                        label: l10n.receiptRetakeButton,
                        icon: Icons.refresh,
                        variant: InkButtonVariant.secondary,
                        expand: true,
                        onPressed: () => Navigator.pop(context, _PreviewAction.retake),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkButton(
                        label: l10n.receiptConfirmButton,
                        trailingArrow: true,
                        expand: true,
                        onPressed: () => Navigator.pop(context, _PreviewAction.confirm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
