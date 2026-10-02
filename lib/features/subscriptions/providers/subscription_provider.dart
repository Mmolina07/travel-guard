import 'package:flutter/foundation.dart';

import '../../auth/providers/app_auth_provider.dart';
import '../data/models/suscripcion_model.dart';
import '../data/subscription_repository.dart';

/// Si el usuario actual es Premium (HU-22). Lo usa la pantalla de
/// planes para mostrar el plan vigente, y HU-24 (TG-298) para decidir
/// quién puede ver las promociones exclusivas.
class SubscriptionProvider extends ChangeNotifier {
  SubscriptionProvider({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository();

  final SubscriptionRepository _repository;

  int? _usuarioId;
  Suscripcion? _suscripcion;
  bool _isLoading = false;
  bool _disposed = false;

  Suscripcion? get suscripcion => _suscripcion;
  bool get isPremium => _suscripcion?.isActive ?? false;

  /// Mientras es `true` todavía no se sabe si es Premium — una vista
  /// restringida debe mostrar un loader, no la invitación a suscribirse.
  bool get isLoading => _isLoading;
  int? get usuarioId => _usuarioId;

  /// Lo llama `ChangeNotifierProxyProvider` cada vez que cambia la sesión.
  void updateAuth(AppAuthProvider auth) {
    final usuarioId = auth.isAuthenticated ? auth.usuario?.id : null;
    if (usuarioId == _usuarioId) return;
    _usuarioId = usuarioId;
    _suscripcion = null;
    _isLoading = usuarioId != null;
    // Esto corre dentro del `update` del ProxyProvider (en pleno build):
    // notificar ahí mismo revienta, así que se difiere un microtask.
    Future.microtask(() {
      if (_disposed || usuarioId != _usuarioId) return;
      if (usuarioId == null) {
        notifyListeners();
      } else {
        refresh();
      }
    });
  }

  Future<void> refresh() async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final suscripcion = await _repository.fetchSuscripcionActiva(usuarioId);
      if (_disposed || usuarioId != _usuarioId) return;
      _suscripcion = suscripcion;
    } catch (e, st) {
      debugPrint('SubscriptionProvider.refresh error: $e\n$st');
    } finally {
      if (!_disposed && usuarioId == _usuarioId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
