import 'browser_notifications_stub.dart'
    if (dart.library.js_interop) 'browser_notifications_web.dart' as impl;

/// Permiso del navegador para notificaciones del sistema.
enum BrowserNotificationPermission { granted, denied, notAsked, unsupported }

/// Notificaciones del sistema en web (`window.Notification`) — complemento
/// de las notificaciones dentro de la app (HU-11). Solo funcionan con la
/// pestaña abierta (no hay servidor de push). Fuera de web no hacen nada.
abstract final class BrowserNotifications {
  static BrowserNotificationPermission get permission => impl.permission();

  /// Debe llamarse directo desde un gesto del usuario (un toque): el
  /// navegador ignora pedidos de permiso que no vengan de uno.
  static Future<BrowserNotificationPermission> requestPermission() => impl.requestPermission();

  static void show({
    required String title,
    required String body,
    String? tag,
    void Function()? onClick,
  }) {
    if (permission != BrowserNotificationPermission.granted) return;
    impl.show(title: title, body: body, tag: tag, onClick: onClick);
  }
}
