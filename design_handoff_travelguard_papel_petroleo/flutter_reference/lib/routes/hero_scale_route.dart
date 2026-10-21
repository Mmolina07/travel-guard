import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ruta para abrir "Crear viaje" desde el FAB: el Hero mueve el contenedor
/// circular y el contenido entra con escala + fade (emphasized).
class HeroScaleRoute<T> extends PageRouteBuilder<T> {
  HeroScaleRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: AppMotion.openScreen,
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, a, b) => builder(context),
          transitionsBuilder: (context, a, b, child) {
            final curved =
                CurvedAnimation(parent: a, curve: AppMotion.emphasized);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Ruta para el detalle del viaje: el Hero de la tarjeta manda, el cuerpo
/// entra deslizando con rebote corto.
class TripDetailRoute<T> extends PageRouteBuilder<T> {
  TripDetailRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: AppMotion.hero,
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, a, b) => builder(context),
          transitionsBuilder: (context, a, b, child) {
            final curved = CurvedAnimation(parent: a, curve: AppMotion.enter);
            return FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
