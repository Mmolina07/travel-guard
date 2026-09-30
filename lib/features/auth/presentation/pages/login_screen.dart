import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/underline_field.dart';
import '../../../../widgets/pressable.dart';
import '../../../../widgets/segmented_pill.dart';
import '../../providers/app_auth_provider.dart';
import "../pages/Register_Type_Screen.dart";

/// Pantalla de acceso — absorbe también el rol de bienvenida/marketing
/// que antes tenía `WelcomeHome` (retirada): en escritorio el panel
/// izquierdo cumple esa función; en móvil, la cabecera + titular.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double _splitBreakpoint = 900;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  /// 0 = turista, 1 = comercio — alimenta el mismo `expectedTipoUsuario`
  /// que ya validaba `AppAuthProvider`.
  int _roleIndex = 0;

  String get _selectedRole => _roleIndex == 0 ? 'turista' : 'comercio';
  bool get _isComercio => _roleIndex == 1;

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
      _showError(auth.errorMessage ?? context.l10n.loginErrorGeneric);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loginSuccessSnackbar)),
    );

    // El redirect de `AppRouter` decide entre home de turista/comercio
    // según el perfil que acaba de cargar `AppAuthProvider`.
    context.go('/');
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
      SnackBar(content: Text(context.l10n.loginSuccessSnackbar)),
    );

    context.go('/');
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showError(context.l10n.loginErrorEnterEmail);
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showError(context.l10n.loginErrorInvalidEmail);
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError(context.l10n.loginErrorEnterPassword);
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
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterTypeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _splitBreakpoint) {
            return _buildSplit(constraints.maxWidth);
          }
          return _buildMobile();
        },
      ),
    );
  }

  // ─── Escritorio: dos paneles a alto completo (1.05 : 1) ───

  Widget _buildSplit(double screenWidth) {
    final headlineSize = (screenWidth * 0.044).clamp(40.0, 64.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 21, child: _buildBrandPanel(headlineSize)),
        Expanded(
          flex: 20,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildCard(includeFooter: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandPanel(double headlineSize) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(120)),
      child: Container(
        color: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.mint.withValues(alpha: 0.20),
                      AppColors.mint.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('TRAVELGUARD', style: AppText.label(11, color: AppColors.mint)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.loginWelcome, style: AppText.display(headlineSize, color: Colors.white)),
                      Text(context.l10n.loginWelcomeBack, style: AppText.displayItalic(headlineSize)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 380,
                        child: Text(
                          context.l10n.loginHeroSubtitle,
                          style: AppText.ui(16, color: AppColors.textOnInk, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 44),
                      Row(
                        children: [
                          _stat(value: '3', label: context.l10n.loginStatStepsLabel),
                          const SizedBox(width: 44),
                          _stat(value: '100%', label: context.l10n.loginStatBudgetLabel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppText.display(34, color: Colors.white)),
        const SizedBox(height: 4),
        SizedBox(
          width: 130,
          child: Text(label, style: AppText.label(10, color: AppColors.textOnInk)),
        ),
      ],
    );
  }

  // ─── Móvil: cabecera ink asimétrica + tarjeta ───

  Widget _buildMobile() {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.ink,
                borderRadius: AppRadius.headerLogin,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GhostIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      Text('TRAVELGUARD', style: AppText.label(11, color: AppColors.mint)),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.loginWelcome, style: AppText.display(44, color: Colors.white)),
                      Text(context.l10n.loginWelcomeBack, style: AppText.displayItalic(44)),
                    ],
                  ),
                ),
                const SizedBox(height: 44),
                _buildCard(includeFooter: false),
                const SizedBox(height: 20),
                _buildGoogleButton(),
                const SizedBox(height: 14),
                _buildRegisterLink(),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tarjeta compartida (pill, campos, CTA) ───

  Widget _buildCard({required bool includeFooter}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadow.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedPill(
            labels: [context.l10n.loginRoleTourist, context.l10n.loginRoleCommerce],
            index: _roleIndex,
            onChanged: _isLoading ? (_) {} : (i) => setState(() => _roleIndex = i),
          ),
          const SizedBox(height: 22),
          UnderlineField(
            label: context.l10n.loginFieldEmailLabel,
            hint: context.l10n.loginFieldEmailHint,
            controller: _emailController,
            emphasized: true,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 20),
          UnderlineField(
            label: context.l10n.loginFieldPasswordLabel,
            hint: '••••••••',
            controller: _passwordController,
            obscure: !_isPasswordVisible,
            enabled: !_isLoading,
            trailing: UnderlineFieldPasswordToggle(
              visible: _isPasswordVisible,
              onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/recuperar-contrasena'),
                child: Text(
                  context.l10n.loginForgotPassword,
                  style: AppText.ui(13, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Pressable(
            onTap: _isLoading ? null : _handleLogin,
            semanticLabel: _isComercio ? context.l10n.loginSubmitAsCommerce : context.l10n.loginSubmitAsTourist,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: _isLoading ? 0.6 : 1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadow.inkButton,
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isComercio ? context.l10n.loginSubmitAsCommerce : context.l10n.loginSubmitAsTourist,
                          style: AppText.ui(16, weight: FontWeight.w700, color: AppColors.paper),
                        ),
                        const Icon(Icons.arrow_forward, color: AppColors.mint, size: 20),
                      ],
                    ),
            ),
          ),
          if (includeFooter) ...[
            const SizedBox(height: 24),
            _buildGoogleButton(),
            const SizedBox(height: 14),
            _buildRegisterLink(),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Pressable(
      onTap: _isLoading ? null : _handleGoogleLogin,
      semanticLabel: context.l10n.loginContinueWithGoogle,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(context.l10n.loginContinueWithGoogle, style: AppText.ui(15, weight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _goToRegister,
          child: Text.rich(
            TextSpan(
              style: AppText.ui(14, color: AppColors.textMuted),
              children: [
                TextSpan(text: '${context.l10n.loginNoAccountQuestion}  '),
                TextSpan(
                  text: context.l10n.loginRegisterLink,
                  style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostIconButton extends StatelessWidget {
  const _GhostIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Icon(icon, color: AppColors.paper, size: 18),
      ),
    );
  }
}
