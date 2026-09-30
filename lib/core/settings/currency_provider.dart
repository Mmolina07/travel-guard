import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/money_formatter.dart';

/// Preferencia de moneda + tasa de cambio mostradas en Configuración.
///
/// **Solo visual, sin API**: convierte los montos que se muestran en
/// pantalla usando una tasa que el propio usuario ingresa a mano (no se
/// consulta ningún servicio externo). Lo que se guarda en Supabase
/// (`gastos.monto`, `viajes.presupuesto_maximo`, etc.) sigue siendo
/// siempre el monto real en pesos colombianos, sin tocar — esta
/// conversión ocurre solo al momento de renderizar el texto.
class CurrencyProvider extends ChangeNotifier {
  static const _prefsKeyCurrency = 'app_currency_code';
  static const _prefsKeyRatePrefix = 'app_currency_rate_';
  static const defaultCurrency = 'COP';
  static const supportedCurrencies = ['COP', 'USD', 'EUR'];

  /// Cuántos pesos colombianos equivalen a 1 unidad de esa moneda.
  /// Son valores de referencia (no una tasa oficial en vivo) — el
  /// usuario los ajusta desde Configuración cuando quiera.
  static const Map<String, double> defaultRates = {
    'USD': 4000.0,
    'EUR': 4300.0,
  };

  String _currency = defaultCurrency;
  final Map<String, double> _rates = Map.of(defaultRates);

  CurrencyProvider() {
    _loadSaved();
  }

  String get currency => _currency;

  /// Pesos colombianos por 1 unidad de [code] ('USD'/'EUR'). Para 'COP'
  /// no aplica (siempre es el monto tal cual).
  double rateFor(String code) => _rates[code] ?? 1;

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    var changed = false;

    final savedCurrency = prefs.getString(_prefsKeyCurrency);
    if (savedCurrency != null &&
        supportedCurrencies.contains(savedCurrency) &&
        savedCurrency != _currency) {
      _currency = savedCurrency;
      changed = true;
    }

    for (final code in defaultRates.keys) {
      final savedRate = prefs.getDouble('$_prefsKeyRatePrefix$code');
      if (savedRate != null && savedRate > 0) {
        _rates[code] = savedRate;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.contains(code)) return;
    if (code == _currency) return;

    _currency = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyCurrency, code);
  }

  /// Guarda cuántos COP equivalen a 1 unidad de [code] ('USD'/'EUR').
  Future<void> setRate(String code, double copPerUnit) async {
    if (!defaultRates.containsKey(code)) return;
    if (copPerUnit <= 0) return;

    _rates[code] = copPerUnit;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefsKeyRatePrefix$code', copPerUnit);
  }

  Future<void> resetToDefault() async {
    _currency = defaultCurrency;
    _rates
      ..clear()
      ..addAll(defaultRates);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyCurrency);
    for (final code in defaultRates.keys) {
      await prefs.remove('$_prefsKeyRatePrefix$code');
    }
  }

  /// Convierte [amountCop] (siempre el monto real, en pesos) a la moneda
  /// elegida y lo formatea para mostrar. Puramente de presentación.
  String format(num amountCop) {
    if (_currency == 'COP') return formatCOP(amountCop);

    final converted = amountCop / rateFor(_currency);
    final symbol = _currency == 'USD' ? 'US\$' : '€';
    return '$symbol ${_formatWithDecimals(converted)}';
  }

  String _formatWithDecimals(num amount) {
    final isNegative = amount < 0;
    final fixed = amount.abs().toStringAsFixed(2);
    final dot = fixed.indexOf('.');
    final intPart = fixed.substring(0, dot);
    final decimalPart = fixed.substring(dot + 1);

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }
    return '${isNegative ? '-' : ''}$buffer,$decimalPart';
  }
}

/// `context.formatMoney(monto)`: dinero en la moneda elegida por el
/// usuario, sin necesidad de leer `CurrencyProvider` a mano en cada
/// pantalla. Segura de usar tanto dentro de `build()` como en callbacks
/// (SnackBars, diálogos) — usa `read`, nunca `watch`, así que no falla
/// fuera de `build()`. Para que la pantalla se refresque sola cuando el
/// usuario cambia de moneda, esa pantalla debe además tener un
/// `context.watch<CurrencyProvider>()` en su `build()` (una sola vez).
extension CurrencyFormatting on BuildContext {
  String formatMoney(num amountCop) =>
      read<CurrencyProvider>().format(amountCop);
}
