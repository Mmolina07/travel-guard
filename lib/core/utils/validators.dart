import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../l10n/l10n_extension.dart';
import 'money_formatter.dart';

/// Reglas de validación compartidas por todos los formularios, para que
/// el mismo tipo de campo se valide igual en toda la app. Cada función
/// devuelve el mensaje de error ya localizado, o `null` si el valor es
/// válido — se pueden pasar tal cual como `validator:` de un
/// `TextFormField` (con `(v) => Validators.x(context, v)`).
abstract final class Validators {
  /// Símbolos que no tienen sentido en ningún texto de la app y que se
  /// usan para inyectar HTML/código.
  static final RegExp _forbidden = RegExp(r'[<>{}\[\]\\]');
  static final RegExp _letter = RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ]');
  static final RegExp _personName = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' \-]+$");
  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneChars = RegExp(r'^\+?[\d\s\-()]+$');
  static final RegExp _nit = RegExp(r'^\d{5,15}(-\d)?$');

  /// Tope de los montos: `numeric(12,2)` admite 10 dígitos enteros.
  static const int maxMoneyDigits = 10;

  static String? required(BuildContext context, String? value) =>
      (value == null || value.trim().isEmpty) ? context.l10n.valRequired : null;

  /// Nombre y apellido de una persona: solo letras (con tildes y ñ),
  /// espacios, apóstrofo y guion.
  static String? personName(
    BuildContext context,
    String? value, {
    bool isRequired = true,
    int max = 100,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? context.l10n.valRequired : null;
    if (!_personName.hasMatch(text) || !_letter.hasMatch(text)) {
      return context.l10n.valPersonName;
    }
    if (text.length < 2) return context.l10n.valTooShort(2);
    if (text.length > max) return context.l10n.valTooLong(max);
    return null;
  }

  /// Nombres de cosas (viaje, destino, negocio, actividad, menú,
  /// producto, sede, dirección): letras, números y signos comunes, al
  /// menos una letra, sin `< > { } [ ] \`.
  static String? title(
    BuildContext context,
    String? value, {
    bool isRequired = true,
    int min = 2,
    int max = 150,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? context.l10n.valRequired : null;
    if (_forbidden.hasMatch(text)) return context.l10n.valInvalidChars;
    if (!_letter.hasMatch(text)) return context.l10n.valNeedsLetter;
    if (text.length < min) return context.l10n.valTooShort(min);
    if (text.length > max) return context.l10n.valTooLong(max);
    return null;
  }

  /// Textos largos (descripciones): sin símbolos peligrosos, con largo
  /// mínimo y máximo.
  static String? freeText(
    BuildContext context,
    String? value, {
    bool isRequired = false,
    int min = 0,
    required int max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? context.l10n.valRequired : null;
    if (_forbidden.hasMatch(text)) return context.l10n.valInvalidChars;
    if (text.length < min) return context.l10n.valTooShort(min);
    if (text.length > max) return context.l10n.valTooLong(max);
    return null;
  }

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  static String? email(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.valRequired;
    if (!isEmail(text) || text.length > 150) return context.l10n.valEmail;
    return null;
  }

  /// Teléfono: solo dígitos (con `+` al inicio, espacios, guiones y
  /// paréntesis opcionales), de 7 a 15 dígitos.
  static String? phone(
    BuildContext context,
    String? value, {
    bool isRequired = true,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? context.l10n.valRequired : null;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (!_phoneChars.hasMatch(text) ||
        digits.length < 7 ||
        digits.length > 15) {
      return context.l10n.valPhone;
    }
    return null;
  }

  /// Contraseña nueva (registro): al menos 8 caracteres.
  static String? newPassword(BuildContext context, String? value) {
    final text = value ?? '';
    if (text.isEmpty) return context.l10n.valRequired;
    if (text.length < 8) return context.l10n.valPasswordMin;
    return null;
  }

  static bool isNit(String value) => _nit.hasMatch(value.trim());

  /// Monto escrito con [ThousandsInputFormatter] (`1.500.000`).
  static String? money(
    BuildContext context,
    String? value, {
    bool isRequired = true,
    bool allowZero = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? context.l10n.valRequired : null;
    final amount = parseThousands(text);
    if (amount == null) return context.l10n.valAmountPositive;
    if (allowZero ? amount < 0 : amount <= 0) {
      return context.l10n.valAmountPositive;
    }
    return null;
  }

  /// Entero dentro de un rango (personas, minutos...).
  static String? intRange(
    BuildContext context,
    String? value, {
    required int min,
    required int max,
  }) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n < min || n > max) {
      return context.l10n.valIntRange(min, max);
    }
    return null;
  }
}

/// Entero de un texto con separador de miles (`1.500.000` → 1500000).
/// `null` si no hay dígitos.
int? parseThousands(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? null : int.tryParse(digits);
}

/// Formatea un entero con separador de miles, sin signo de pesos
/// (`1500000` → `1.500.000`).
String groupThousands(num value) => formatCOP(value).replaceFirst(r'$', '');

/// Montos: solo dígitos, agrupados con punto de miles mientras se
/// escribe (`1.500.000`), y como máximo [maxDigits] dígitos — así también
/// lo que se pega queda limpio y nunca desborda `numeric(12,2)`.
class ThousandsInputFormatter extends TextInputFormatter {
  ThousandsInputFormatter({this.maxDigits = Validators.maxMoneyDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    // Sin ceros a la izquierda ("0005" → "5"), pero se permite "0".
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final formatted = groupThousands(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Deja pasar el texto sin filtrar mientras se está componiendo un
/// carácter en dos pasos (en Mac la `ñ` es `˜` + `n`, igual las tildes):
/// si se filtrara el `˜` intermedio, la `ñ` nunca llega a escribirse. El
/// filtro se aplica en cuanto termina la composición.
class _ComposingSafeFormatter extends TextInputFormatter {
  _ComposingSafeFormatter(this._inner);

  final TextInputFormatter _inner;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final composing = newValue.composing;
    if (composing.isValid && !composing.isCollapsed) return newValue;
    return _inner.formatEditUpdate(oldValue, newValue);
  }
}

/// Formateadores de entrada reutilizables: impiden escribir (o pegar)
/// caracteres que el campo nunca acepta.
abstract final class AppInputFormatters {
  /// Nombres de persona: letras (con tildes y ñ), espacios, apóstrofo y
  /// guion.
  static final TextInputFormatter personName = _ComposingSafeFormatter(
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ' \-]")),
  );

  /// Cualquier texto: bloquea `< > { } [ ] \`.
  static final TextInputFormatter safeText = _ComposingSafeFormatter(
    FilteringTextInputFormatter.deny(RegExp(r'[<>{}\[\]\\]')),
  );

  /// Teléfonos: dígitos, `+`, espacios, guiones y paréntesis.
  static final TextInputFormatter phone = _ComposingSafeFormatter(
    FilteringTextInputFormatter.allow(RegExp(r'[\d+\s()\-]')),
  );

  /// NIT: dígitos y guion.
  static final TextInputFormatter nit = _ComposingSafeFormatter(
    FilteringTextInputFormatter.allow(RegExp(r'[\d\-]')),
  );

  static final TextInputFormatter digits = FilteringTextInputFormatter.digitsOnly;

  static TextInputFormatter maxLength(int n) => LengthLimitingTextInputFormatter(n);
}
