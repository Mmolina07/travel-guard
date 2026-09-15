// Import condicional: en web usa el botón real de Google
// (`google_sign_in_web`), en cualquier otra plataforma un stub que
// nunca se construye (ahí sí funciona `authenticate()` directo).
export 'web_google_button_stub.dart'
    if (dart.library.js_util) 'web_google_button_web.dart';
