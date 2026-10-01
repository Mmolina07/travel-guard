# TravelGuard

App Flutter (objetivo web) para turistas y comercios. Ver `CLAUDE.md` para la arquitectura
feature-first completa y el esquema de base de datos (Supabase/PostgreSQL).

## Getting Started

```bash
flutter pub get
flutter run -d chrome   # o el device que corresponda
```

`generate: true` en `pubspec.yaml` + `l10n.yaml` hacen que `flutter pub get` / `flutter run` /
`flutter build` regeneren automáticamente las clases de localización (`lib/l10n/app_localizations*.dart`)
a partir de los `.arb`. Si solo cambiaste los `.arb` y quieres regenerar sin correr la app:

```bash
flutter gen-l10n
```

## Diseño: tokens del design handoff

Las referencias visuales están en `design_handoff/` (`README.md`, `WEB_LAYOUT.md`,
`TravelGuard Web.dc.html`). Los tokens (colores, radios, sombras, tipografía, movimiento) están
implementados en `lib/core/theme/app_theme.dart` — **es la única fuente de esos valores**: nada de
`Color(0xFF...)`, `BorderRadius.circular(<número suelto>)` ni `TextStyle(fontSize: ...)` sueltos
fuera de esa clase.

| Qué necesitas | Usa |
|---|---|
| Color | `AppColors.ink` / `inkSoft` / `mint` / `paper` / `paperDeep` / `surface` / `wash` / `line` / `hair` / `textMuted` / `textLabel` / `textOnInk` / `error` |
| Radio | `AppRadius.control` (14) / `chip` (13) / `dateField` (18) / `button` (20) / `card` (22) / `cardLg` (28) / `nav` (26) / `screen` (38) / `headerDetail` (asimetría `bottomRight: 44`, para cabeceras de pantallas de detalle) |
| Sombra | `AppShadow.card` / `raised` / `inkButton` — nunca `elevation` de Material |
| Tipografía | `AppText.display(size)` (Instrument Serif, títulos) / `AppText.displayItalic(size)` (acento en segunda línea) / `AppText.ui(size, {weight, color})` (Instrument Sans, cuerpo/UI) / `AppText.label(size, {weight, color})` (JetBrains Mono MAYÚSCULAS, etiquetas) |
| Movimiento | `AppMotion.*` (duraciones) + `AppMotion.enter/press/bouncy/...` (curvas) — nunca `Curves.linear` |

Para campos de formulario, **no repitas** `filled`/`fillColor`/`border`/`enabledBorder` si solo vas
a reproducir lo que ya da el tema global (`AppTheme.light().inputDecorationTheme`): basta con
`InputDecoration(labelText: ..., hintText: ..., prefixIcon: ...)` y el campo ya sale con el radio,
relleno y color de foco correctos. Mira `create_activity_screen.dart` o `create_menu_screen.dart`
como ejemplo.

## Idioma y divisa — cómo mantenerlos en pantallas nuevas

Todo texto visible y todo monto de dinero mostrado en pantalla **debe** pasar por estos dos
sistemas. Si agregas una pantalla (o adaptas una de otra rama) sin esto, el selector de idioma y
el selector de divisa de Configuración dejan de cubrir esa pantalla.

### 1. Idioma (`AppLocalizations`)

- Los textos viven en `lib/l10n/app_es.arb` (plantilla, también fuente de verdad del inglés) y
  `lib/l10n/app_en.arb` — **mismas claves en ambos archivos**, en el mismo orden si es posible.
- Nombre de clave: `pantallaDescripcionEnCamelCase`, con el nombre de la pantalla/widget como
  prefijo (p. ej. `menuDetailDeleteButton`, `subscriptionsFaqTitle`). Así se evitan choques entre
  pantallas y es fácil ubicar a qué vista pertenece cada string.
- Placeholders dinámicos van con `{nombre}` en el string y un bloque `"@clave": {"placeholders": {...}}`
  debajo (ver cualquier ejemplo con `{count}` o `{email}` en los `.arb` actuales).
- Después de tocar los `.arb`, corre `flutter gen-l10n` (o `flutter pub get`) para regenerar
  `app_localizations*.dart` — **no los edites a mano**, se sobrescriben.
- En el widget: `import '.../core/l10n/l10n_extension.dart';` y usa `context.l10n.miClave` (nunca
  `AppLocalizations.of(context)!` directo, para mantener un solo patrón en toda la app).

### 2. Divisa (`CurrencyProvider`)

- **Todo lo que se guarda en Supabase es siempre pesos colombianos (COP)** — `gastos.monto`,
  `viajes.presupuesto_maximo`, precios de productos/actividades, etc. La conversión a USD/EUR es
  **solo de presentación**, nunca toca lo guardado.
- Para mostrar un monto en la pantalla: `import '.../core/settings/currency_provider.dart';` y usa
  `context.formatMoney(montoEnCop)`. Internamente aplica la divisa y tasa que el usuario eligió en
  Configuración (`CurrencyProvider`), con el formato de miles correcto para cada divisa.
