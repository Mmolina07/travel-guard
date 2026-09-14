import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../data/auth_exception.dart';
import '../data/comercio_repository.dart';
import '../data/email_auth_service.dart';
import '../data/google_auth_service.dart';
import '../data/models/comercio_model.dart';
import '../data/models/tourist_model.dart';
import '../data/models/usuario_model.dart';
import '../data/tourist_repository.dart';
import '../data/usuarios_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Provider de sesión global para turista y comercio (TG-92, TG-97,
/// TG-102, TG-123, TG-124).
///
/// Responsabilidades:
/// - Registro/login con email+contraseña y con Google, usando Firebase
///   Authentication como backend de autenticación.
/// - Mantener y exponer el estado de sesión actual (`ChangeNotifier` +
///   `authStateChanges` de Firebase) para toda la app (p.ej. el nombre
///   dinámico en los home de turista/comercio).
/// - Sincronizar `usuarios` + `turistas`/`comercios` en Supabase (TG-92).
///
/// No depende de ninguna pantalla existente: las pantallas de
/// presentación consumen esto con `context.read/watch<AppAuthProvider>()`
/// sin que este archivo modifique su maquetación.
class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider({
    GoogleAuthService? googleAuthService,
    EmailAuthService? emailAuthService,
    UsuariosRepository? usuariosRepository,
    TouristRepository? touristRepository,
    ComercioRepository? comercioRepository,
  })  : _googleAuth = googleAuthService ?? GoogleAuthService(),
        _emailAuth = emailAuthService ?? EmailAuthService(),
        _usuarios = usuariosRepository ?? UsuariosRepository(),
        _turistas = touristRepository ?? TouristRepository(),
        _comercios = comercioRepository ?? ComercioRepository() {
    _authSub = _googleAuth.authStateChanges().listen(_onAuthChanged);
  }

  final GoogleAuthService _googleAuth;
  final EmailAuthService _emailAuth;
  final UsuariosRepository _usuarios;
  final TouristRepository _turistas;
  final ComercioRepository _comercios;
  late final StreamSubscription<fb.User?> _authSub;

  AuthStatus _status = AuthStatus.unknown;
  fb.User? _firebaseUser;
  UsuarioModel? _usuario;
  TouristModel? _tourist;
  ComercioModel? _comercio;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  fb.User? get firebaseUser => _firebaseUser;
  UsuarioModel? get usuario => _usuario;
  TouristModel? get tourist => _tourist;
  ComercioModel? get comercio => _comercio;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Nombre a mostrar en la UI (p.ej. "¡Hola, {displayName}!") sin depender
  /// de ningún valor hardcodeado en las pantallas.
  String get displayName {
    if (_tourist != null) return _tourist!.nombreCompleto;
    if (_comercio != null) return _comercio!.nombreComercio;
    final email = _usuario?.email ?? _firebaseUser?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Usuario';
  }

  Future<void> _onAuthChanged(fb.User? user) async {
    _firebaseUser = user;
    _status =
        user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    if (user != null) {
      try {
        final usuario = await _resolveUsuario(user);
        await _loadProfile(usuario);
      } catch (e, st) {
        // La sesión de Firebase sigue siendo válida aunque falle Supabase;
        // se reintenta la sincronización en el próximo login/registro.
        debugPrint('AppAuthProvider._onAuthChanged Supabase error: $e\n$st');
      }
    } else {
      _usuario = null;
      _tourist = null;
      _comercio = null;
    }
    notifyListeners();
  }

  Future<UsuarioModel?> _resolveUsuario(fb.User user) {
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    if (isGoogle) return _usuarios.findByGoogleId(user.uid);
    return _usuarios.findByEmail(user.email ?? '');
  }

  Future<void> _loadProfile(UsuarioModel? usuario) async {
    _usuario = usuario;
    if (usuario == null) {
      _tourist = null;
      _comercio = null;
      return;
    }
    if (usuario.tipoUsuario == 'comercio') {
      _comercio = await _comercios.find(usuario.id);
      _tourist = null;
    } else {
      _tourist = await _turistas.find(usuario.id);
      _comercio = null;
    }
  }

  /// Escenarios 1-4 de HU-01: registro de turista con email/contraseña.
  Future<bool> registerTourist({
    required String nombre,
    required String email,
    required String password,
  }) {
    return _runAuthAction(() async {
      final user = await _emailAuth.register(
        email: email,
        password: password,
        displayName: nombre,
      );
      final usuario =
          await _usuarios.createLocal(email: email, tipoUsuario: 'turista');
      final tourist = await _turistas.createProfile(
        usuarioId: usuario.id,
        displayName: nombre,
      );
      _usuario = usuario;
      _tourist = tourist;
      _comercio = null;
      _firebaseUser = user;
    });
  }

  /// Registro de comercio (HU-02) con email/contraseña.
  Future<bool> registerComercio({
    required String nombreComercio,
    required String nit,
    required String direccion,
    required String telefono,
    required String? sede,
    required String email,
    required String password,
  }) {
    return _runAuthAction(() async {
      final user = await _emailAuth.register(
        email: email,
        password: password,
        displayName: nombreComercio,
      );
      final usuario =
          await _usuarios.createLocal(email: email, tipoUsuario: 'comercio');
      final comercio = await _comercios.createProfile(
        usuarioId: usuario.id,
        nit: nit,
        nombreComercio: nombreComercio,
        direccion: direccion,
        telefonoContacto: telefono,
        sede: sede,
      );
      _usuario = usuario;
      _comercio = comercio;
      _tourist = null;
      _firebaseUser = user;
    });
  }

  /// Login con email/contraseña (HU-03), validando que el rol de la
  /// cuenta coincida con el botón que el usuario presionó.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required String expectedTipoUsuario,
  }) {
    return _runAuthAction(() async {
      final user =
          await _emailAuth.signIn(email: email, password: password);
      final usuario = await _usuarios.findByEmail(email);
      if (usuario == null) {
        throw const AuthException('No existe una cuenta con este correo.');
      }
      if (usuario.tipoUsuario != expectedTipoUsuario) {
        throw AuthException(
          'Esta cuenta no está registrada como $expectedTipoUsuario.',
        );
      }
      final updated = await _usuarios.touchLastLogin(usuario.id);
      await _loadProfile(updated);
      _firebaseUser = user;
    });
  }

  /// Escenario 5 de HU-01 (TG-123/TG-124): registro/login con Google.
  /// Solo aplica a turistas: el perfil de comercio exige NIT, dirección y
  /// teléfono, datos que Google no provee.
  ///
  /// Retorna `false` tanto si el usuario cancela el flujo como si ocurre
  /// un error (en el primer caso [errorMessage] queda en `null`).
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _googleAuth.signInWithGoogle();
      if (user == null) return false; // Cancelado por el usuario.

      var usuario = await _usuarios.findByGoogleId(user.uid);
      if (usuario == null) {
        usuario = await _usuarios.createGoogle(
          googleId: user.uid,
          email: user.email ?? '',
          tipoUsuario: 'turista',
        );
      } else {
        usuario = await _usuarios.touchLastLogin(usuario.id);
      }

      var tourist = await _turistas.find(usuario.id);
      tourist ??= await _turistas.createProfile(
        usuarioId: usuario.id,
        displayName: user.displayName,
      );

      _usuario = usuario;
      _tourist = tourist;
      _comercio = null;
      _firebaseUser = user;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      debugPrint('AppAuthProvider.signInWithGoogle error: $e\n$st');
      _errorMessage = 'No se pudo completar el registro con Google.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Paso 1 del registro de comercio con Google (TG-123/TG-124): solo
  /// autentica con Firebase y retorna el usuario, sin tocar Supabase
  /// todavía (el perfil de comercio necesita datos que Google no provee
  /// — NIT, dirección, teléfono — y se completan con el formulario).
  ///
  /// Retorna `null` tanto si el usuario cancela como si ocurre un error
  /// (en el primer caso [errorMessage] queda en `null`).
  Future<fb.User?> beginGoogleSignIn() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _googleAuth.signInWithGoogle();
      if (user != null) _firebaseUser = user;
      return user;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e, st) {
      debugPrint('AppAuthProvider.beginGoogleSignIn error: $e\n$st');
      _errorMessage = 'No se pudo completar el registro con Google.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Paso 2: crea `usuarios` (proveedor_auth='google') + `comercios` para
  /// el usuario de Firebase ya autenticado con [beginGoogleSignIn].
  Future<bool> completeComercioGoogleRegistration({
    required String nombreComercio,
    required String nit,
    required String direccion,
    required String telefono,
    String? sede,
  }) {
    final user = _firebaseUser;
    if (user == null) {
      _errorMessage = 'Primero inicia sesión con Google.';
      notifyListeners();
      return Future.value(false);
    }
    return _runAuthAction(() async {
      var usuario = await _usuarios.findByGoogleId(user.uid);
      usuario ??= await _usuarios.createGoogle(
        googleId: user.uid,
        email: user.email ?? '',
        tipoUsuario: 'comercio',
      );
      final comercio = await _comercios.createProfile(
        usuarioId: usuario.id,
        nit: nit,
        nombreComercio: nombreComercio,
        direccion: direccion,
        telefonoContacto: telefono,
        sede: sede,
      );
      _usuario = usuario;
      _comercio = comercio;
      _tourist = null;
    });
  }

  Future<void> signOut() async {
    await _googleAuth.signOut();
  }

  /// Centraliza loading + manejo de errores para las acciones de auth.
  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      debugPrint('AppAuthProvider._runAuthAction error: $e\n$st');
      _errorMessage = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
