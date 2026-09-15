# Notas de configuración — Auth y persistencia (TG-92, TG-97, TG-102, TG-123, TG-124)

## HU-13: Gasto Manual — implementación completa

Nueva feature `lib/features/expenses/` (antes vacía):

- `data/models/gasto_model.dart` / `categoria_gasto_model.dart` +
  `data/expense_repository.dart`: CRUD real contra `gastos` /
  `categorias_gasto` en Supabase (no había nada persistido — RLS y
  tablas ya existían desde `schema.sql`, no hizo falta migración).
- `presentation/widgets/add_expense_sheet.dart`: formulario con
  categorías **reales** (traídas de `categorias_gasto`, ya no la lista
  fija que tenía el sheet viejo con nombres que no coincidían con la
  BD) y selector de fecha acotado al rango del viaje.
- `TripDetailScreen` (que ya tenía un botón "Agregar gasto" pero solo
  guardaba en una lista en memoria — `_extraExpenses`, se perdía al
  salir de la pantalla): ahora carga los gastos reales del viaje al
  abrir, permite agregar (persiste en Supabase, aparece al instante) y
  eliminar (con confirmación), y **el presupuesto se recalcula solo**
  cada vez que la lista de gastos cambia (`_gastosTotal` es un getter
  derivado, no un valor que haya que sincronizar a mano) — "Total
  Gastado", "Disponible", la barra de progreso y el desglose por
  categoría siempre reflejan lo último. Se quitó la clase `Expense`
  (quedó huérfana en `trip_model.dart`).
- Manejo de errores real: si falla la carga/creación/borrado, se
  muestra un SnackBar y no se pierde el estado de la pantalla.

## Mapa/comercios: pulido visual (a pedido explícito, "embellece el front")

- **Marcador del turista**: más pequeño y con una etiqueta fija "Tú
  estás aquí" dibujada en el propio ícono (antes solo un círculo de
  color, sin texto — había que tocarlo para ver el `InfoWindow`).
- **Estilos por categoría** (`data/models/category_visuals.dart`):
  ícono + color + tono de marcador según la categoría real
  (Restaurante, Hotel, Museo, Parque, etc.), usados de forma consistente
  en el mapa, las tarjetas de "Comercios cercanos" y la hoja de
  detalles — en vez de un mismo ícono genérico para todo. No son fotos
  reales (no hay URLs de imágenes en la BD), son ilustraciones
  consistentes por categoría.

## ⚡ Si algo no cuadra con la base de datos: usa `reset_schema.sql` + `schema.sql`

`docs/db/schema.sql` es el esquema **completo** real del proyecto
(basado en `travelguard_schema_sprint1.sql`: usuarios, turistas,
comercios, viajes, gastos, lugares_interes, actividades y sus tablas de
categorías), con dos correcciones puntuales para que funcione con el
código Dart actual:

1. Se eliminó el `CONSTRAINT chk_auth_local` de `usuarios` — exigía
   `password_hash NOT NULL` para cuentas locales, pero la app nunca
   guarda contraseñas en Supabase (la autenticación real vive en
   Firebase). Esto causaba el error `23514` en TODO registro por email.
2. Se agregó RLS habilitado + una política abierta
   (`dev_open_access_*`) en cada tabla. Sin políticas, Postgres bloquea
   todo acceso con el error `42501` ("row-level security policy") — la
   causa de los fallos al registrar turista y comercio.
3. (HU-05/TG-141) Se agregaron `costo_tours`, `costo_restaurantes`,
   `costo_discotecas`, `costo_souvenirs` a `viajes` — el formulario de
   crear viaje captura un monto para cada uno, pero el esquema original
   solo tenía flags booleanos. Si ya tenías `viajes` creada, corre
   `docs/db/hu05_viajes_costos.sql` (aditivo) en vez de resetear todo.

Para dejar la base de datos limpia y consistente:

1. Corre `docs/db/reset_schema.sql` en el SQL Editor de Supabase (usa
   `CASCADE`: borra TODAS las tablas del proyecto, incluidas las que
   dependían de `comercios`/`turistas` como `lugares_interes` y
   `actividades`).
2. Corre `docs/db/schema.sql` completo (recrea todo desde cero, con las
   dos correcciones ya incluidas, más los datos semilla de categorías).

`usuarios_turistas.sql` y `comercios.sql` quedan como referencia
histórica (la primera versión, acotada solo a auth, antes de tener
visibilidad del esquema completo real). Para configurar o reparar la
base de datos usa siempre `reset_schema.sql` + `schema.sql`.

## Estado actual

- **Firebase Authentication**: configurado (proyecto `travelguard-5a487`,
  `lib/firebase_options.dart` generado con `flutterfire configure`,
  proveedores email/contraseña y Google habilitados).
- **Supabase**: proyecto ya existente del equipo. URL y "publishable key"
  quedan como default en `lib/core/network/supabase_client.dart`
  (`SupabaseConfig`).
