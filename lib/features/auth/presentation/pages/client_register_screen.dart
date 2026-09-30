import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import '../../../../core/widgets/underline_field.dart';
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
      _showError(auth.errorMessage ?? context.l10n.commonRegisterErrorGeneric);
      return;
    }

    // Feedback visual verde
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.clientRegisterSuccessSnackbar),
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
      SnackBar(
        content: Text(context.l10n.clientRegisterSuccessSnackbar),
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
      title: context.l10n.clientRegisterTitle,
      subtitle: context.l10n.clientRegisterSubtitle,
      content: (context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnderlineField(
                    label: context.l10n.clientRegisterNameLabel,
                    hint: context.l10n.clientRegisterNameHint,
                    controller: _nameController,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.clientRegisterNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  UnderlineField(
                    label: context.l10n.commonEmailLabel,
                    hint: context.l10n.commonEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.commonEmailRequired;
                      }
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return context.l10n.commonEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  UnderlineField(
                    label: context.l10n.commonPasswordLabel,
                    hint: '••••••••',
                    controller: _passwordController,
                    obscure: !_isPasswordVisible,
                    enabled: !_isLoading,
                    helperText: context.l10n.clientRegisterPasswordHelper,
                    trailing: UnderlineFieldPasswordToggle(
                      visible: _isPasswordVisible,
                      onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.commonPasswordRequired;
                      }
                      if (value.length < 6) {
                        return context.l10n.clientRegisterPasswordMin;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  UnderlineField(
                    label: context.l10n.commonConfirmPasswordLabel,
                    hint: '••••••••',
                    controller: _confirmPasswordController,
                    obscure: !_isPasswordVisible,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.clientRegisterConfirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return context.l10n.commonPasswordsMismatch;
                      }
                      return null;
                    },
                  ),
                ],
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
                    : Text(context.l10n.commonRegisterButton),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    context.l10n.clientRegisterOrContinueWith,
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
                label: Text(context.l10n.clientRegisterGoogleButton),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.l10n.commonTermsNotice,
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
}
