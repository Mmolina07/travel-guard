import 'package:flutter/material.dart';

import '../core/l10n/l10n_extension.dart';
import '../core/theme/app_theme.dart';

/// Caja de "no se pudo cargar" con Reintentar: reemplaza el estado vacío
/// cuando falló el servidor, para que un error no se vea como "no hay
/// datos".
class LoadErrorBox extends StatelessWidget {
  const LoadErrorBox({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorWash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppText.ui(13, color: AppColors.error)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(context.l10n.comercioRetry)),
        ],
      ),
    );
  }
}
