import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Inicialización de Firebase (TG-97) para habilitar Firebase Authentication.
///
/// Requiere que `flutterfire configure` haya generado
/// `lib/firebase_options.dart` con las credenciales del proyecto de Firebase
/// (uno por integrante o uno compartido para el equipo). Ese archivo no se
/// versiona con datos sensibles del proyecto real: cada quien corre
/// `flutterfire configure` localmente.
///
/// Pasar `DefaultFirebaseOptions.currentPlatform` es obligatorio en Flutter
/// Web (no hay `google-services.json`/`GoogleService-Info.plist` nativos
/// que lo suplan); sin esto, `Firebase.initializeApp()` falla con
/// "FirebaseOptions cannot be null when creating the default app.".
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
