import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/trips/presentation/pages/create_trip_screen.dart';
import '../features/trips/presentation/pages/trip_model.dart';
import '../widgets/ink_header.dart';
import 'app_shell.dart';

/// Pantalla secundaria del turista con el layout de "Papel Petróleo"
/// (`WEB_LAYOUT.md`): desde [AppBreakpoints.mobile] va dentro de
/// [AppShell] (sidebar + topbar) con la cabecera `ink` como tarjeta; en
/// móvil, la cabecera arriba a todo el ancho, el contenido con scroll y
/// [action] fija abajo. Nunca una columna angosta centrada en escritorio.
///
/// [header] recibe `asCard` (true en escritorio) para armar el
/// [InkHeader]. [body] es solo contenido: sin `Scaffold` ni scroll propio.
class ShellPage extends StatelessWidget {
  const ShellPage({
    super.key,
    required this.section,
    required this.header,
    required this.body,
    this.action,
    this.activeTrip,
    this.activeTripSpent,
  });

  final AppSection section;
  final InkHeader Function(bool asCard) header;
  final Widget body;

  /// Acción principal (un `InkButton` con `expand: true`).
  final Widget? action;
  final Trip? activeTrip;
  final double? activeTripSpent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header(false),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
                    child: body,
                  ),
                ],
              ),
            ),
            bottomNavigationBar: action == null
                ? null
                : Container(
                    decoration: const BoxDecoration(
                      color: AppColors.paper,
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: SafeArea(top: false, child: action!),
                  ),
          );
        }
        return AppShell(
          section: section,
          onNavigate: (s) => goToSection(context, s),
          onCreateTrip: () => showCreateTripDialog(context),
          activeTrip: activeTrip,
          activeTripSpent: activeTripSpent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header(true),
              body,
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: action,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Navegación del sidebar del turista, igual en todas las vistas.
void goToSection(BuildContext context, AppSection section) {
  switch (section) {
    case AppSection.inicio:
    case AppSection.misViajes:
      context.go('/');
    case AppSection.comercios:
      context.go('/comercios');
    case AppSection.mapa:
      context.go('/mapa');
    case AppSection.actividades:
      context.go('/actividades');
    case AppSection.promociones:
      context.go('/promociones');
    case AppSection.suscripciones:
      context.go('/suscripciones');
  }
}
