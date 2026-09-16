import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/search_focus.dart';

/// Atajos de teclado de escritorio (Fase 5, `WEB_LAYOUT.md`): `N` abre
/// el wizard de crear viaje, `Esc` cierra la ruta de encima (el wizard u
/// otra), `/` enfoca el buscador del `TopBar`.
///
/// Envuelve el `child` del `builder` de `MaterialApp.router`: ese
/// `context` queda por *encima* del `Router` (es el `child`, todavía sin
/// montar, el que contiene el `Router`), así que `context.go`/
/// `GoRouter.of(context)` no funcionan ahí — por eso recibe la instancia
/// de [router] directamente en vez de leerla del árbol.
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN): () {
          final current = router.routerDelegate.currentConfiguration.uri.path;
          if (current != '/crear') router.push('/crear');
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (router.canPop()) router.pop();
        },
        const SingleActivator(LogicalKeyboardKey.slash): () {
          searchFocusNode.requestFocus();
        },
      },
      child: child,
    );
  }
}
