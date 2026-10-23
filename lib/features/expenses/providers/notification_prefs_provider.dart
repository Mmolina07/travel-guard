import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de alertas y recordatorios de HU-11, guardadas en el
/// dispositivo (no necesitan sincronizarse entre equipos).
///
/// - [alertsEnabled] (CA4): con `false` no se muestra ninguna alerta ni
///   recordatorio, pero los gastos se siguen registrando igual.
/// - [reminderHours] (CA5): horas sin registrar gastos antes de
///   preguntar "¿Tuviste gastos hoy...?" (2, 4 o 6).
/// - [dailySummary] (CA6): resumen de las 11 PM — se activa a mano.
/// - [tripReminder] (CA9): aviso 3 días y 1 día antes de un viaje.
/// - [checklistReminder] (HU-26): aviso de pendientes sin marcar 3 días
///   antes, 1 día antes y la mañana de salida.
/// - [browserNotifications]: además de dentro de la app, como
///   notificación del navegador (requiere su permiso).
class NotificationPrefsProvider extends ChangeNotifier {
  NotificationPrefsProvider() {
    _load();
  }

  static const reminderHourOptions = [2, 4, 6];

  static const _kAlerts = 'hu11_alerts_enabled';
  static const _kReminderHours = 'hu11_reminder_hours';
  static const _kDailySummary = 'hu11_daily_summary';
  static const _kTripReminder = 'hu11_trip_reminder';
  static const _kChecklistReminder = 'hu26_checklist_reminder';
  static const _kBrowser = 'hu11_browser_notifications';

  static const _defaultAlerts = true;
  static const _defaultReminderHours = 4;
  static const _defaultDailySummary = false;
  static const _defaultTripReminder = true;
  static const _defaultChecklistReminder = true;
  static const _defaultBrowser = false;

  bool _alertsEnabled = _defaultAlerts;
  int _reminderHours = _defaultReminderHours;
  bool _dailySummary = _defaultDailySummary;
  bool _tripReminder = _defaultTripReminder;
  bool _checklistReminder = _defaultChecklistReminder;
  bool _browserNotifications = _defaultBrowser;
  bool _disposed = false;

  bool get alertsEnabled => _alertsEnabled;
  int get reminderHours => _reminderHours;
  bool get dailySummary => _dailySummary;
  bool get tripReminder => _tripReminder;
  bool get checklistReminder => _checklistReminder;
  bool get browserNotifications => _browserNotifications;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _alertsEnabled = prefs.getBool(_kAlerts) ?? _defaultAlerts;
      final hours = prefs.getInt(_kReminderHours) ?? _defaultReminderHours;
      _reminderHours = reminderHourOptions.contains(hours) ? hours : _defaultReminderHours;
      _dailySummary = prefs.getBool(_kDailySummary) ?? _defaultDailySummary;
      _tripReminder = prefs.getBool(_kTripReminder) ?? _defaultTripReminder;
      _checklistReminder = prefs.getBool(_kChecklistReminder) ?? _defaultChecklistReminder;
      _browserNotifications = prefs.getBool(_kBrowser) ?? _defaultBrowser;
      if (!_disposed) notifyListeners();
    } catch (e, st) {
      debugPrint('NotificationPrefsProvider._load error: $e\n$st');
    }
  }

  Future<void> setAlertsEnabled(bool value) => _save(() => _alertsEnabled = value, (p) => p.setBool(_kAlerts, value));

  Future<void> setReminderHours(int value) {
    assert(reminderHourOptions.contains(value));
    return _save(() => _reminderHours = value, (p) => p.setInt(_kReminderHours, value));
  }

  Future<void> setDailySummary(bool value) =>
      _save(() => _dailySummary = value, (p) => p.setBool(_kDailySummary, value));

  Future<void> setTripReminder(bool value) =>
      _save(() => _tripReminder = value, (p) => p.setBool(_kTripReminder, value));

  Future<void> setChecklistReminder(bool value) =>
      _save(() => _checklistReminder = value, (p) => p.setBool(_kChecklistReminder, value));

  Future<void> setBrowserNotifications(bool value) =>
      _save(() => _browserNotifications = value, (p) => p.setBool(_kBrowser, value));

  /// "Restaurar valores predeterminados" de Configuración.
  Future<void> resetToDefault() async {
    _alertsEnabled = _defaultAlerts;
    _reminderHours = _defaultReminderHours;
    _dailySummary = _defaultDailySummary;
    _tripReminder = _defaultTripReminder;
    _checklistReminder = _defaultChecklistReminder;
    _browserNotifications = _defaultBrowser;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_kAlerts),
        prefs.remove(_kReminderHours),
        prefs.remove(_kDailySummary),
        prefs.remove(_kTripReminder),
        prefs.remove(_kChecklistReminder),
        prefs.remove(_kBrowser),
      ]);
    } catch (e, st) {
      debugPrint('NotificationPrefsProvider.resetToDefault error: $e\n$st');
    }
  }

  /// Aplica el cambio en memoria al instante (la UI no espera al disco).
  Future<void> _save(void Function() apply, Future<bool> Function(SharedPreferences) persist) async {
    apply();
    notifyListeners();
    try {
      await persist(await SharedPreferences.getInstance());
    } catch (e, st) {
      debugPrint('NotificationPrefsProvider._save error: $e\n$st');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
