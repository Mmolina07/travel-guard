import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_extension.dart';
import '../theme/app_theme.dart';
import 'responsive_center.dart';
import 'route_pattern_background.dart';

/// Estructura visual compartida de las pantallas de autenticación
/// (login, registro de turista, registro de comercio, recuperación de
/// contraseña): fondo ink + patrón de ruta punteada, marca "TRAVELGUARD"
/// (mismo chip mint que `login_screen.dart`), botón volver, y un layout
/// responsive que pasa de una columna (mobile) a dos paneles (desktop,
/// ≥900px) — evita repetir este mismo armazón en cada pantalla de auth
/// con su propia copia ligeramente distinta.
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.brandTagline,
    this.maxContentWidth = 480,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder content;
  final String? brandTagline;
  final double maxContentWidth;

  static const double _wideLayoutMinWidth = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.ink)),
          const RoutePatternBackground(opacity: 0.10),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth >= _wideLayoutMinWidth
                    ? _buildWide(context)
                    : _buildNarrow(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Align(alignment: Alignment.topLeft, child: const _BackButton()),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: ResponsiveCenter(
              maxWidth: maxContentWidth,
              child: Column(
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 24),
                  _headerText(),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppShadow.raised,
                    ),
                    child: content(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              const Positioned(top: 24, left: 24, child: _BackButton()),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _BrandMark(),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppText.display(34, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppText.ui(15, height: 1.5, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        brandTagline ?? context.l10n.authBrandTagline,
                        textAlign: TextAlign.center,
                        style: AppText.ui(13, color: Colors.white.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: ColoredBox(
            color: AppColors.paper,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth + 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppShadow.raised,
                    ),
                    child: content(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Título + subtítulo sobre el fondo ink (usados en el layout angosto,
  /// antes de la tarjeta blanca — en el ancho viven en el panel de marca).
  Widget _headerText() {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.display(28, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppText.ui(15, height: 1.4, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}

/// Marca "TRAVELGUARD": chip mint + ícono + versalitas — mismo elemento
/// que usa `login_screen.dart` en su panel de marca, para que todas las
/// pantallas de autenticación compartan el mismo lenguaje visual.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.shield_outlined, size: 18, color: AppColors.ink),
        ),
        const SizedBox(width: 10),
        Text('TRAVELGUARD', style: AppText.label(11, color: AppColors.mint)),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  void _handleBack(BuildContext context) {
    // Las pantallas de recuperación/restablecimiento de contraseña se
    // llegan con `context.go(...)`, que reemplaza el stack del
    // `Navigator` en vez de apilarlo: no queda nada debajo para hacer
    // `Navigator.pop`, y forzarlo dispara un assertion failure. Los
    // registros sí llegan con `Navigator.push`, así que ahí `canPop()`
    // sigue siendo true y el comportamiento no cambia.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBack(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
    );
  }
}
