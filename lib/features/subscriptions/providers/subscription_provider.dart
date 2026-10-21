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
  EstadoSuscripcion _estado = EstadoSuscripcion(const []);
  bool _isLoading = false;
  bool _disposed = false;

  /// HU-23: periodos vigentes, cancelación y plan programado.
  EstadoSuscripcion get estado => _estado;

  /// El periodo vigente que termina más tarde (hasta cuándo es Premium).
  Suscripcion? get suscripcion => _estado.ultimo;
  bool get isPremium => _estado.isActive;

  /// Mientras es `true` todavía no se sabe si es Premium — una vista
  /// restringida debe mostrar un loader, no la invitación a suscribirse.
  bool get isLoading => _isLoading;
  int? get usuarioId => _usuarioId;

  /// Lo llama `ChangeNotifierProxyProvider` cada vez que cambia la sesión.
  void updateAuth(AppAuthProvider auth) {
    final usuarioId = auth.isAuthenticated ? auth.usuario?.id : null;
    if (usuarioId == _usuarioId) return;
    _usuarioId = usuarioId;
    _estado = EstadoSuscripcion(const []);
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
      final periodos = await _repository.fetchPeriodosVigentes(usuarioId);
      if (_disposed || usuarioId != _usuarioId) return;
      _estado = EstadoSuscripcion(periodos);
    } catch (e, st) {
      debugPrint('SubscriptionProvider.refresh error: $e\n$st');
    } finally {
      if (!_disposed && usuarioId == _usuarioId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// HU-23 CA4: cancela la renovación; el acceso sigue hasta el final
  /// del periodo pagado. Lanza [PaymentException] si falla.
  Future<void> cancelar() => _gestionar(AccionSuscripcion.cancelar);

  Future<void> reactivar() => _gestionar(AccionSuscripcion.reactivar);

  /// HU-23 CA3: deja [plan] programado para el siguiente periodo (pasar
  /// el plan actual quita el cambio programado).
  Future<void> programarPlan(PlanSuscripcion plan) =>
      _gestionar(AccionSuscripcion.programarPlan, plan: plan);

  Future<void> _gestionar(AccionSuscripcion accion, {PlanSuscripcion? plan}) async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return;
    final periodos = await _repository.gestionarSuscripcion(
      usuarioId: usuarioId,
      accion: accion,
      plan: plan,
    );
    if (_disposed || usuarioId != _usuarioId) return;
    _estado = EstadoSuscripcion(periodos);
    notifyListeners();
  }

  Future<List<PagoResumen>> fetchPagos() async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return const [];
    return _repository.fetchPagos(usuarioId);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
