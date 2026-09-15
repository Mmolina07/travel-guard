import 'package:flutter/material.dart';

/// Centra y limita el ancho del contenido en pantallas grandes (web o
/// desktop) para que formularios y listas no se estiren de borde a
/// borde — en móvil (`maxWidth` de la ventana por debajo de
/// [largeScreenMinWidth]) no cambia nada.
///
/// Ver skill `flutter-build-responsive-layout`: las decisiones de
/// layout deben basarse en el espacio disponible de la ventana
/// (`LayoutBuilder`/`constraints.maxWidth`), no en el tipo de
/// dispositivo.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  static const double largeScreenMinWidth = 600;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= largeScreenMinWidth) {
          return Padding(padding: padding, child: child);
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}
