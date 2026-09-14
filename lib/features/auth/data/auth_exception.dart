/// Excepción de dominio para fallas de autenticación (email/contraseña o
/// Google), con un mensaje ya listo para mostrar en la UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
