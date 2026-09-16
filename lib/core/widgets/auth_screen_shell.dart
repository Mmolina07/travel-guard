import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'responsive_center.dart';
import 'route_pattern_background.dart';
import 'travel_guard_badge.dart';

/// Estructura visual compartida de las pantallas de autenticación
/// (login, registro de turista, registro de comercio): fondo degradado
/// + patrón de ruta punteada, insignia de marca, botón volver, y un
/// layout responsive que pasa de una columna (mobile) a dos paneles
/// (desktop, ≥900px) — evita repetir este mismo armazón en cada
/// pantalla de auth con su propia copia ligeramente distinta.
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.brandTagline =
        'Tu itinerario, tu presupuesto y tu seguridad, en un solo lugar.',
    this.badgeSize = 64,
    this.maxContentWidth = 480,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder content;
  final String brandTagline;
  final double badgeSize;
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
                  TravelGuardBadge(size: badgeSize),
                  const SizedBox(height: 20),
                  _headerText(onDark: true),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
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
                      TravelGuardBadge(size: badgeSize * 2.06),
                      const SizedBox(height: 28),
                      const Text(
                        'TravelGuard',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        brandTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
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
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth + 40),
                  child: Column(
                    children: [
                      _headerText(onDark: false),
                      const SizedBox(height: 28),
                      content(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerText({required bool onDark}) {
    final titleColor = onDark ? Colors.white : AppColors.ink;
    final subtitleColor = onDark
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.textMuted;
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: subtitleColor),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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