- `formatMoney` usa `read`, así que es seguro llamarlo en callbacks (SnackBars, diálogos) y dentro
  de `build()`. Para que la pantalla se **redibuje sola** cuando el usuario cambia de divisa en otra
  pantalla, agrega una vez en el `build()` de la pantalla: `context.watch<CurrencyProvider>();`
  (ver `subscriptions_screen.dart`, `create_menu_screen.dart` o `menu_detail_screen.dart`).
- Nunca construyas el símbolo de moneda a mano (`'\$...'`, `'... COP'` concatenado, etc.) — eso es
  exactamente lo que rompe el selector de divisa cuando alguien lo cambia.

### Checklist al traer/crear una pantalla nueva

1. ¿Hay texto fijo en español? → mover a `app_es.arb` + `app_en.arb`, regenerar, usar
   `context.l10n.*`.
2. ¿Hay algún monto de dinero mostrado al usuario? → `context.formatMoney(valorEnCop)`, nunca un
   literal con `$`.
3. ¿La pantalla necesita reaccionar a un cambio de divisa en vivo? → `context.watch<CurrencyProvider>()`
   una vez en `build()`.
4. ¿Los colores/radios/sombras/tipografía están sueltos (`Color(0xFF...)`, `BorderRadius.circular(16)`,
   `TextStyle(...)`)? → reemplazar por los tokens de `AppColors`/`AppRadius`/`AppShadow`/`AppText`
   (tabla arriba).
5. `flutter analyze` sin errores nuevos antes de abrir PR.

## Persistencia de comercio (menús, actividades, perfil)

Ya **no** viven solo en memoria — están conectados a Supabase:

- **Menús y productos**: tablas nuevas `menus`/`menu_productos` (no existían antes). Repositorio:
  `lib/features/places_map/data/menus_repository.dart`. `Menu`/`MenuItem`
  (`lib/features/places_map/presentation/menu_model.dart`) ahora tienen `id` y sus
  `fromRow`/`toInsertMap` mapean esas tablas (los nombres de campo en Dart siguen en inglés —
  `name`/`description`/`price` — solo cambió cómo se serializan).
- **Actividades**: la tabla `actividades` (HU-07) ya existía pero le faltaban columnas que la UI de
  comercio pedía — se agregaron `categoria`, `estado` ('activa'/'pausada'/'borrador'),
  `fecha_inicio`, `fecha_fin`. `activo` se sigue calculando (`true` solo si `estado='activa'`)
  porque el mapa del lado turista (`PlacesMapRepository.fetchActividadesDelLugar`) filtra por ese
  campo y no debía dejar de funcionar. Repositorio: los métodos nuevos en
  `lib/features/places_map/data/places_map_repository.dart` (`fetchActividadesDelComercio`,
  `createActividad`, `updateActividad`, `deleteActividad`).
- **Perfil de comercio**: `ComercioRepository.update()` (antes no existía) edita
  `nombre_comercio`/`telefono_contacto`/`descripcion`/`horario_apertura`/`horario_cierre`.
  `business_settings_screen.dart` ya no pide el horario como un texto libre — son dos selectores de
  hora (`showTimePicker`), uno por cada columna `TIME` real de `comercios`.

**La migración `docs/db/hu_comercio_menus_actividades.sql` ya se corrió en Supabase** — las tablas
`menus`/`menu_productos` y las columnas nuevas de `actividades` ya existen en la base real.
`MenusRepository` y los métodos nuevos de `PlacesMapRepository` ya pueden leer/escribir contra ellas.

**Categorías de menú/actividad siguen siendo texto libre** (`categoria VARCHAR`, no un FK a una
tabla de categorías): las listas (`_categories` en `create_menu_screen.dart`/
`create_activity_screen.dart`) no corresponden a ninguna tabla de categorías existente
(`categorias_lugar`/`categorias_comercio` son para lugares/comercios en el mapa, no para esto) — se
decidió no crear una tabla nueva solo para esto. Si se necesita un lookup real más adelante, el
patrón a copiar es `ExpenseRepository.fetchCategorias()` (la única tabla de categorías que sí se
trae dinámicamente hoy).

## Estado conocido / pendiente

- `design_handoff/` solo especifica 5 pantallas del lado turista (Login, Home, Crear Viaje,
  Comercios cercanos, Detalle del Viaje). Las pantallas de comercio no tienen mockup propio: se
  alinearon a los mismos tokens (`AppColors`/`AppText`/`AppRadius`/`AppShadow`) por consistencia,
  pero su layout (no sus tokens) queda a criterio de quien las toque después.
- El nombre del comercio que se ve en el saludo del home (`AppAuthProvider.displayName`) no se
  actualiza automáticamente si se edita `nombre_comercio` desde "Mi negocio" — `AppAuthProvider` no
  se refresca desde ahí todavía. El cambio sí queda guardado en Supabase (y se refleja la próxima
  vez que se inicia sesión); solo el texto del saludo en esa misma sesión queda desactualizado.
