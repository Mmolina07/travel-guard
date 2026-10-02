import 'package:flutter_test/flutter_test.dart';
import 'package:travelguard/features/subscriptions/data/models/tarjeta_model.dart';

void main() {
  group('numeroTarjetaValido (Luhn)', () {
    test('acepta las tarjetas de prueba de Mercado Pago', () {
      expect(numeroTarjetaValido('4013 5406 8274 6260'), isTrue);
      expect(numeroTarjetaValido('5254133674403564'), isTrue);
    });

    test('rechaza un dígito mal digitado o muy corto', () {
      expect(numeroTarjetaValido('4013 5406 8274 6261'), isFalse);
      expect(numeroTarjetaValido('4013'), isFalse);
    });
  });

  test('MarcaTarjeta.detectar por BIN', () {
    expect(MarcaTarjeta.detectar('4013 5406'), MarcaTarjeta.visa);
    expect(MarcaTarjeta.detectar('5254 1336'), MarcaTarjeta.mastercard);
    expect(MarcaTarjeta.detectar('2221 0000'), MarcaTarjeta.mastercard);
    expect(MarcaTarjeta.detectar('3743 7818'), MarcaTarjeta.amex);
    expect(MarcaTarjeta.detectar('3600 0000'), MarcaTarjeta.diners);
    expect(MarcaTarjeta.detectar('6011 0000'), isNull);
  });

  group('parseVencimiento', () {
    final hoy = DateTime(2026, 10, 2);

    test('vigente y el mes actual todavía sirven', () {
      expect(parseVencimiento('11/30', ahora: hoy), (11, 2030));
      expect(parseVencimiento('10/26', ahora: hoy), (10, 2026));
    });

    test('vencida, mes inválido o formato raro', () {
      expect(parseVencimiento('09/26', ahora: hoy), isNull);
      expect(parseVencimiento('13/30', ahora: hoy), isNull);
      expect(parseVencimiento('1130', ahora: hoy), isNull);
    });
  });
}
