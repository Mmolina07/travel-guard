import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import '../../../../core/widgets/boarding_pass_card.dart';
import '../../../trips/presentation/pages/home_screen_client.dart';
import '../../providers/app_auth_provider.dart';

class ClienteRegisterScreen extends StatefulWidget {
  const ClienteRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ClienteRegisterScreen> createState() => _ClienteRegisterScreenState();
}

class _ClienteRegisterScreenState extends State<ClienteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Activa las validaciones visuales del Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final success = await auth.registerTourist(
      nombre: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      _showError(auth.errorMessage ?? 'No se pudo completar el registro.');
      return;
    }

    // Feedback visual verde
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro exitoso'),
        backgroundColor: Colors.green,
      ),
    );

    // Redireccionar a Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreenClient()),
    );
  }

  void _onGoogleSignUpPressed() async {
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
      const SnackBar(
        content: Text('Registro exitoso'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreenClient()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Regístrate como turista',
      subtitle: 'Crea tu cuenta para empezar a planificar tu viaje',
      content: (context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BoardingPassCard(
              leading: const Icon(
                Icons.person_outline,
                size: 30,
                color: AppColors.ink,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nombre completo'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Correo electrónico'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildLabel('Confirmar contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isPasswordVisible,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Registrarse'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continúa con',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _onGoogleSignUpPressed,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Registrarse con Google'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Al registrarte aceptas nuestros Términos y Condiciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}