- El esquema `usuarios` / `turistas` / `comercios` ya está creado en ese
  proyecto (documentado en `CLAUDE.md`). `docs/db/usuarios_turistas.sql`
  y `docs/db/comercios.sql` son la referencia/reproducción de esas
  tablas, no un paso pendiente.

## ⚠️ Discrepancia de tipos en `usuarios.id`

`CLAUDE.md` documenta `usuarios.id` como `uuid`, pero **en el Table
Editor de Supabase la columna real es `int8`** (confirmado directamente
por el equipo). Todo el código de esta capa (`UsuariosRepository`,
`TouristRepository`, `ComercioRepository`, `AppAuthProvider`) usa `int`
para `usuarios.id` / `*.usuario_id`, siguiendo el tipo real de la base de
datos. Si en algún momento se migra `usuarios.id` a `uuid`, hay que
actualizar estos archivos en consecuencia. Vale la pena actualizar
`CLAUDE.md` para que no siga diciendo `uuid`.

## ⚠️ Constraint `chk_auth_local` (bloqueaba TODO registro)

`usuarios` tenía un `CHECK CONSTRAINT` llamado `chk_auth_local` (tampoco
documentado en `CLAUDE.md`) que exigía `password_hash IS NOT NULL`
cuando `proveedor_auth = 'local'`. Como la autenticación real vive en
Firebase (no guardamos contraseñas en Supabase), todo insert local
llegaba con `password_hash = null` y Postgres lo rechazaba con:

```
PostgrestException: new row for relation "usuarios" violates check
constraint "chk_auth_local" (code 23514)
```

Se eliminó la restricción (no borra datos existentes):

```sql
alter table public.usuarios drop constraint if exists chk_auth_local;
```

Si en el futuro se vuelve a asumir un modelo de auth "local" real
(password_hash gestionado por la propia app, sin Firebase), habría que
recrear una validación equivalente.

## Cómo se enlaza Firebase con `usuarios`

`usuarios.id` es autogenerado por Supabase, no el UID de Firebase. Por
eso `AppAuthProvider`/`UsuariosRepository`:

- **Cuentas de Google**: buscan/enlazan por `usuarios.google_id`, donde
  se guarda `FirebaseAuth.instance.currentUser.uid`.
- **Cuentas locales (email/contraseña)**: buscan/enlazan por
  `usuarios.email` (columna única), ya que Firebase gestiona la
  autenticación y Supabase solo guarda el perfil.
- En ambos casos, tras crear/encontrar la fila en `usuarios`, se usa su
  `id` (int) para crear/leer el perfil en `turistas.usuario_id` o
  `comercios.usuario_id`.

## Qué se conectó en esta iteración

- `client_register_screen.dart` (turista): `_handleRegister` ahora
  registra en Firebase + Supabase vía `AppAuthProvider.registerTourist`.
  Se agregó un botón "Registrarse con Google" (nuevo, sin tocar el resto
  del diseño) que llama a `AppAuthProvider.signInWithGoogle`.
- `comercio_register_screen.dart`: `_handleRegister` registra en
  Firebase + Supabase vía `AppAuthProvider.registerComercio`. También
  se agregó "Verificar con Google": como `comercios` exige `nit`,
  `direccion` y `telefono_contacto` (NOT NULL) que Google no provee, el
  botón solo autentica (`AppAuthProvider.beginGoogleSignIn`) y precarga
  nombre/correo; el usuario completa NIT/dirección/teléfono/sede en el
  mismo formulario y presiona "Registrarse", que en ese caso llama a
  `AppAuthProvider.completeComercioGoogleRegistration` (sin contraseña).
- `login_screen.dart`: `_handleLogin` ahora inicia sesión real
  (`AppAuthProvider.signInWithEmail`) y valida que el rol de la cuenta
  coincida con el botón presionado ("Iniciar sesión como Turista" /
  "...Comercio"). Se agregó "Continuar con Google"
  (`AppAuthProvider.signInWithGoogle`), que registra automáticamente
  como turista si es la primera vez (Escenario 5 HU-01) y navega a la
  home correspondiente según `usuario.tipoUsuario`.
- `home_screen_client.dart` / `home_screen_comercio.dart`: el nombre
  hardcodeado ("Ana" / "Mi Negocio") ahora es un getter que lee
  `AppAuthProvider.displayName` (nombre de turista, nombre del comercio,
  o el usuario del email como último recurso).

## HU-02 (TG-107, TG-111, TG-112, TG-124): mensajes exactos y duplicados

`comercio_register_screen.dart` y `AppAuthProvider` ya traían el flujo de
registro/Google funcionando (ver sección anterior); esta iteración ajustó
`_validateForm` y `AppAuthProvider.registerComercio` /
`completeComercioGoogleRegistration` para calzar con los escenarios
exactos de `docs/hu/hu-02.md`:

- **Escenario 6** (campos vacíos): un solo mensaje unificado "Debe
  completar todos los campos obligatorios" en vez de mensajes por campo.
