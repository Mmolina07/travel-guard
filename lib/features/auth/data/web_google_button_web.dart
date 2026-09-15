import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// En Flutter Web, `google_sign_in` (v7) ya no soporta disparar el
/// flujo de Google por código (`authenticate()` lanza
/// `UnimplementedError`): Google exige que el usuario haga click en un
/// botón renderizado por su propio SDK (Google Identity Services),
/// como medida anti-bot. `renderButton()` crea ese botón real.
Widget renderGoogleButton() => web.renderButton();
