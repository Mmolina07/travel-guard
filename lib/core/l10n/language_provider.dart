import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider global de idioma (ES/EN) para la HU de configuración regional.
///
/// Persiste la elección del usuario en `SharedPreferences` para que la
/// app recuerde el idioma entre sesiones.
class LanguageProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_code';
  static const supportedLocales = [Locale('es'), Locale('en')];

  Locale _locale = supportedLocales.first;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);
    if (savedCode == null) return;

    final match = supportedLocales.firstWhere(
      (candidate) => candidate.languageCode == savedCode,
      orElse: () => _locale,
    );
    if (match.languageCode != _locale.languageCode) {
      _locale = match;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    if (locale.languageCode == _locale.languageCode) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }

  Future<void> resetToDefault() => setLocale(supportedLocales.first);
}