- **Escenario 2** (email): "Email inválido o ya registrado" tanto para
  formato inválido (cliente) como para email ya existente. La duplicidad
  se valida de forma anticipada en `AppAuthProvider` con
  `UsuariosRepository.findByEmail` antes de tocar Firebase.
- **Escenario 4** (NIT): "NIT inválido o ya registrado" para formato
  inválido (regex simple: 5-15 dígitos, guion y dígito de verificación
  opcional) o NIT ya existente, vía el nuevo
  `ComercioRepository.findByNit`.
- Como red de seguridad ante condiciones de carrera (dos registros
  simultáneos con el mismo NIT/email), `AppAuthProvider` también
  atrapa `PostgrestException` (violación de unicidad, código `23505`) y
  la traduce al mismo mensaje según si el conflicto es en `nit` o
  `email`.
- **TG-107**: tanto `registerComercio` como
  `completeComercioGoogleRegistration` crean el `usuarios` con
  `tipo_usuario: 'comercio'` explícitamente — un comercio nunca queda
  identificado como turista, a diferencia del login/registro genérico
  con Google (`signInWithGoogle`) que por defecto asume `'turista'` para
  cuentas nuevas.
- Contraseña mínima ajustada de 6 a 8 caracteres, según el Escenario 1.

## HU-05 (TG-139, TG-141): crear viaje conectado a Supabase

`create_trip_screen.dart` simulaba la creación con `Future.delayed` y
nunca guardaba nada. Ahora:

- Nuevo `lib/features/trips/data/trip_repository.dart`
  (`TripRepository.createTrip`) inserta en `viajes`, usando
  `AppAuthProvider.usuario.id` como `turista_id`. Mapea los campos en
  inglés del formulario (`Trip` en `presentation/pages/trip_model.dart`)
  a las columnas en español de la tabla, incluyendo la conversión de
  fecha `dd/MM/yyyy` → `yyyy-MM-dd` y de los valores de los dropdowns
  (`'Transporte público'` → `'transporte_publico'`, etc.) a los enums de
  Postgres.
- `Trip` ganó `id` (asignado por Supabase tras el insert, vía
  `copyWith`) y `datosCompletos` (Escenarios 8-9 de HU-05).
- `_validateForm()` en `create_trip_screen.dart` ahora usa los mensajes
  exactos de `docs/hu/hu-05.md`: campos obligatorios vacíos, personas ≤
  0, presupuesto ≤ 0, costo de hospedaje ≤ 0 (si se ingresó), dinero de
  emergencias ≤ 0 (si se ingresó), y fecha fin no posterior a fecha
  inicio.
- Si los campos opcionales quedan vacíos, se muestra un diálogo
  ("La estimación será menos precisa. ¿Deseas continuar?") antes de
  guardar con `datos_completos = false` (Escenarios 8-9).
- El botón "Cancelar" y la flecha de volver del AppBar ahora piden
  confirmación ("¿Estás seguro?") antes de descartar el formulario
  (Escenario 10).
- Al crear el viaje con éxito: SnackBar verde con el presupuesto total
  (Escenario 1) y navegación a `TripDetailScreen` (la vista de resumen
  con presupuesto que ya existía) antes de volver a `HomeScreenClient`.
- **Fuera de alcance de TG-139/141** (no se tocó): eliminar un viaje
  (Escenario 11) pertenece a HU-16 (gestión de viajes), no a HU-05.

## HU-07 (tercera vuelta): comercios reales en el mapa + más interactividad

- **Los comercios registrados ya aparecen en el mapa**: la brecha que
  quedaba pendiente (el registro de comercio no capturaba lat/lng) ya
  se cerró. `comercio_register_screen.dart` ahora tiene un mapa
  interactivo (`LocationPickerField`, nuevo widget en
  `presentation/widgets/`) donde el comercio toca para ubicar su
  negocio (o usa su ubicación actual con un botón, y puede arrastrar el
  marcador para ajustar). Eso viaja por `AppAuthProvider.registerComercio`
  / `completeComercioGoogleRegistration` → `ComercioRepository.createProfile`
  hasta `comercios.latitud`/`longitud` — columnas que **ya existían** en
  el esquema, solo faltaba que el código las usara. `ComercioModel`
  también las expone ahora.
- **"Comercios cercanos" ya no tiene nada quemado**: `comercios_cercanos_screen.dart`
  tenía una lista fija de Cartagena (de otra persona del equipo, pero se
  pidió corregirla igual). Se reescribió para usar `PlacesMapRepository`
  (los mismos datos reales del mapa) + la ubicación actual real del
  turista, con categorías dinámicas y distancia real, en vez de
  "rating"/"abierto ahora" inventados que no existen en el esquema.
  Se eliminaron `data/comercio_model.dart` y `presentation/comercios_view.dart`
  (quedaron huérfanos, nadie los importaba ya).
- **Hoja de detalles compartida**: se extrajo a
  `presentation/widgets/place_details_sheet.dart` (`PlaceDetailsSheet`)
  para que el mapa y "Comercios cercanos" usen exactamente la misma
  vista de detalles (TG-152) en vez de tener dos copias.
