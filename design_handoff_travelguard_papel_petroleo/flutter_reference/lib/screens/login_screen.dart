import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import '../widgets/segmented_pill.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _role = 0; // 0 turista, 1 comercio
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cabecera petróleo con una sola esquina grande (asimetría).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.ink,
                borderRadius: AppRadius.headerAsym,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
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
                        Text('TRAVELGUARD',
                            style: AppText.label(11, color: AppColors.mint)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: RichText(
                      text: TextSpan(
                        style: AppText.display(44, color: AppColors.paper),
                        children: [
                          const TextSpan(text: 'Bienvenido\n'),
                          TextSpan(
                            text: 'de nuevo',
                            style: AppText.displayItalic(44,
                                color: AppColors.mint),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  _LoginCard(
                    role: _role,
                    obscure: _obscure,
                    onRole: (v) => setState(() => _role = v),
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    onSubmit: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
                  ),
                  const Spacer(),
                  Pressable(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.hair),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Continuar con Google',
                          style: AppText.ui(15, weight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: AppText.ui(14, color: AppColors.textMuted),
                        children: [
                          const TextSpan(text: '¿No tienes cuenta?  '),
                          TextSpan(
                            text: 'Regístrate',
                            style: AppText.ui(14, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.role,
    required this.obscure,
    required this.onRole,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final int role;
  final bool obscure;
  final ValueChanged<int> onRole;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadow.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedPill(
            labels: const ['Turista', 'Comercio'],
            index: role,
            onChanged: onRole,
          ),
          const SizedBox(height: 20),
          _UnderlineField(
            label: 'CORREO',
            hint: 'mateo@correo.com',
            emphasized: true,
          ),
          const SizedBox(height: 18),
          _UnderlineField(
            label: 'CONTRASEÑA',
            hint: '••••••••',
            trailing: GestureDetector(
              onTap: onToggleObscure,
              child: AnimatedOpacity(
                duration: AppMotion.pressIn,
                opacity: obscure ? 0.6 : 1,
                child: Text('VER', style: AppText.label(11, color: AppColors.ink)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text('¿Olvidaste tu contraseña?',
                style: AppText.ui(13, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 22),
          Pressable(
            onTap: onSubmit,
            semanticLabel: 'Ingresar como turista',
            child: AnimatedContainer(
              duration: AppMotion.toggle,
              curve: AppMotion.press,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadow.inkButton,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    role == 0 ? 'Ingresar como turista' : 'Ingresar como comercio',
                    style: AppText.ui(16,
                        weight: FontWeight.w700, color: AppColors.paper),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.mint, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.label,
    required this.hint,
    this.emphasized = false,
    this.trailing,
  });

  final String label;
  final String hint;
  final bool emphasized;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(10)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                style: AppText.ui(18, weight: FontWeight.w500),
                cursorColor: AppColors.inkSoft,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hint,
                  hintStyle: AppText.ui(18, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.only(bottom: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: emphasized ? AppColors.ink : AppColors.hair,
                      width: emphasized ? 2 : 1,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.ink, width: 2),
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ],
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
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Icon(icon, color: AppColors.paper, size: 18),
      ),
    );
  }
}
