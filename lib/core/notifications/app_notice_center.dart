import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tono de una notificación dentro de la app: decide color e ícono.
enum AppNoticeTone {
  /// Recordatorios y resúmenes (petróleo).
  info,

  /// 75% del presupuesto diario (HU-11 CA1): amarilla.
  warning,

  /// 85% del presupuesto diario (HU-11 CA7).
  nearLimit,

  /// 100% del presupuesto diario (HU-11 CA2): roja.
  danger,
}

/// Notificación que se muestra encima de cualquier pantalla (HU-11):
/// por ahora las notificaciones son solo dentro de la app.
class AppNotice {
  AppNotice({
    required this.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.message,
    this.route,
    this.routeExtra,
    this.actionLabel,
  });

  /// Identifica el aviso para no repetirlo mientras sigue en pantalla.
  final String key;
  final AppNoticeTone tone;
  final IconData icon;
  final String title;
  final String message;

  /// A dónde lleva al tocarla (p. ej. `/viajes/12`).
  final String? route;
  final Object? routeExtra;
  final String? actionLabel;
}

/// Cola de [AppNotice] visibles; la pinta `AppNoticeOverlay`.
class AppNoticeCenter extends ChangeNotifier {
  static const maxVisible = 3;

  final List<AppNotice> _notices = [];

  /// Navegación para abrir el destino de un aviso desde fuera del árbol
  /// (p. ej. al tocar la notificación del navegador). La asigna
  /// `AppNoticeOverlay`, que tiene el router.
  void Function(String route, Object? extra)? navigate;

  void open(AppNotice notice) {
    dismiss(notice.key);
    final route = notice.route;
    if (route != null) navigate?.call(route, notice.routeExtra);
  }

  List<AppNotice> get notices => List.unmodifiable(_notices);

  void push(AppNotice notice) {
    _notices.removeWhere((n) => n.key == notice.key);
    _notices.insert(0, notice);
    if (_notices.length > maxVisible) _notices.removeRange(maxVisible, _notices.length);
    notifyListeners();
  }

  void dismiss(String key) {
    final before = _notices.length;
    _notices.removeWhere((n) => n.key == key);
    if (_notices.length != before) notifyListeners();
  }

  void clear() {
    if (_notices.isEmpty) return;
    _notices.clear();
    notifyListeners();
  }
}