- **Marcador del turista con ícono propio**: en vez de un pin genérico
  con otro color, `_buildUserIcon` dibuja a mano (Canvas) un círculo de
  la marca con halo y borde blanco, convertido a `BitmapDescriptor`.
- **La cámara sigue al turista siempre** (como se pidió), pero se pausa
  si él mismo arrastra el mapa —si no, sería imposible explorar otros
  lugares—, con un botón para reanudar el seguimiento (cambia de color
  según el estado). El indicador nativo de Google (`myLocationEnabled`)
  se apagó a propósito para no duplicar el indicador visual.
- **Más ubicaciones de prueba**: `docs/db/hu07_seed_places.sql` pasó de
  5 a 12 lugares reales de Medellín (Parque Lleras, Comuna 13, Mercado
  del Río, Plaza Mayor, Parque de los Pies Descalzos, Museo El Castillo,
  Basílica Metropolitana), cubriendo más categorías.

## HU-07 (segunda vuelta): ubicación en tiempo real + "magia"

Sobre lo de abajo, esta iteración además:

- **Ubicación en tiempo real de verdad**: antes solo se pedía la
  posición una vez al cargar. Ahora `LocationService.watchPosition()`
  se suscribe a `Geolocator.getPositionStream()` y mueve un **marcador
  propio del turista** (violeta, con tooltip "Tú estás aquí") en vivo,
  aparte del punto azul nativo (`myLocationEnabled`/`myLocationButtonEnabled`,
  ahora en `true` como pedía la tarea). La cámara solo se mueve en el
  primer fix, no en cada actualización, para no arrebatarle el mapa al
  turista si lo está explorando.
- **Distancia real a cada lugar**: `Geolocator.distanceBetween` calcula
  la distancia en línea recta turista→lugar; se muestra en el snippet
  de cada marcador y en la hoja de detalle, y los lugares se ordenan
  por cercanía dentro de cada categoría.
- **Spinner superpuesto, no bloqueante**: el mapa se renderiza de
  inmediato (con el centro de respaldo) y el `CircularProgressIndicator`
  queda como overlay semi-transparente encima, en vez de tapar la
  pantalla completa mientras carga.
- **"Cómo llegar"**: nuevo botón en la hoja de detalle que abre Google
  Maps (`url_launcher`, ya en el proyecto como dependencia transitiva,
  promovida a directa) con direcciones hacia el lugar. Se agregó el
  `<queries>` de Android necesario para abrir enlaces `https` en
  Android 11+.

## HU-07 (TG-143 a TG-157): mapa interactivo de comercios/lugares cercanos

`map_screen.dart` era un placeholder ("Contenido en desarrollo"). Ahora:

- **TG-143/159**: `google_maps_flutter`/`geolocator` ya estaban en
  `pubspec.yaml`, pero la API key y los permisos de ubicación NO estaban
  configurados (a pesar de lo que se indicó) — los agregué:
  `AndroidManifest.xml` (permisos `ACCESS_FINE/COARSE_LOCATION` + la API
  key como `com.google.android.geo.API_KEY`), `web/index.html` (script
  de Google Maps JS con la key) e `ios/Info.plist`
  (`NSLocationWhenInUseUsageDescription`, requerido por `geolocator`
  aunque la key de Maps en iOS quedó fuera de alcance).
- **TG-145/146/147/155**: nuevo `lib/features/places_map/data/location_service.dart`
  — verifica GPS activo, pide permiso, y distingue 3 fallos
  (`serviceDisabled`, `permissionDenied`, `permissionDeniedForever`) para
  mostrar el mensaje/acción correcta (banner + botón "Activar"/"Ajustes"
  que abre la configuración del sistema vía `Geolocator.openLocationSettings`/`openAppSettings`).
  Si no hay ubicación, el mapa cae a un centro de respaldo (Medellín).
- **TG-144/149/151/156**: nuevo `PlacesMapRepository` (`data/places_map_repository.dart`)
  trae `comercios` + `lugares_interes` (con su categoría vía embed de
  PostgREST: `select('*, categorias_comercio(nombre)')`) unificados en un
  modelo `MapPlace`. El mapa muestra un `CircularProgressIndicator` de
  pantalla completa mientras carga ubicación + lugares, marcadores
  interactivos (tap → hoja de detalle con actividades asociadas, cargadas
  a demanda), y filtro por categoría (chips generados dinámicamente a
  partir de las categorías realmente presentes en los datos).
  `actividades` no tiene lat/lng propias en el esquema (se relaciona vía
  `comercio_id`/`lugar_interes_id`), así que se consultan al abrir el
  detalle de un lugar, no como marcadores independientes.
- **TG-157**: `MapPlace._toDouble` convierte `latitud`/`longitud`
  (`numeric(9,6)`) a `double` de forma defensiva (acepta tanto `num`
  como `String`, por si PostgREST los serializa distinto).
