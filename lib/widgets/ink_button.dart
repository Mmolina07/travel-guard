import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'pressable.dart';

enum InkButtonVariant {
  /// `ink` radio 20, texto `paper`, flecha `mint`, sombra `inkButton`.
  primary,

  /// Blanco con borde `hair` (botón secundario del login).
  secondary,

  /// Secundario con texto y borde de error (acciones destructivas).
  danger,

  /// `mint` con texto `ink` — solo sobre fondo `ink`.
  mint,
}

/// Botón del handoff (README › Login / Estados): la escala de
/// [Pressable] da el feedback; en [loading] el texto se reemplaza por un
/// indicador de 18 px manteniendo el alto.
class InkButton extends StatelessWidget {
  const InkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = InkButtonVariant.primary,
    this.icon,
    this.trailingArrow = false,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final InkButtonVariant variant;
  final IconData? icon;

  /// Flecha a la derecha (CTA principal de un flujo).
  final bool trailingArrow;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final (bg, fg, accent, border, shadow) = switch (variant) {
      InkButtonVariant.primary => (
          AppColors.ink,
          AppColors.paper,
          AppColors.mint,
          null,
          AppShadow.inkButton,
        ),
      InkButtonVariant.secondary => (
          AppColors.surface,
          AppColors.ink,
          AppColors.inkSoft,
          AppColors.hair,
          const <BoxShadow>[],
        ),
      InkButtonVariant.danger => (
          AppColors.surface,
          AppColors.error,
          AppColors.error,
          AppColors.error.withValues(alpha: 0.4),
          const <BoxShadow>[],
        ),
      InkButtonVariant.mint => (
          AppColors.mint,
          AppColors.ink,
          AppColors.ink,
          null,
          const <BoxShadow>[],
        ),
    };

    final content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == InkButtonVariant.primary ? AppColors.mint : accent,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: trailingArrow
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppText.ui(15, weight: FontWeight.w700, color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingArrow) ...[
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 20, color: accent),
              ],
            ],
          );

    return AnimatedOpacity(
      opacity: enabled || loading ? 1 : 0.5,
      duration: AppMotion.pressIn,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        semanticLabel: label,
        child: Container(
          width: expand ? double.infinity : null,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          alignment: expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: border == null ? null : Border.all(color: border, width: 1.5),
            boxShadow: enabled ? shadow : const [],
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Etiqueta mono de campo (CORREO, CONTRASEÑA... — README › Login).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(), style: AppText.label(10, color: AppColors.textLabel)),
      );
}

/// Texto de error de campo: #B4413A, 12/w500 (README › Estados).
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(text, style: AppText.ui(12, color: AppColors.error)),
      );
}
