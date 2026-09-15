/// Formatea un monto en pesos colombianos con separador de miles ('.'),
/// como se escriben normalmente ($ 2.000.000 en vez de $2000000) — sin
/// esto, distinguir 200.000 de 2.000.000 a simple vista es difícil.
///
/// No depende de datos de locale de `intl` (evita fallos en tiempo de
/// ejecución si el locale no está inicializado en la plataforma).
String formatCOP(num amount) {
  final rounded = amount.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${isNegative ? '-' : ''}\$$buffer';
}
