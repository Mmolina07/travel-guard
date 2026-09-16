import 'package:flutter/widgets.dart';

/// `FocusNode` único del buscador del `TopBar` — el atajo global `/`
/// (Fase 5, `WEB_LAYOUT.md`) vive fuera del árbol del `TopBar`, así que
/// necesita una forma de pedirle foco sin pasar callbacks por cada
/// pantalla que arma su propio `AppShell`.
final FocusNode searchFocusNode = FocusNode();
