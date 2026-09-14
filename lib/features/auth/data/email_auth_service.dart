import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'auth_exception.dart';

/// Autenticación con email/contraseña usando Firebase Authentication
/// (TG-97/TG-102), para los escenarios 1-4 de HU-01 (registro con
/// email/contraseña) y el login de HU-03.
class EmailAuthService {
  EmailAuthService({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _firebaseAuth;

  Future<fb.User> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No se pudo completar el registro. Intenta de nuevo.',
        );
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  Future<fb.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo iniciar sesión.');
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña debe tener mínimo 8 caracteres';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
