import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthApiException, OAuthProvider, SupabaseClient, User;

import '../../../core/network/supabase_client.dart';
import 'auth_exception.dart';
import 'web_google_button.dart';

/// Autenticación con Google (TG-97/TG-123/TG-124) usando la
/// autenticación nativa de Supabase (`signInWithIdToken`) en vez de
/// Firebase: `google_sign_in` solo se usa para el selector de cuenta y
/// obtener el ID token de Google; quien valida ese token y crea la
/// sesión real es Supabase Auth.
///
/// **Dos flujos distintos según la plataforma** (`GoogleSignIn.
/// supportsAuthenticate()`):
/// - Android/iOS/desktop: `authenticate()` funciona directo, como
///   antes — dispara el selector de cuenta nativo por código.
/// - **Web**: `authenticate()` lanza `UnimplementedError`. Desde
///   `google_sign_in` v7, Google exige que el usuario haga click en un
///   botón renderizado por su propio SDK (Google Identity Services) —
///   es una medida anti-bot, no se puede evitar por código. Por eso,
///   en web, `signInWithGoogle` abre un bottom sheet con ese botón
///   real (`renderGoogleButton()`, ver `web_google_button.dart`) y
///   espera a que `authenticationEvents` confirme el login; el sheet
///   se cierra solo apenas el usuario completa el flujo con Google.
///   El botón "Iniciar sesión con Google" de cada pantalla no cambia
///   de apariencia — solo dispara este sheet en vez de `authenticate()`
///   directamente.
///
/// El registro/login por email+contraseña sigue en Firebase
/// (`EmailAuthService`) — son dos backends de sesión distintos a
/// propósito, cada uno responsable de un método de acceso.
class GoogleAuthService {
  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    SupabaseClient? client,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _client = client ?? SupabaseConfig.client;

  final GoogleSignIn _googleSignIn;
  final SupabaseClient _client;
  Future<void>? _initFuture;

  // "Cliente web 1" en Google Cloud Console: creado a mano para
  // Supabase (tiene su Client Secret y el callback de Supabase
  // registrado). No es un secreto: los client id de OAuth son públicos
  // por diseño. `serverClientId` es el que debe coincidir con el
  // registrado en Supabase Dashboard > Authentication > Providers >
  // Google, para que el `aud` del idToken sea el que Supabase espera.
  static const String _webClientId =
      '522265539593-95ivihjvu0gcrda27h6knu4obdp5sntn.apps.googleusercontent.com';

  Future<void> _ensureInitialized() {
    return _initFuture ??= _googleSignIn.initialize(
      // En Web, `clientId` es el que google_sign_in_web usa para
      // inicializar Google Identity Services (y por lo tanto, el que
      // determina qué "Authorized JavaScript origins" se validan).
      // `serverClientId` es el que debe coincidir con el registrado en
      // Supabase (Authentication > Providers > Google) para que el
      // `aud` del idToken sea el que Supabase espera. Acá son el mismo
      // cliente, así que van los dos con el mismo valor.
      clientId: _webClientId,
      serverClientId: _webClientId,
    );
  }

  /// Ejecuta el flujo "Registrarse/Iniciar sesión con Google" (Escenario 5
  /// de HU-01) y retorna el usuario autenticado en Supabase.
  ///
  /// Retorna `null` si el usuario cancela el flujo (no es un error).
  ///
  /// [context] es requerido en Web (para mostrar el bottom sheet con el
  /// botón real de Google); en otras plataformas se ignora.
  ///
  /// Requiere que en Supabase Dashboard → Authentication → Providers →
  /// Google esté habilitado con el Client ID de Web autorizado.
  Future<User?> signInWithGoogle({BuildContext? context}) async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount? googleAccount;
      if (_googleSignIn.supportsAuthenticate()) {
        googleAccount = await _googleSignIn.authenticate();
      } else {
        if (context == null) {
          throw const AuthException(
            'No se pudo iniciar el flujo de Google en esta plataforma.',
          );
        }
        googleAccount = await _authenticateViaWebButton(context);
      }
      if (googleAccount == null) return null; // Cancelado por el usuario.

      final idToken = googleAccount.authentication.idToken;
      if (idToken == null) {
        throw const AuthException(
          'No se pudo obtener el token de Google. Intenta de nuevo.',
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return response.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // Usuario canceló el flujo.
      }
      debugPrint('GoogleAuthService.signInWithGoogle GoogleSignInException: '
          '${e.code} ${e.description}');
      throw AuthException(_mapGoogleError(e));
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapSupabaseError(e));
    } catch (e, st) {
      debugPrint('GoogleAuthService.signInWithGoogle error: $e\n$st');
      throw const AuthException(
        'No se pudo completar el registro con Google. Intenta de nuevo.',
      );
    }
  }

  /// Muestra un bottom sheet con el botón real de Google (obligatorio en
  /// web) y espera a `authenticationEvents` para saber cuándo el login
  /// terminó. Retorna `null` si el usuario cierra el sheet sin
  /// completar el flujo (cancelado, no es un error).
  Future<GoogleSignInAccount?> _authenticateViaWebButton(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    final completer = Completer<GoogleSignInAccount?>();
    final subscription = _googleSignIn.authenticationEvents.listen(
      (event) {
        if (event is GoogleSignInAuthenticationEventSignIn &&
            !completer.isCompleted) {
          completer.complete(event.user);
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Cierra el sheet automáticamente en cuanto Google confirme
        // (éxito o error) — el usuario no tiene que hacer nada más.
        completer.future.whenComplete(() {
          if (Navigator.canPop(sheetContext)) Navigator.pop(sheetContext);
        });
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continúa con tu cuenta de Google',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 20),
                renderGoogleButton(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    await subscription.cancel();
    if (!completer.isCompleted) return null; // Cerrado sin elegir cuenta.
    try {
      return await completer.future;
    } on GoogleSignInException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _client.auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  User? get currentUser => _client.auth.currentUser;

  /// Gestión de sesión (TG-102) para cuentas de Google.
  Stream<User?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  String _mapGoogleError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.interrupted:
        return 'Se interrumpió el inicio de sesión con Google. Intenta de nuevo.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google no está configurado correctamente en la app.';
      default:
        return 'No se pudo completar el registro con Google. Intenta de nuevo.';
    }
  }

  String _mapSupabaseError(AuthApiException e) {
    final message = e.message.toLowerCase();
    if (message.contains('audience') || message.contains('client')) {
      return 'Google no está habilitado correctamente en el servidor '
          '(revisa el Client ID en Supabase).';
    }
    if (message.contains('nonce')) {
      return 'Falta activar "Skip nonce checks" para este client en '
          'Supabase (Authentication > Providers > Google).';
    }
    return 'Error de autenticación con Google: ${e.message}';
  }
}
