import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, User;

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
/// La app usa **dos backends de sesión a propósito**:
/// - Email/contraseña -> Firebase Authentication (`EmailAuthService`).
/// - Google -> autenticación nativa de Supabase (`GoogleAuthService`,
///   `signInWithIdToken`), para tener una sesión real de Supabase Auth
///   con Google en vez de depender de Firebase para ese proveedor.
///
/// Este provider escucha ambos streams y los combina en un solo estado
/// de sesión + perfil (`usuarios`/`turistas`/`comercios`), sin que las
/// pantallas necesiten saber cuál de los dos autenticó al usuario.
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
    _firebaseAuthSub =
        _emailAuth.authStateChanges().listen(_onFirebaseAuthChanged);
    _googleAuthSub = _googleAuth.authStateChanges().listen(_onGoogleAuthChanged);
  }

  final GoogleAuthService _googleAuth;
  final EmailAuthService _emailAuth;
  final UsuariosRepository _usuarios;
  final TouristRepository _turistas;
  final ComercioRepository _comercios;
  late final StreamSubscription<fb.User?> _firebaseAuthSub;
  late final StreamSubscription<User?> _googleAuthSub;

  AuthStatus _status = AuthStatus.unknown;
  fb.User? _firebaseUser; // sesión de email/contraseña (Firebase).
  User? _googleUser; // sesión de Google (Supabase Auth nativo).
  UsuarioModel? _usuario;
  TouristModel? _tourist;
  ComercioModel? _comercio;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  fb.User? get firebaseUser => _firebaseUser;
  User? get googleUser => _googleUser;
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
    final email = _usuario?.email ?? _firebaseUser?.email ?? _googleUser?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Usuario';
  }

  Future<void> _onFirebaseAuthChanged(fb.User? user) async {
    _firebaseUser = user;
    await _syncSessionState(
      hasSession: user != null || _googleUser != null,
      resolveUsuario: user == null
          ? null
          : () => _usuarios.findByEmail(user.email ?? ''),
    );
  }

  Future<void> _onGoogleAuthChanged(User? user) async {
    _googleUser = user;
    await _syncSessionState(
      hasSession: user != null || _firebaseUser != null,
      resolveUsuario:
          user == null ? null : () => _usuarios.findByGoogleId(user.id),
    );
  }

  Future<void> _syncSessionState({
    required bool hasSession,
    Future<UsuarioModel?> Function()? resolveUsuario,
  }) async {
    _status =
        hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (resolveUsuario != null) {
      try {
        await _loadProfile(await resolveUsuario());
      } catch (e, st) {
        // La sesión sigue siendo válida aunque falle Supabase; se
        // reintenta la sincronización en el próximo login/registro.
        debugPrint('AppAuthProvider._syncSessionState error: $e\n$st');
      }
    } else if (!hasSession) {
      _usuario = null;
      _tourist = null;
      _comercio = null;
    }
    notifyListeners();
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

  /// Busca el `usuarios` enlazado a esta cuenta de Google (por
  /// `google_id`); si no existe, intenta enlazarlo por `email` (cuenta
  /// que se había registrado con Google cuando ese flujo pasaba por
  /// Firebase, con un `google_id` distinto) antes de crear uno nuevo.
  Future<UsuarioModel> _findOrLinkGoogleUsuario({
    required String googleId,
    required String email,
    required String tipoUsuario,
  }) async {
    final existingByGoogleId = await _usuarios.findByGoogleId(googleId);
    if (existingByGoogleId != null) return existingByGoogleId;

    final existingByEmail = await _usuarios.findByEmail(email);
    if (existingByEmail != null) {
      return _usuarios.updateGoogleId(id: existingByEmail.id, googleId: googleId);
    }

    return _usuarios.createGoogle(
      googleId: googleId,
      email: email,
      tipoUsuario: tipoUsuario,
    );
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
    double? latitud,
    double? longitud,
  }) {
    return _runAuthAction(() async {
      await _checkComercioDuplicates(nit: nit, email: email);

      final user = await _emailAuth.register(
        email: email,
        password: password,
        displayName: nombreComercio,
      );
      try {
        final usuario = await _usuarios.createLocal(
          email: email,
          tipoUsuario: 'comercio',
        );
        final comercio = await _comercios.createProfile(
          usuarioId: usuario.id,
          nit: nit,
          nombreComercio: nombreComercio,
          direccion: direccion,
          telefonoContacto: telefono,
          sede: sede,
          latitud: latitud,
          longitud: longitud,
        );
        _usuario = usuario;
        _comercio = comercio;
        _tourist = null;
        _firebaseUser = user;
      } on PostgrestException catch (e) {
        _rethrowComercioConstraintViolation(e);
      }
    });
  }

  /// Escenarios 2 y 4 de HU-02: valida de forma anticipada que el email y
  /// el NIT no estén ya registrados, con el mensaje exacto de cada caso.
  Future<void> _checkComercioDuplicates({
    required String nit,
    required String email,
  }) async {
    if (await _comercios.findByNit(nit) != null) {
      throw const AuthException('NIT inválido o ya registrado');
    }
    if (await _usuarios.findByEmail(email) != null) {
      throw const AuthException('Email inválido o ya registrado');
    }
  }

  /// Traduce violaciones de unicidad de Postgres (condición de carrera con
  /// las validaciones anticipadas) a los mensajes de HU-02.
  Never _rethrowComercioConstraintViolation(PostgrestException e) {
    final detail = '${e.message} ${e.details ?? ''}'.toLowerCase();
    if (detail.contains('nit')) {
      throw const AuthException('NIT inválido o ya registrado');
    }
    if (detail.contains('email')) {
      throw const AuthException('Email inválido o ya registrado');
    }
    throw e;
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

  /// Escenario 5 de HU-01 (TG-123/TG-124): registro/login con Google,
  /// vía Supabase Auth nativo. Solo aplica a turistas: el perfil de
  /// comercio exige NIT, dirección y teléfono, datos que Google no provee.
  ///
  /// Retorna `false` tanto si el usuario cancela el flujo como si ocurre
  /// un error (en el primer caso [errorMessage] queda en `null`).
  ///
  /// [context] es obligatorio en Web (el SDK de Google exige mostrar su
  /// propio botón real ahí, ver [GoogleAuthService]); en otras
  /// plataformas se ignora.
  Future<bool> signInWithGoogle([BuildContext? context]) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _googleAuth.signInWithGoogle(context: context);
      if (user == null) return false; // Cancelado por el usuario.

      var usuario = await _findOrLinkGoogleUsuario(
        googleId: user.id,
        email: user.email ?? '',
        tipoUsuario: 'turista',
      );
      usuario = await _usuarios.touchLastLogin(usuario.id);

      var tourist = await _turistas.find(usuario.id);
      tourist ??= await _turistas.createProfile(
        usuarioId: usuario.id,
        displayName: _googleDisplayName(user),
      );

      _usuario = usuario;
      _tourist = tourist;
      _comercio = null;
      _googleUser = user;
      _status = AuthStatus.authenticated;
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
  /// autentica con Supabase y retorna el usuario, sin crear el perfil
  /// todavía (el perfil de comercio necesita datos que Google no provee
  /// — NIT, dirección, teléfono — y se completan con el formulario).
  ///
  /// Retorna `null` tanto si el usuario cancela como si ocurre un error
  /// (en el primer caso [errorMessage] queda en `null`).
  Future<User?> beginGoogleSignIn([BuildContext? context]) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _googleAuth.signInWithGoogle(context: context);
      if (user != null) _googleUser = user;
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

  String? _googleDisplayName(User user) {
    final metadata = user.userMetadata;
    return metadata?['full_name'] as String? ?? metadata?['name'] as String?;
  }

  /// Paso 2: crea `usuarios` (proveedor_auth='google') + `comercios` para
  /// el usuario ya autenticado con [beginGoogleSignIn].
  Future<bool> completeComercioGoogleRegistration({
    required String nombreComercio,
    required String nit,
    required String direccion,
    required String telefono,
    String? sede,
    double? latitud,
    double? longitud,
  }) {
    final user = _googleUser;
    if (user == null) {
      _errorMessage = 'Primero inicia sesión con Google.';
      notifyListeners();
      return Future.value(false);
    }
    return _runAuthAction(() async {
      await _checkComercioDuplicates(nit: nit, email: user.email ?? '');

      try {
        final usuario = await _findOrLinkGoogleUsuario(
          googleId: user.id,
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
          latitud: latitud,
          longitud: longitud,
        );
        _usuario = usuario;
        _comercio = comercio;
        _tourist = null;
      } on PostgrestException catch (e) {
        _rethrowComercioConstraintViolation(e);
      }
    });
  }

  Future<void> signOut() async {
    await Future.wait([
      _emailAuth.signOut(),
      _googleAuth.signOut(),
    ]);
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
    _firebaseAuthSub.cancel();
    _googleAuthSub.cancel();
    super.dispose();
  }
}
