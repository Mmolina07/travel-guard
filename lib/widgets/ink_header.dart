import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'pressable.dart';

/// Cabecera petróleo de las pantallas secundarias (comercio, planes),
/// con la anatomía de la cabecera de Detalle del handoff: botón atrás
/// fantasma, etiqueta mono `mint`, título display con la segunda línea
/// en itálica `mint` y una sola esquina grande (`bottomRight`).
///
/// Con [asCard] se dibuja como tarjeta con margen (escritorio, dentro
/// del shell — `WEB_LAYOUT.md` › Detalle del viaje).
class InkHeader extends StatelessWidget {
  const InkHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.titleAccent,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.bottom,
    this.asCard = false,
  });

  final String eyebrow;
  final String title;

  /// Segunda línea del título, en itálica `mint`.
  final String? titleAccent;
  final String? subtitle;
  final VoidCallback? onBack;

  /// Acciones a la derecha de la fila superior.
  final Widget? trailing;

  /// Contenido extra debajo del título (chips de estado, cifras...).
  final Widget? bottom;
  final bool asCard;

  @override
  Widget build(BuildContext context) {
    final titleSize = asCard ? 40.0 : 36.0;
    final header = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(26, asCard ? 30 : 22, 26, 30),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: asCard
            ? const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(60),
              )
            : AppRadius.headerDetail,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBack != null) ...[
                  GhostIconButton(icon: Icons.arrow_back, onTap: onBack!),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: AppText.label(11, color: AppColors.mint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: title, style: AppText.display(titleSize, color: AppColors.paper)),
                  if (titleAccent != null) ...[
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: titleAccent,
                      style: AppText.displayItalic(titleSize, color: AppColors.mint),
                    ),
                  ],
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(subtitle!, style: AppText.ui(14, color: AppColors.textOnInk)),
            ],
            if (bottom != null) ...[
              const SizedBox(height: 18),
              bottom!,
            ],
          ],
        ),
      ),
    );
    if (!asCard) return header;
    return Padding(padding: const EdgeInsets.only(bottom: 26), child: header);
  }
}

/// Botón fantasma 40×40 sobre `ink` (borde blanco 24%, radio 14).
class GhostIconButton extends StatelessWidget {
  const GhostIconButton({super.key, required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      onTap: onTap,
      semanticLabel: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: AppColors.paper.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, color: AppColors.paper, size: 20),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
