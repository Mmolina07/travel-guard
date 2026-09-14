import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_exception.dart';

/// Autenticación con Google usando Firebase Authentication (TG-97).
///
/// Encapsula el flujo de `google_sign_in` + `firebase_auth` para que los
/// providers/pantallas no dependan directamente de los SDKs de terceros.
class GoogleAuthService {
  GoogleAuthService({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // En Flutter Web, google_sign_in necesita el Web OAuth
              // Client ID explícito (no basta con FirebaseOptions.web).
              // Es el client_type=3 del google-services.json del
              // proyecto (no es un secreto: los client id de OAuth son
              // públicos por diseño).
              clientId: kIsWeb
                  ? '223103352776-orljp1ln7p011ncbmm470kt724u3qe8n'
                      '.apps.googleusercontent.com'
                  : null,
            );

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Ejecuta el flujo "Registrarse/Iniciar sesión con Google" (Escenario 5
  /// de HU-01) y retorna el usuario autenticado en Firebase.
  ///
  /// Retorna `null` si el usuario cancela el flujo (no es un error).
  Future<fb.User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuario canceló el flujo.

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('GoogleAuthService.signInWithGoogle error: $e\n$st');
      throw const AuthException(
        'No se pudo completar el registro con Google. Intenta de nuevo.',
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  fb.User? get currentUser => _firebaseAuth.currentUser;

  /// Gestión de sesión (TG-102): notifica cambios de sesión (login/logout).
  Stream<fb.User?> authStateChanges() => _firebaseAuth.authStateChanges();

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Este email ya está registrado con otro método de acceso.';
      case 'invalid-credential':
        return 'Credenciales de Google inválidas.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
