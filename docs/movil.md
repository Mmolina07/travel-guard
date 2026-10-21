# TravelGuard en móvil (Android / iOS) — pendientes

La app es Flutter: el mismo código compila para web, Android e iOS. Ya quedó preparado lo que se
podía hacer sin un equipo con Android Studio / Xcode; esto es lo que falta, en orden.

## Ya hecho (2026-10-02)

- **Android:** permiso `INTERNET` en `android/app/src/main/AndroidManifest.xml` (antes solo estaba en
  el de debug: el APK de release no tenía red).
- **Login con Google en móvil:** `GoogleAuthService` ya no le pasa el cliente *web* a Android/iOS;
  en móvil `clientId` va en `null` y se toma de la configuración nativa (abajo).
- **iOS:**
  - Las claves se rellenan en un solo archivo: `ios/Flutter/MobileKeys.xcconfig` (lo leen
    `Info.plist` y `AppDelegate.swift`).
  - `Info.plist` ya tiene `GIDClientID`, el esquema de URL de Google y `GMSApiKey`.
  - `AppDelegate.swift` inicializa Google Maps con esa clave; sin ella, abrir el mapa cerraba la app.
  - Versión mínima de iOS: 15.0 (la que pide el SDK de Google Maps).
  - Permisos de fotos y cámara en `Info.plist` para la foto de portada del comercio (`image_picker`).

## Pendiente — requiere a alguien del equipo

### 0. Herramientas
- Se prueba **solo en teléfonos físicos** (sin emuladores: no hay espacio en disco).
- Android: instalar Android Studio (solo SDK) + teléfono con depuración USB.
- iOS: Mac con Xcode completo + CocoaPods (`sudo gem install cocoapods` o `brew install cocoapods`).
- Verificar con `flutter doctor`.

### 1. Login con Google en Android
El login con Google valida contra Supabase con el cliente web del proyecto de Google Cloud
**522265539593** (no el de Firebase). Por eso:
1. Sacar la huella SHA-1 del equipo que compila: `cd android && ./gradlew signingReport`
   (la de `debug` para pruebas; la de la llave de release si se publica).
2. En Google Cloud Console → proyecto **522265539593** → APIs y servicios → Credenciales → Crear
   ID de cliente OAuth → tipo **Android**, paquete `com.travelguard.app`, la SHA-1 del paso 1.
3. No hay que poner ese ID en el código.

### 2. Login con Google en iOS
1. En el mismo proyecto **522265539593** crear un ID de cliente OAuth tipo **iOS**, bundle id
   `com.travelguard.app`.
2. Copiar el *Client ID* y el *iOS URL scheme* (el client id al revés) en
   `ios/Flutter/MobileKeys.xcconfig` → `GOOGLE_IOS_CLIENT_ID` y `GOOGLE_IOS_REVERSED_CLIENT_ID`.
3. En Supabase → Authentication → Providers → Google → **Client IDs**: agregar ese client id de iOS
   (separado por coma del web) para que Supabase acepte los tokens que emite.

### 3. Google Maps en iOS
- En Google Cloud (proyecto de la clave de Maps) habilitar **Maps SDK for iOS**.
- Si la clave actual está restringida a apps Android, crear una para iOS (restringida al bundle id)
  y ponerla en `GOOGLE_MAPS_IOS_API_KEY` de `ios/Flutter/MobileKeys.xcconfig`. Hoy tiene la de Android
  como provisional.

### 4. Compilar y probar
```bash
flutter run                 # con el emulador/teléfono conectado
flutter build apk --release # APK de Android
flutter build ios           # iOS (después, firmar desde Xcode)
```
Recorrido mínimo: login (correo y Google, turista y comercio) → crear viaje → registrar gasto (ver la
notificación de presupuesto) → mapa y "Cómo llegar" → ficha de un comercio con su menú → Planes /
Mi suscripción → como comercio: editar datos, dirección y menú.

## Limitaciones conocidas en móvil

- **Notificaciones (HU-11):** en el teléfono las alertas y recordatorios salen solo con la app
  abierta (dentro de la app). Las "notificaciones del navegador" son solo web. Recibirlos con la app
  cerrada requiere agregar notificaciones locales (`flutter_local_notifications`) — es otra
  funcionalidad.
- **Identificador:** `com.travelguard.app` (cambiado el 2026-10-19 desde `com.example.travelguard`,
  que las tiendas no aceptan). Firebase ya tiene registradas apps Android/iOS con ese id
  (`google-services.json`, `GoogleService-Info.plist` y `firebase_options.dart` actualizados); las
  apps viejas `com.example.*` siguen en Firebase sin uso (macOS aún apunta a la de iOS vieja).
- **Pagos:** Mercado Pago sigue con el cobro simulado (`MP_SIMULAR_COBRO`), igual que en web.