- **`docs/db/hu07_seed_places.sql`**: datos de prueba reales de Medellín
  para `lugares_interes` (Parque Arví, Pueblito Paisa, etc.), porque
  ningún comercio real tiene lat/lng todavía — el formulario de
  registro de comercio (HU-02) no las captura. Esa es una brecha de
  HU-02, no de HU-07; no se tocó `comercio_register_screen.dart` ni
  `ComercioRepository` para no salirme de las subtareas asignadas.

## ⚠️ Cambio de arquitectura: Google ahora usa Supabase Auth nativo (no Firebase)

Decisión explícita del equipo: **Google pasó de Firebase Authentication a
la autenticación nativa de Supabase** (`signInWithIdToken`). Email/
contraseña sigue en Firebase — son dos backends de sesión a propósito,
cada uno responsable de un método de acceso distinto.

- `GoogleAuthService` ya no usa `firebase_auth`: usa `google_sign_in`
  solo para el selector de cuenta de Google (obtener el ID token), y
  `Supabase.auth.signInWithIdToken` para crear la sesión real. Retorna
  el `User` de Supabase, no el de Firebase.
- `google_sign_in` se subió de v6 a **v7.2.0** (`authenticate()` en vez
  de `signIn()`): en Flutter Web, `signIn()` está desaconsejado y no
  garantiza devolver un `idToken` (usa el popup de autorización OAuth2,
  no el flujo de autenticación de Google Identity Services) — eso
  causaba que el popup se cerrara solo (`popup_closed`) sin completar el
  login. `authenticate()` sí lo garantiza en todas las plataformas.
- El Client ID de Google usado por la app (en `GoogleAuthService`,
  `serverClientId` de `GoogleSignIn.initialize`) es **"Cliente web 1"**
  en Google Cloud Console — creado a mano específicamente para Supabase
  (con su Client Secret y el callback
  `https://wtyofjlzjkzjlpdynvay.supabase.co/auth/v1/callback`
  registrado), **no** el que Firebase autogeneró originalmente. Si el
  login con Google vuelve a fallar con `origin_mismatch`, verifica que
  el origin (`https://travelguard-5a487.web.app`) esté agregado a
  *este* cliente específico y no a otro.
- `EmailAuthService` ganó `signOut()`/`currentUser`/`authStateChanges()`
  propios (antes esa gestión de sesión vivía, un poco confusamente, en
  `GoogleAuthService`, porque Firebase era el backend de ambos métodos).
- `AppAuthProvider` ahora escucha **dos streams** en paralelo
  (`_emailAuth.authStateChanges()` para Firebase y
  `_googleAuth.authStateChanges()` para Supabase) y los combina en un
  solo estado de sesión/perfil. `firebaseUser` (email/contraseña) y
  `googleUser` (Google) son campos separados.
- `usuarios.google_id` ahora guarda el `id` (uuid) de la sesión de
  Supabase Auth, no el UID de Firebase.
- **Migración de cuentas ya registradas con Google antes de este
  cambio**: su `google_id` quedó apuntando al UID de Firebase viejo, que
  ya no coincide con nada. `AppAuthProvider._findOrLinkGoogleUsuario`
  hace auto-reparación: si no encuentra la cuenta por `google_id`, busca
  por `email` y actualiza su `google_id` al nuevo valor en vez de crear
  una fila duplicada (que violaría el `UNIQUE` de `email`).

### Configuración ya hecha (para referencia del equipo)

- **Google Cloud Console → Credenciales → "Cliente web 1"**
  (`522265539593-95ivihjvu0gcrda27h6knu4obdp5sntn.apps.googleusercontent.com`):
  "Authorized JavaScript origins" tiene `https://travelguard-5a487.web.app`.
  Si se agrega otro dominio de prueba, debe ir en *este* cliente.
- **Supabase Dashboard → Authentication → Providers → Google**:
  habilitado, con ese mismo Client ID.

Si Supabase rechaza el login por nonce (mensaje mencionando "nonce"),
activa **"Skip nonce checks"** para este client en Authentication >
Providers > Google — no confirmado todavía si `authenticate()` (v7)
sigue necesitando esto como pasaba con el viejo `signIn()` de v6.

## HU-07: fotos reales + formato de dinero (pesos colombianos)

- **Dinero**: se creó `lib/core/utils/money_formatter.dart`
  (`formatCOP`) para mostrar montos con separador de miles ('.') —
  `$2.000.000` en vez de `$2000000`, que era difícil de leer. Se aplicó
  en `create_trip_screen.dart`, `trip_detail_screen.dart` y
  `place_details_sheet.dart` (todos los lugares que ya mostraban dinero
  en pantalla).
