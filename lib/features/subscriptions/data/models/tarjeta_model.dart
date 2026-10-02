/// Marcas que acepta el formulario de pago (HU-22), con el
/// `payment_method_id` que espera Mercado Pago.
enum MarcaTarjeta {
  visa('visa', 'Visa', 3),
  mastercard('master', 'Mastercard', 3),
  amex('amex', 'American Express', 4),
  diners('diners', 'Diners Club', 3);

  const MarcaTarjeta(this.mpId, this.nombre, this.digitosCodigo);
  final String mpId;
  final String nombre;
  final int digitosCodigo;

  /// Detecta la marca por los primeros dígitos (BIN).
  static MarcaTarjeta? detectar(String numero) {
    final n = soloDigitos(numero);
    if (n.isEmpty) return null;
    if (n.startsWith('4')) return MarcaTarjeta.visa;
    if (RegExp(r'^3[47]').hasMatch(n)) return MarcaTarjeta.amex;
    if (RegExp(r'^(36|38|30[0-5])').hasMatch(n)) return MarcaTarjeta.diners;
    if (n.length >= 2) {
      final dos = int.parse(n.substring(0, 2));
      if (dos >= 51 && dos <= 55) return MarcaTarjeta.mastercard;
    }
    if (n.length >= 4) {
      final cuatro = int.parse(n.substring(0, 4));
      if (cuatro >= 2221 && cuatro <= 2720) return MarcaTarjeta.mastercard;
    }
    return null;
  }
}

String soloDigitos(String text) => text.replaceAll(RegExp(r'\D'), '');

/// Algoritmo de Luhn: descarta números mal digitados antes de mandarlos
/// a Mercado Pago.
bool numeroTarjetaValido(String numero) {
  final n = soloDigitos(numero);
  if (n.length < 13 || n.length > 19) return false;
  var suma = 0;
  var doblar = false;
  for (var i = n.length - 1; i >= 0; i--) {
    var d = int.parse(n[i]);
    if (doblar) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    suma += d;
    doblar = !doblar;
  }
  return suma % 10 == 0;
}

/// `MM/AA` → (mes, año completo), o `null` si no es válida o ya venció.
(int, int)? parseVencimiento(String text, {DateTime? ahora}) {
  final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(text.trim());
  if (match == null) return null;
  final mes = int.parse(match.group(1)!);
  final anio = 2000 + int.parse(match.group(2)!);
  if (mes < 1 || mes > 12) return null;
  final hoy = ahora ?? DateTime.now();
  // Vence al final de ese mes: sirve hasta el primer día del siguiente.
  if (!DateTime(anio, mes + 1).isAfter(DateTime(hoy.year, hoy.month))) return null;
  return (mes, anio);
}

/// Datos ya validados del formulario. Solo viven en memoria mientras se
/// tokenizan con Mercado Pago; no se guardan en ningún lado.
class DatosTarjeta {
  final String numero;
  final String titular;
  final int mesVencimiento;
  final int anioVencimiento;
  final String codigoSeguridad;
  final String tipoDocumento;
  final String numeroDocumento;

  const DatosTarjeta({
    required this.numero,
    required this.titular,
    required this.mesVencimiento,
    required this.anioVencimiento,
    required this.codigoSeguridad,
    required this.tipoDocumento,
    required this.numeroDocumento,
  });

  MarcaTarjeta? get marca => MarcaTarjeta.detectar(numero);
}
