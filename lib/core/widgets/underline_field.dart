import 'package:flutter/material.dart';

import '../l10n/l10n_extension.dart';
import '../theme/app_theme.dart';

/// Campo de texto con etiqueta en versalitas arriba y borde inferior
/// (sin caja rellena) — el estilo de las 5 pantallas rediseñadas a mano
/// (ver `login_screen.dart`), extraído aquí para poder reutilizarlo en
/// el resto de las pantallas de autenticación (registro, recuperación
/// de contraseña) sin duplicarlo.
///
/// Es un `TextFormField` (no `TextField`) para poder usarse tanto suelto
/// (como en `login_screen.dart`, sin `Form`) como dentro de un `Form`
/// con `validator` (como en los formularios de registro).
class UnderlineField extends StatelessWidget {
  const UnderlineField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.emphasized = false,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.trailing,
    this.validator,
    this.onFieldSubmitted,
    this.helperText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool emphasized;
  final bool obscure;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(10)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                enabled: enabled,
                autofocus: autofocus,
                keyboardType: keyboardType,
                validator: validator,
                onFieldSubmitted: onFieldSubmitted,
                style: AppText.ui(18, weight: FontWeight.w500),
                cursorColor: AppColors.inkSoft,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  hintText: hint,
                  helperText: helperText,
                  hintStyle: AppText.ui(18, color: AppColors.textMuted),
                  errorStyle: AppText.ui(11, color: AppColors.error),
                  contentPadding: const EdgeInsets.only(bottom: 8),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: emphasized ? AppColors.ink : AppColors.hair,
                      width: emphasized ? 2 : 1,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.ink, width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error, width: 1),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error, width: 2),
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ],
    );
  }
}

/// Toggle "VER"/"OCULTAR" para mostrar/ocultar contraseña, en texto en
/// vez de ícono de ojo — mismo patrón de `login_screen.dart`, para
/// reutilizar como `trailing` de un [UnderlineField] de contraseña.
class UnderlineFieldPasswordToggle extends StatelessWidget {
  const UnderlineFieldPasswordToggle({
    super.key,
    required this.visible,
    required this.onTap,
  });

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          visible ? context.l10n.loginPasswordHide : context.l10n.loginPasswordShow,
          style: AppText.label(11, color: AppColors.ink),
        ),
      ),
    );
  }
}