- **Fotos reales**: se agregó columna `foto_url text` a `comercios` y
  `lugares_interes` (`docs/db/hu07_fotos.sql`, ya incluida también en
  `schema.sql` para instalaciones nuevas). Los 12 lugares sembrados en
  `hu07_seed_places.sql` ahora traen `foto_url` con fotos reales del
  lugar (Wikimedia Commons, licencia libre, verificadas con `curl -I`
  antes de usarlas) — **excepto "Parque Lleras" y "Mercado del Río"**,
  para los que no existe un archivo específico en Commons; se dejó
  `foto_url = null` en vez de poner una foto de otro sitio.
  - **Pendiente de correr en Supabase**: este repo no tiene credenciales
    de base de datos configuradas para ejecutar SQL desde aquí — hay
    que correr `docs/db/hu07_fotos.sql` en el SQL Editor de Supabase
    (agrega las columnas y actualiza los 10 lugares con foto). Si se
    vuelve a correr `hu07_seed_places.sql` desde cero, ya incluye
    `foto_url` en el insert, así que no necesitaría el `update` de
    `hu07_fotos.sql` aparte.
  - **Bug encontrado en producción y corregido**: las fotos no se veían
    en `https://travelguard-5a487.web.app` — la consola mostraba
    `blocked by CORS policy` para cada `foto_url`. Causa: las URLs
    usaban `commons.wikimedia.org/wiki/Special:FilePath/<archivo>`,
    que responde con un **redirect** (302 → 301) hacia
    `upload.wikimedia.org` antes de llegar a la imagen real; el dominio
    intermedio (`commons.wikimedia.org`) no manda cabecera
    `Access-Control-Allow-Origin`, y el renderer CanvasKit de Flutter
    Web (que carga imágenes vía XHR/fetch, no `<img>`) sí exige esa
    cabecera. `upload.wikimedia.org` (el destino final) sí la manda
    (`access-control-allow-origin: *`), así que la solución fue apuntar
    **directo** a esa URL, sin pasar por el redirect. Todas las
    `foto_url` en `hu07_seed_places.sql` y `hu07_fotos.sql` ya se
    actualizaron a la forma
    `https://upload.wikimedia.org/wikipedia/commons/<hash>/<hash>/<archivo>`.
    Si se agrega una foto nueva de Commons a futuro, hay que resolver
    la URL final (`curl -s -o /dev/null -w '%{url_effective}' -L
    'https://commons.wikimedia.org/wiki/Special:FilePath/<archivo>'`)
    en vez de usar el link de `Special:FilePath` directamente.
  - `MapPlace` (`fotoUrl`) y `ComercioModel` (`fotoUrl`) ya leen la
    columna. La UI (`comercios_cercanos_screen.dart`,
    `place_details_sheet.dart`) muestra `Image.network(fotoUrl)` con
    `loadingBuilder`/`errorBuilder`, y si no hay foto (o falla la
    carga) cae de vuelta al ícono + degradado de `CategoryVisual` de
    siempre — nunca se rompe la tarjeta por una foto caída.
  - **No incluido todavía**: que un comercio (HU-02) suba su propia
    foto real del negocio al registrarse. `ComercioModel`/`comercios`
    ya tienen `fotoUrl`/`foto_url` listos para recibirla, pero falta el
    flujo de subida (bucket de Supabase Storage + `image_picker` +
    UI en el formulario de registro) — no se construyó porque no fue
    parte explícita de lo pedido y toca la pantalla de registro de
    comercio, que es maquetación de otro compañero.

## Qué NO se tocó

Ningún estilo, color, texto fijo, ni estructura visual de las pantallas
de `lib/features/auth/presentation/**`, `home_screen_client.dart` ni
`home_screen_comercio.dart` — solo se agregó lógica (imports, métodos,
y en `client_register_screen.dart` un botón nuevo) siguiendo el permiso
explícito de vincular eventos en la UI sin alterar la maquetación de
Ana María.

## Bug: se perdía la sesión al recargar la página (F5)

Firebase Auth y Supabase Auth sí persisten la sesión en el navegador
por defecto (localStorage) — el problema no era la persistencia en sí,
sino que `MyApp` en `lib/main.dart` tenía `home: const WelcomeHome()`
**fijo**, sin mirar nunca el estado de `AppAuthProvider`. Entonces,
aunque al recargar la página `AppAuthProvider` sí restauraba la sesión
(`AuthStatus.authenticated` + `tourist`/`comercio` cargados desde
Supabase), la UI ignoraba ese estado y siempre mostraba la pantalla de
bienvenida/login, dando la impresión de que la sesión se perdía.

Se agregó `AuthGate` (nuevo widget en `lib/main.dart`, `home:` ahora
apunta a él) que escucha `AppAuthProvider` con `context.watch`:
- `AuthStatus.unknown` (esperando la primera respuesta de Firebase/
  Supabase al arrancar): spinner de carga.
- `AuthStatus.authenticated` con `comercio != null`: `HomeScreenComercio`.
- `AuthStatus.authenticated` con `tourist != null`: `HomeScreenClient`.
- `AuthStatus.authenticated` pero el perfil todavía no resolvió: spinner.
- `AuthStatus.unauthenticated`: `WelcomeHome` (como antes).

No se tocó la maquetación de `WelcomeHome`, `HomeScreenClient` ni
`HomeScreenComercio` — solo se agregó el enrutamiento en `main.dart`.

