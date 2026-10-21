import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/providers/app_auth_provider.dart';
import '../utils/money_formatter.dart';

/// Preferencia de moneda + tasa de cambio mostradas en Configuración.
///
/// **Solo visual**: convierte los montos que se muestran en pantalla.
/// La tasa del día se descarga sola (open.er-api.com, gratis y sin key;
/// respaldo: currency-api en jsDelivr) como máximo una vez cada 12 h.
/// No se puede editar a mano. La moneda elegida aplica **solo al
/// turista**: con un comercio (o sin sesión) todo se ve en pesos, aunque
/// en el mismo navegador un turista haya dejado euros. Lo que se guarda en Supabase
/// (`gastos.monto`, `viajes.presupuesto_maximo`, etc.) sigue siendo
/// siempre el monto real en pesos colombianos, sin tocar — esta
/// conversión ocurre solo al momento de renderizar el texto.
class CurrencyProvider extends ChangeNotifier {
  static const _prefsKeyCurrency = 'app_currency_code';
  static const _prefsKeyRatePrefix = 'app_currency_rate_';
  static const _prefsKeyRatesManual = 'app_currency_rates_manual';
  static const _prefsKeyRatesFetchedAt = 'app_currency_rates_fetched_at';
  static const _refreshEvery = Duration(hours: 12);
  static const defaultCurrency = 'COP';
  static const supportedCurrencies = ['COP', 'USD', 'EUR'];

  /// Cuántos pesos colombianos equivalen a 1 unidad de esa moneda.
  /// Respaldo solo si nunca se ha podido descargar la tasa del día.
  static const Map<String, double> defaultRates = {
    'USD': 4000.0,
    'EUR': 4300.0,
  };

  String _currency = defaultCurrency;

  /// true si la sesión no es de un turista: se ignora la moneda elegida.
  bool _soloPesos = true;
  final Map<String, double> _rates = Map.of(defaultRates);
  DateTime? _ratesFetchedAt;

  CurrencyProvider() {
    _loadSaved();
  }

  /// Moneda con la que se muestran los montos ahora mismo.
  String get currency => _soloPesos ? defaultCurrency : _currency;

  /// Solo el turista puede elegir moneda.
  bool get puedeCambiarMoneda => !_soloPesos;

  /// Sigue la sesión (ProxyProvider en `main.dart`).
  void updateAuth(AppAuthProvider auth) {
    final soloPesos = auth.usuario?.tipoUsuario != 'turista';
    if (soloPesos == _soloPesos) return;
    _soloPesos = soloPesos;
    // Corre dentro del `update` del ProxyProvider (en pleno build).
    Future.microtask(notifyListeners);
  }

  /// Pesos colombianos por 1 unidad de [code] ('USD'/'EUR'). Para 'COP'
  /// no aplica (siempre es el monto tal cual).
  double rateFor(String code) => _rates[code] ?? 1;

  /// Cuándo se descargó la tasa en vivo por última vez (null = nunca).
  DateTime? get ratesFetchedAt => _ratesFetchedAt;

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

    // Restos de cuando la tasa se podía fijar a mano: ya no aplica.
    await prefs.remove(_prefsKeyRatesManual);
    final fetchedMs = prefs.getInt(_prefsKeyRatesFetchedAt);
    if (fetchedMs != null) {
      _ratesFetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedMs);
    }

    if (changed) notifyListeners();

    await refreshRates();
  }

  /// Descarga la tasa del día si la guardada tiene más de
  /// [_refreshEvery] (o siempre, con [force]). Nunca lanza: si no hay red
  /// se queda con la última tasa guardada.
  Future<void> refreshRates({bool force = false}) async {
    final last = _ratesFetchedAt;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < _refreshEvery) {
      return;
    }

    final fetched = await _fetchLiveRates();
    if (fetched == null) return;

    _rates.addAll(fetched);
    _ratesFetchedAt = DateTime.now();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    for (final entry in fetched.entries) {
      await prefs.setDouble('$_prefsKeyRatePrefix${entry.key}', entry.value);
    }
    await prefs.setInt(
      _prefsKeyRatesFetchedAt,
      _ratesFetchedAt!.millisecondsSinceEpoch,
    );
  }

  /// COP por USD y por EUR, o null si ninguna fuente responde bien.
  Future<Map<String, double>?> _fetchLiveRates() async {
    try {
      final res = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final rates = (jsonDecode(res.body) as Map)['rates'] as Map;
        final parsed = _toCopRates(rates['COP'], rates['EUR']);
        if (parsed != null) return parsed;
      }
    } catch (_) {}

    try {
      final res = await http
          .get(Uri.parse(
            'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
          ))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final rates = (jsonDecode(res.body) as Map)['usd'] as Map;
        return _toCopRates(rates['cop'], rates['eur']);
      }
    } catch (_) {}

    return null;
  }

  /// A partir de "1 USD = [copPerUsd] COP" y "1 USD = [eurPerUsd] EUR".
  Map<String, double>? _toCopRates(Object? copPerUsd, Object? eurPerUsd) {
    if (copPerUsd is! num || eurPerUsd is! num) return null;
    if (copPerUsd <= 0 || eurPerUsd <= 0) return null;
    return {
      'USD': copPerUsd.toDouble(),
      'EUR': copPerUsd / eurPerUsd,
    };
  }

  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.contains(code)) return;
    if (_soloPesos) return;
    if (code == _currency) return;

    _currency = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyCurrency, code);
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
    _ratesFetchedAt = null;
    await prefs.remove(_prefsKeyRatesFetchedAt);

    // Vuelve a la tasa del día en vez de quedarse con los valores fijos.
    await refreshRates(force: true);
  }

  /// Convierte [amountCop] (siempre el monto real, en pesos) a la moneda
  /// elegida y lo formatea para mostrar. Puramente de presentación.
  String format(num amountCop) {
    final code = currency;
    if (code == 'COP') return formatCOP(amountCop);

    final converted = amountCop / rateFor(code);
    final symbol = code == 'USD' ? 'US\$' : '€';
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
