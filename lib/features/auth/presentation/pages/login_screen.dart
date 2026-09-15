import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import '../../../../core/widgets/boarding_pass_card.dart';
import '../../../places_map/presentation/home_screen_comercio.dart';
import '../../../trips/presentation/pages/home_screen_client.dart';
import '../../providers/app_auth_provider.dart';
import "../pages/Register_Type_Screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  /// Rol elegido en el [_RoleToggle] — reemplaza los dos botones
  /// "Iniciar sesión como Turista/Comercio" de lado a lado (se apretaban
  /// en pantallas angostas) por una sola selección que alimenta el mismo
  /// `expectedTipoUsuario` que ya validaba `AppAuthProvider`.
  String _selectedRole = 'turista';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isComercio => _selectedRole == 'comercio';
  Color get _roleColor =>
      _isComercio ? AppColors.accentLight : AppColors.primaryLight;
  Widget get _roleDestination =>
      _isComercio ? const HomeScreenComercio() : const HomeScreenClient();

  void _handleLogin() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final success = await auth.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      expectedTipoUsuario: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      _showError(auth.errorMessage ?? 'No se pudo iniciar sesión.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Ingreso exitoso!')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _roleDestination),
    );
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final success = await auth.signInWithGoogle(context);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      if (auth.errorMessage != null) _showError(auth.errorMessage!);
      return; // Cancelado por el usuario: no hay error que mostrar.
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Ingreso exitoso!')),
    );

    final destination = auth.usuario?.tipoUsuario == 'comercio'
        ? const HomeScreenComercio()
        : const HomeScreenClient();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showError('Por favor ingresa tu correo');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showError('Correo inválido');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Por favor ingresa tu contraseña');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Bienvenido de nuevo',
      subtitle: 'Inicia sesión para seguir planificando tu viaje',
      content: (context) => _buildFormArea(),
    );
  }

  Widget _buildFormArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RoleToggle(
          selected: _selectedRole,
          onChanged: _isLoading
              ? null
              : (role) => setState(() => _selectedRole = role),
        ),
        const SizedBox(height: 20),
        BoardingPassCard(
          leading: Icon(Icons.shield_outlined, color: _roleColor, size: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Correo electrónico'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 18),
              _buildFieldLabel('Contraseña'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función en desarrollo'),
                      ),
                    );
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(backgroundColor: _roleColor),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isComercio
                        ? 'Ingresar como comercio'
                        : 'Ingresar como turista',
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleLogin,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Continuar con Google'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterTypeScreen(),
                  ),
                );
              },
              child: const Text('Regístrate aquí'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryLight,
      ),
    );
  }
}

/// Selector de rol tipo pill — decide si el login valida contra
/// `turista` o `comercio` (mismo `expectedTipoUsuario` que ya requería
/// `AppAuthProvider.signInWithEmail`), sin necesitar dos botones anchos
/// compitiendo por espacio.
class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryLight.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(context, 'turista', 'Turista', Icons.person_outline),
          ),
          Expanded(
            child: _segment(
              context,
              'comercio',
              'Comercio',
              Icons.storefront_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = selected == value;
    final color =
        value == 'comercio' ? AppColors.accentLight : AppColors.primaryLight;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
