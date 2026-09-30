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

  Future<void> signOut() => _firebaseAuth.signOut();

  fb.User? get currentUser => _firebaseAuth.currentUser;

  /// Gestión de sesión (TG-102) para email/contraseña. Google ya no pasa
  /// por Firebase — ver `GoogleAuthService`, que ahora usa la
  /// autenticación nativa de Supabase.
  Stream<fb.User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// HU-04: dispara el correo de recuperación (Firebase genera el token
  /// temporal y lo envía — no hay SMTP ni backend propio que mantener).
  ///
  /// Si [email] no está registrado, esto NO lanza error: se traga
  /// `user-not-found` a propósito. Revelar si un correo existe o no es
  /// una fuga de información clásica (permite enumerar cuentas); la UI
  /// siempre debe mostrar el mismo mensaje de éxito sin importar si el
  /// correo estaba registrado.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthException(_mapResetError(e));
    }
  }

  /// Valida el `oobCode` del enlace del correo antes de mostrar el
  /// formulario de nueva contraseña — si ya expiró o se usó, falla acá
  /// en vez de dejar que el usuario llene el formulario para nada.
  /// Retorna el correo asociado (útil para mostrarlo en la pantalla).
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      return await _firebaseAuth.verifyPasswordResetCode(code);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapResetError(e));
    }
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapResetError(e));
    }
  }

  String _mapResetError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña debe tener mínimo 8 caracteres';
      case 'expired-action-code':
        return 'Este enlace ya expiró. Solicita uno nuevo.';
      case 'invalid-action-code':
        return 'Este enlace ya no es válido (puede que ya se haya usado). Solicita uno nuevo.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return 'No se pudo completar la solicitud: ${e.message ?? e.code}';
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