## Google Sign-In no funciona en Web con `google_sign_in` v7 (y cómo se arregló)

`google_sign_in` v7 **no soporta `authenticate()` en Flutter Web** — lanza
`UnimplementedError: authenticate is not supported on the web. Instead,
use renderButton to create a sign-in widget.` Es una restricción real de
Google (anti-bot): en web exigen que el click sea sobre un botón que
ellos mismos renderizan (Google Identity Services), no uno disparado
por código.

Solución implementada (sin cambiar el diseño de los botones existentes
en `login_screen.dart`, `client_register_screen.dart` ni
`comercio_register_screen.dart`):

- `GoogleSignIn.supportsAuthenticate()` devuelve `false` en web y `true`
  en Android/iOS — `GoogleAuthService.signInWithGoogle()` ahora se
  ramifica en ese chequeo.
- En **web**: abre un bottom sheet con el botón real de Google
  (`renderGoogleButton()`, de `package:google_sign_in_web/web_only.dart`,
  importado condicionalmente vía `web_google_button.dart` +
  `_stub.dart`/`_web.dart` porque ese import solo compila en web) y
  espera a `GoogleSignIn.authenticationEvents` para saber cuándo el
  usuario completó el login; el sheet se cierra solo.
- En **Android/iOS**: sigue usando `authenticate()` directo, sin cambios.
- `AppAuthProvider.signInWithGoogle()`/`beginGoogleSignIn()` ahora
  reciben un `BuildContext?` opcional (solo se usa en web, para el
  sheet) — los 3 call sites en las pantallas de auth se actualizaron
  para pasar `context`, sin tocar el resto de esas pantallas.
- Se agregó `google_sign_in_web` como dependencia directa en
  `pubspec.yaml` (antes solo transitiva) porque se importa directo.

**Gotcha de despliegue**: después de este cambio, un usuario reportó
que el error `UnimplementedError` seguía apareciendo en producción
después del deploy. El build sí tenía el fix (se verificó buscando el
string nuevo dentro de `build/web/main.dart.js`) — era el
**Service Worker de Flutter Web** (`flutter_service_worker.js`)
sirviendo la versión JS vieja cacheada en el navegador. Se confirmó
probando en una ventana de incógnito (sin service worker registrado
aún), donde sí funcionó. **Después de cada deploy, probar en incógnito
o hacer "Unregister" del Service Worker en DevTools → Application antes
de asumir que un fix no funcionó** — un refresh normal (incluso
Cmd+Shift+R) no siempre es suficiente.

**Gotcha de dominio (origin_mismatch)**: Firebase Hosting sirve el
mismo despliegue en dos dominios — `https://travelguard-5a487.web.app`
y `https://travelguard-5a487.firebaseapp.com` — pero el OAuth 2.0
Client ID de Google (`522265539593-95ivihjvu0gcrda27h6knu4obdp5sntn`,
en `google_auth_service.dart`) solo tiene autorizado
**`.firebaseapp.com`** en "Authorized JavaScript origins" (Google
Cloud Console). Entrar por `.web.app` da
`Error 400: origin_mismatch` / "The given origin is not allowed for
the given client ID" al intentar el login con Google, aunque el resto
de la app funcione igual en ambos dominios. **Usar siempre
`https://travelguard-5a487.firebaseapp.com` para probar el login con
Google** — o agregar también `.web.app` a los "Authorized JavaScript
origins" en Google Cloud Console (APIs & Services → Credentials) si se
quiere que ambos dominios funcionen.

## "Crear viaje" ahora es un gestor de presupuesto (TG-166)

A pedido explícito: mejoras 1, 2 y 4 de la lista que se propuso. La
mejora 3 (progreso por categoría vs. gasto real) se había marcado
como fuera de este sprint por tocar HU-13, pero luego se confirmó
que **sí entra en este sprint** — ver sección siguiente.

1. **Presupuesto por día y por persona**, calculado solo con las fechas
   y el número de personas ya capturados — antes solo se veía el total
   estimado vs. el máximo. Aparece en `create_trip_screen.dart` (en vivo,
   mientras se llena el formulario) y en `trip_detail_screen.dart` (con
   el presupuesto ya guardado, descontando también los gastos reales de
   HU-13). Lógica compartida en `lib/features/trips/utils/budget_calculator.dart`.
2. **Editar el presupuesto después de creado el viaje** — antes había
   que borrar y recrear el viaje para ajustar el presupuesto. Nueva
   pantalla `edit_trip_budget_screen.dart`, accesible desde el ícono de
   lápiz en `trip_detail_screen.dart` y desde "Editar" en el menú de
   cada tarjeta de viaje en `home_screen_client.dart`.
   `TripRepository.updateTripBudget(...)` (nuevo) actualiza `viajes` y
   reemplaza las categorías del viaje.
