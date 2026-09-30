import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import '../../../../core/widgets/underline_field.dart';
import '../../data/auth_exception.dart';
import '../../data/email_auth_service.dart';

/// HU-04, TG-312: pantalla que abre el enlace del correo de
/// recuperación. Se llega acá con `oobCode` como query param — lo pone
/// Firebase en el enlace del correo (ver README de esta HU sobre cómo
/// configurar la "Action URL" en la consola de Firebase para que
/// apunte a esta ruta en vez de a la página genérica de Firebase).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.oobCode});

  final String? oobCode;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailAuthService = EmailAuthService();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isVerifying = true;
  bool _isSaving = false;
  bool _success = false;
  bool _missingCode = false;
  String? _verifyError;
  String? _verifiedEmail;

  @override
  void initState() {
    super.initState();
    _verifyCode();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = widget.oobCode;
    if (code == null || code.isEmpty) {
      setState(() {
        _isVerifying = false;
        _missingCode = true;
      });
      return;
    }
    try {
      final email = await _emailAuthService.verifyPasswordResetCode(code);
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verifiedEmail = email;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verifyError = e.message;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _emailAuthService.confirmPasswordReset(
        code: widget.oobCode!,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _success = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(e.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: context.l10n.resetPasswordTitle,
      subtitle: context.l10n.resetPasswordSubtitle,
      content: (context) {
        if (_isVerifying) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
          );
        }
        final errorMessage = _missingCode ? context.l10n.resetPasswordInvalidLink : _verifyError;
        if (errorMessage != null) return _buildInvalidLink(context, errorMessage);
        if (_success) return _buildSuccess(context);
        return _buildForm(context);
      },
    );
  }

  Widget _buildInvalidLink(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.wash,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 26, color: AppColors.error),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.resetPasswordInvalidLinkTitle,
                      style: AppText.ui(16, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(message, style: AppText.ui(14, color: AppColors.textMuted, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: () => context.go('/recuperar-contrasena'),
            child: Text(context.l10n.resetPasswordRequestNewLink),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_verifiedEmail != null) ...[
                  Text(
                    context.l10n.resetPasswordForEmail(_verifiedEmail!),
                    style: AppText.ui(12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                ],
                UnderlineField(
                  label: context.l10n.configNewPasswordLabel,
                  hint: '••••••••',
                  controller: _newPasswordController,
                  obscure: !_isPasswordVisible,
                  enabled: !_isSaving,
                  autofocus: true,
                  helperText: context.l10n.clientRegisterPasswordHelper,
                  trailing: UnderlineFieldPasswordToggle(
                    visible: _isPasswordVisible,
                    onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return context.l10n.commonPasswordRequired;
                    if (value.length < 8) return context.l10n.resetPasswordMinLength;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commonConfirmPasswordLabel,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscure: !_isPasswordVisible,
                  enabled: !_isSaving,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.clientRegisterConfirmPasswordRequired;
                    }
                    if (value != _newPasswordController.text) {
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
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(context.l10n.resetPasswordSubmitButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.wash,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 26, color: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.resetPasswordSuccessTitle,
                      style: AppText.ui(16, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.resetPasswordSuccessBody,
                      style: AppText.ui(14, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: Text(context.l10n.resetPasswordGoToLogin),
          ),
        ),
      ],
    );
  }
}
