import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() => runApp(const TravelGuardApp());

class TravelGuardApp extends StatelessWidget {
  const TravelGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WebShell(child: LoginScreen()),
    );
  }
}

/// En web la app se centra en un lienzo de ancho mobile (el diseño es
/// mobile-first). En pantallas anchas se ve el papel cálido alrededor.
class WebShell extends StatelessWidget {
  const WebShell({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.paperDeep,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              MediaQuery.sizeOf(context).width > maxWidth ? AppRadius.screen : 0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
