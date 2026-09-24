import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/search_focus.dart';

/// Atajos de teclado de escritorio (Fase 5, `WEB_LAYOUT.md`): `Esc` cierra
/// la ruta de encima (el wizard de crear viaje u otra), `/` enfoca el
/// buscador del `TopBar`. (El atajo `N` para abrir "Crear viaje" se quitó:
/// un `SingleActivator` de una sola tecla sin modificador es intrínsecamente
/// conflictivo con cualquier campo de texto en toda la app — ver
/// `_isTypingInTextField` más abajo, que sigue haciendo falta para `/`.)
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

  /// `SingleActivator`s sin modificador (como `N` o `/`) igual reciben el
  /// `KeyEvent` aunque haya un `TextField` enfocado — la inserción del
  /// carácter la maneja el canal de IME/`TextInputClient`, aparte del
  /// árbol de foco que usa `CallbackShortcuts`. Sin este chequeo, escribir
  /// una palabra con "n" (p.ej. un destino como "Cancún" o "Panamá") vuelve
  /// a abrir el wizard de crear viaje en cada tecleo.
  ///
  /// Ojo: el `context` del `FocusNode` de un campo de texto NO es el de
  /// `EditableText` — es el del `Focus` interno que éste declara
  /// (`Focus(focusNode: ..., child: ...)` en `editable_text.dart`), así
  /// que comparar `context.widget is EditableText` da siempre `false`. Hay
  /// que buscar `EditableText` como ancestro desde ese contexto.
  bool get _isTypingInTextField {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (router.canPop()) router.pop();
        },
        const SingleActivator(LogicalKeyboardKey.slash): () {
          if (_isTypingInTextField) return;
          searchFocusNode.requestFocus();
        },
      },
      child: child,
    );
  }
}
