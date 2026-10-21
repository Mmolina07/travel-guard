import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'pressable.dart';

/// Barra superior de las pantallas móviles sobre papel, con la anatomía
/// de la cabecera de Crear viaje del handoff: botón atrás en caja con
/// borde `hair` (radio 14), etiqueta mono y, opcional, título display.
/// Sustituye al `AppBar` de Material para que todas las pantallas
/// compartan el mismo lenguaje.
class PaperTopBar extends StatelessWidget implements PreferredSizeWidget {
  const PaperTopBar({
    super.key,
    this.eyebrow,
    this.title,
    this.onBack,
    this.trailing,
  });

  /// Etiqueta mono en mayúsculas (p.ej. "PASO 1 DE 3").
  final String? eyebrow;

  /// Título display 26 bajo la etiqueta.
  final String? title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => Size.fromHeight(title != null ? 76 : 64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            if (onBack != null) ...[
              PaperBackButton(onTap: onBack!),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null)
                    Text(
                      eyebrow!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label(11, color: title != null ? AppColors.inkSoft : AppColors.textLabel),
                    ),
                  if (title != null)
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(26),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Botón atrás sobre papel: 40×40, borde `hair`, radio 14.
class PaperBackButton extends StatelessWidget {
  const PaperBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: AppColors.hair),
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
      ),
    );
  }
}
