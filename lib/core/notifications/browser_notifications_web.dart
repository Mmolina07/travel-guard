import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

import 'browser_notifications.dart';

@JS('Notification')
extension type _Notification._(JSObject _) implements JSObject {
  external factory _Notification(String title, _NotificationOptions options);

  @JS('permission')
  external static String get permission;

  @JS('requestPermission')
  external static JSPromise<JSString> requestPermission();

  external set onclick(JSFunction handler);
  external void close();
}

extension type _NotificationOptions._(JSObject _) implements JSObject {
  external factory _NotificationOptions({String body, String icon, String tag});
}

@JS('window.focus')
external void _focusWindow();

bool get _supported => globalContext.has('Notification');

BrowserNotificationPermission _parse(String value) => switch (value) {
      'granted' => BrowserNotificationPermission.granted,
      'denied' => BrowserNotificationPermission.denied,
      _ => BrowserNotificationPermission.notAsked,
    };

BrowserNotificationPermission permission() {
  if (!_supported) return BrowserNotificationPermission.unsupported;
  return _parse(_Notification.permission);
}

Future<BrowserNotificationPermission> requestPermission() async {
  if (!_supported) return BrowserNotificationPermission.unsupported;
  try {
    final result = await _Notification.requestPermission().toDart;
    return _parse(result.toDart);
  } catch (e) {
    debugPrint('BrowserNotifications.requestPermission error: $e');
    return permission();
  }
}

void show({required String title, required String body, String? tag, void Function()? onClick}) {
  if (!_supported) return;
  try {
    final notification = _Notification(
      title,
      _NotificationOptions(body: body, icon: 'icons/Icon-192.png', tag: tag ?? ''),
    );
    notification.onclick = (JSAny _) {
      _focusWindow();
      onClick?.call();
      notification.close();
    }.toJS;
  } catch (e) {
    debugPrint('BrowserNotifications.show error: $e');
  }
}