4. **Categorías de presupuesto personalizables** — antes eran 5 columnas
   fijas en `viajes` (costo_tours/costo_restaurantes/costo_discotecas/
   costo_souvenirs/costo_actividades_pagas): no se podían renombrar,
   quitar, ni agregar una propia. Ahora viven en una tabla nueva,
   `presupuesto_categorias` (una fila por categoría, nombre y monto
   libres), y el formulario deja agregar/quitar categorías con un botón
   "+ Agregar categoría".

   **Pendiente de correr en Supabase** (no tengo credenciales de DB en
   este entorno): `docs/db/hu05_presupuesto_categorias.sql` — crea la
   tabla + RLS. Las 5 columnas fijas viejas en `viajes` quedan sin
   usarse desde la app (no se borraron, es una acción destructiva; el
   equipo puede hacer `DROP COLUMN` después si confirma que no hacen
   falta).

   `Trip.tours/restaurants/discotheque/souvenirs/paidActivities` (los 5
   campos fijos del modelo) se reemplazaron por `Trip.categories`
   (`List<TripBudgetCategory>`). Se actualizó todo lo que los usaba
   (`trip_detail_screen.dart`, `trip_repository.dart`).

   **Bug de casing encontrado de paso**: `home_screen_client.dart`
   importaba `create_trip_screen.dart` y `trip_detail_screen.dart` como
   `../Pages/...` (mayúscula) cuando la carpeta real es `pages/`
   (minúscula). En macOS esto "funciona" porque el filesystem no
   distingue mayúsculas/minúsculas, pero Dart sí trata esas rutas como
   dos librerías distintas — causaba que `Trip` se resolviera como dos
   tipos incompatibles apenas agregué un archivo nuevo (`edit_trip_
   budget_screen.dart`) en la cadena de imports. Se corrigió a
   minúscula; en Linux (CI, por ejemplo) esto habría sido un error de
   compilación real, no solo un problema mío.

3. **Progreso por categoría vs. gasto real (HU-13) — intentado y revertido
   de la UI.** Se agregó un vínculo opcional entre cada categoría de
   presupuesto y una categoría de gasto real (columna `categoria_gasto_id`
   en `presupuesto_categorias`, FK a `categorias_gasto`), con un dropdown
   "Comparar con gastos reales de..." en `create_trip_screen.dart` y
   `edit_trip_budget_screen.dart`, y una barra de progreso estimado-vs-real
   por categoría en `trip_detail_screen.dart`.

   Se quitó por feedback directo: en el formulario se veía como ruido
   visual sin explicación ("unas listas ahí todas raras", "sin vincular"
   sin contexto) — sobre todo en Crear Viaje, donde no existen gastos
   reales todavía y vincular ahí no tiene mucho sentido. Se eliminó el
   dropdown de ambas pantallas y `_buildExpenseBreakdown()` volvió al
   listado plano (categorías planeadas + gastos reales agrupados por su
   categoría, cada uno vs. el presupuesto total del viaje).

   La columna `categoria_gasto_id` y los campos `categoriaGastoId`/
   `categoriaGastoNombre` en `TripBudgetCategory` **se dejaron intactos**
   (nadie los setea desde la UI ahora, pero no estorban) por si se retoma
   la vinculación más adelante con una interfaz distinta — a definir.

   **Pendiente de correr en Supabase** (no tengo credenciales de DB en
   este entorno), solo si se quiere tener la columna disponible para el
   futuro: `docs/db/hu13_presupuesto_categoria_gasto.sql`, después de
   `hu05_presupuesto_categorias.sql`. No es urgente — hoy nada en la app
   la usa.

## Detalle del viaje: recomendaciones personalizadas ("Para ti")

Nueva sección en `trip_detail_screen.dart`, entre el presupuesto diario y
el desglose de gastos:

- **Ritmo de gasto** (`_buildSpendingPaceCard`): a diferencia de la
  tarjeta ya existente (que reparte el presupuesto entre el total de
  días del viaje), esta usa la fecha de **hoy** — si el viaje ya
  empezó, dice cuánto queda por gastar por día y por persona en lo que
  **resta** del viaje, no en el total; si aún no empieza o ya terminó,
  lo indica en vez de mostrar un número que no aplica. También muestra
  lo ya gastado por persona (`totalSpent / persons`), si hay algo
  registrado.
- **Devolución de IVA para turistas extranjeros** (`_buildTaxRefundCard`):
  toggle "¿Eres turista extranjero?" que, al activarse, estima cuánto de
  lo gastado en la categoría "Compras" (HU-13) corresponde a IVA y
  podría recuperarse. Basado en las reglas reales de la DIAN (búsqueda
  verificada): devolución del 100% del IVA (19%) en compras de bienes
  elegibles con factura electrónica, mínimo 3 UVT por factura, tope de
  200 UVT por solicitud — cifras en pesos calculadas con la UVT 2026
  ($52.374, Resolución DIAN 000238 de 2025). Es un estimado educativo
  dentro de la app, no un trámite oficial; el texto le pide al usuario
  verificar el proceso vigente en dian.gov.co antes de viajar.
