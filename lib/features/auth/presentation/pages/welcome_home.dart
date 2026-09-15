import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import "../Pages/Register_Type_Screen.dart";
import "../Pages/login_screen.dart";

/// Pantalla de bienvenida — reemplaza la foto de avión pixelada de fondo
/// por una insignia "vuelo + escudo" dibujada con widgets (nítida a
/// cualquier resolución/zoom, incluyendo web) que combina los dos
/// conceptos de la marca: Travel (avión) + Guard (escudo). Se anima al
/// cargar (fade + slide escalonado) y tiene movimiento continuo sutil
/// (flotación, órbita punteada, glow) para que se sienta viva sin
/// distraer del contenido.
class WelcomeHome extends StatefulWidget {
  const WelcomeHome({super.key});

  @override
  State<WelcomeHome> createState() => _WelcomeHomeState();
}

class _WelcomeHomeState extends State<WelcomeHome>
    with TickerProviderStateMixin {
  static const double _largeScreenMinWidth = 600;
  static const double _contentMaxWidth = 440;

  late final AnimationController _introController;
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  Animation<double> _fadeIn(double start, double end) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideUp(double start, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));
  }

  Widget _staggered({
    required double start,
    required double end,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fadeIn(start, end),
      child: SlideTransition(
        position: _slideUp(start, end),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F3D50),
              AppColors.primaryLight,
              Color(0xFF12707F),
            ],
          ),
        ),
        child: Stack(
          children: [
            _AmbientGlow(controller: _loopController),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLargeScreen =
                      constraints.maxWidth > _largeScreenMinWidth;
                  return Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: _contentMaxWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: isLargeScreen ? 48 : 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight -
                                (isLargeScreen ? 96 : 48),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(height: isLargeScreen ? 24 : 12),
                              Column(
                                children: [
                                  _staggered(
                                    start: 0.0,
                                    end: 0.65,
                                    child: _TravelGuardBadge(
                                      loopController: _loopController,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _staggered(
                                    start: 0.2,
                                    end: 0.8,
                                    child: const Text(
                                      'TravelGuard',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _staggered(
                                    start: 0.3,
                                    end: 0.9,
                                    child: Text(
                                      'Explora Medellín con seguridad y '
                                      'control de tu presupuesto',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        height: 1.5,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  _staggered(
                                    start: 0.45,
                                    end: 1.0,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _navigateToLogin(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: const Text(
                                          'Iniciar sesión',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A5F7A),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _staggered(
                                    start: 0.55,
                                    end: 1.0,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _navigateToRegister(context),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'Crear cuenta',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _staggered(
                                    start: 0.6,
                                    end: 1.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '¿Deseas crear una cuenta?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              _navigateToRegister(context),
                                          child: const Text(
                                            'Regístrate aquí',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isLargeScreen ? 16 : 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RegisterTypeScreen()));
  }
}

/// Un par de resplandores muy suaves que se desplazan despacio de fondo
/// — le da profundidad a la pantalla sin competir con el contenido.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * 2 * math.pi;
        return Stack(
          children: [
            Positioned(
              top: 60 + math.sin(t) * 20,
              right: -60 + math.cos(t) * 15,
              child: _glowCircle(220, AppColors.accentLight, 0.18),
            ),
            Positioned(
              bottom: -40 + math.cos(t * 0.8) * 20,
              left: -50 + math.sin(t * 0.8) * 15,
              child: _glowCircle(260, Colors.white, 0.08),
            ),
          ],
        );
      },
    );
  }

  Widget _glowCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

/// Insignia distintiva de la marca: un anillo punteado en órbita lenta
/// (ruta de vuelo), un avión que flota suavemente dentro, y una medalla
/// de "escudo" superpuesta — Travel + Guard en un solo elemento visual,
/// en vez de la foto de stock pixelada que había antes.
class _TravelGuardBadge extends StatelessWidget {
  const _TravelGuardBadge({required this.loopController});

  final AnimationController loopController;

  static const double _size = 140;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedBuilder(
        animation: loopController,
        builder: (context, _) {
          final t = loopController.value;
          final floatOffset = math.sin(t * 2 * math.pi) * 6;
          final orbitAngle = t * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: orbitAngle,
                child: CustomPaint(
                  size: const Size(_size, _size),
                  painter: _DashedOrbitPainter(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Container(
                width: _size - 40,
                height: _size - 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: const Icon(
                    Icons.flight,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLight,
                    border: Border.all(
                      color: const Color(0xFF0F3D50),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Anillo punteado — evoca una ruta de vuelo alrededor de la insignia.
class _DashedOrbitPainter extends CustomPainter {
  _DashedOrbitPainter({required this.color});

  final Color color;
  static const int _dashCount = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < _dashCount; i++) {
      final startAngle = (i / _dashCount) * 2 * math.pi;
      final sweep = (2 * math.pi / _dashCount) * 0.55;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
