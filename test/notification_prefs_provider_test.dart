import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelguard/features/expenses/providers/notification_prefs_provider.dart';

Future<NotificationPrefsProvider> _loaded() async {
  final p = NotificationPrefsProvider();
  await Future<void>.delayed(Duration.zero);
  return p;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('valores por defecto (HU-11)', () async {
    final p = await _loaded();
    expect(p.alertsEnabled, isTrue);
    expect(p.reminderHours, 4);
    expect(p.dailySummary, isFalse);
    expect(p.tripReminder, isTrue);
  });

  test('"Mostrar alertas" se guarda y se recupera (CA4)', () async {
    final p = await _loaded();
    await p.setAlertsEnabled(false);
    final again = await _loaded();
    expect(again.alertsEnabled, isFalse);
  });

  test('restaurar valores predeterminados', () async {
    final p = await _loaded();
    await p.setAlertsEnabled(false);
    await p.setReminderHours(6);
    await p.resetToDefault();
    final again = await _loaded();
    expect(again.alertsEnabled, isTrue);
    expect(again.reminderHours, 4);
  });
}
