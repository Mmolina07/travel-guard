import 'package:flutter/widgets.dart';

/// Stub para plataformas no-web: en Android/iOS `authenticate()` sí
/// funciona, así que este widget nunca debería llegar a construirse.
Widget renderGoogleButton() => const SizedBox.shrink();
