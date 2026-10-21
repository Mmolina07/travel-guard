import 'browser_notifications.dart';

BrowserNotificationPermission permission() => BrowserNotificationPermission.unsupported;

Future<BrowserNotificationPermission> requestPermission() async =>
    BrowserNotificationPermission.unsupported;

void show({required String title, required String body, String? tag, void Function()? onClick}) {}
