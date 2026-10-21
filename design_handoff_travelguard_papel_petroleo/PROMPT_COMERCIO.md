# Prompt — Panel de comercio (web de escritorio)

Pega esto en Claude Code dentro de tu repo Flutter, con la carpeta
`design_handoff_travelguard_papel_petroleo/` en la raíz. Requiere que el rediseño del turista
(tema, widgets y `AppShell`) ya esté aplicado.

---

Vas a rediseñar **el lado comercio** de la app (rol "Comercio": panel del negocio, actividades y
menú) para web de escritorio. Especificación:

- `design_handoff_travelguard_papel_petroleo/TravelGuard Comercio Web.dc.html` es el **objetivo
  visual exacto**. Ábrelo en el navegador y compáralo pantalla por pantalla contra lo que
  construyas. Lee su código: los tamaños, colores, radios y textos están ahí literalmente.
- `WEB_LAYOUT.md` define el shell, los breakpoints y las reglas web. Aplican igual al comercio.
- `README.md` define tokens, tipografía, sombras y movimiento.

**Restricción número uno:** usa el mismo `AppShell` responsive del turista (sidebar 248 + topbar +
contenido fluido a todo el ancho). Quita la cabecera de ancho completo actual, la columna central
angosta y la `BottomNavigationBar` en escritorio. En `< 720 px` se mantiene la nav flotante.

**Reutiliza, no dupliques:** `AppColors`, `AppText`, `AppRadius`, `AppShadow`, `AppMotion`,
`Pressable`, `HoverCard`, `SegmentedPill`, `FilterChipsRow`, `SideNav`, `TopBar`. Parametriza
`SideNav` por rol en lugar de crear otro.

**Conserva** mi lógica de negocio, modelos, validaciones, llamadas a backend y gestión de estado.
Solo cambia la presentación. Los datos de ejemplo del HTML son de relleno: usa los datos reales.

Trabaja por fases y detente al final de cada una para que yo revise:

**Fase 0 — Plan.** Localiza las pantallas actuales de comercio (inicio, crear actividad, menú y lo
que haya) y sus modelos. Dime qué campos tiene cada modelo y cómo los vas a mapear a cada elemento
del diseño. Si hay campos que el diseño no muestra, propón dónde van siguiendo el mismo patrón.

**Fase 1 — Shell del comercio.**
`SideNav` en modo comercio:
- Marca con la línea `COMERCIO` en mono 9 `inkSoft` bajo `TRAVELGUARD`.
- CTA "Crear actividad" (abre el modal).
- Sección `NEGOCIO` con los items Inicio / Actividades / Menú, cada uno con su contador en mono 11.
- Al pie, la tarjeta `wash` "TU PERFIL PÚBLICO" con el nombre del negocio en display 22, la zona y
  el enlace "Ver como turista →", y debajo la fila de perfil con las iniciales y "Salir"
  (reemplaza el "Cerrar sesión" de la cabecera).

`TopBar` con el placeholder "Buscar actividades o platos".

**Fase 2 — Inicio** (`/comercio`).
1. Cabecera como tarjeta `ink`, radio 30 con `bottomRight: 60` y halo `mint` arriba a la derecha.
   Contiene `PANEL DEL NEGOCIO`, "¡Hola, *{nombre}!*" con el nombre en itálica `mint` y
   "Gestiona tu negocio fácilmente". A la derecha van dos contadores translúcidos (display 40 +
   etiqueta mono): ACTIVIDADES y MENÚS CREADOS, pulsables, que llevan a su vista.
2. Retícula `auto-fit minmax(300, 1fr)`:
   - "Crear actividad": blanca, sombra `card`, botón `ink` "+ Actividad".
   - "Agregar menú": `wash`, botón de borde "+ Menú".
   Usa los textos actuales de esas tarjetas.
3. Dos columnas 1.6 : 1:
   - "Mis actividades": las 3 más recientes como filas con thumb 60, categoría mono, nombre,
     fechas · precio y badge de estado.
   - "Tu menú": los 5 primeros platos con su precio en mono `inkSoft`.
4. **Estados vacíos** (mi cuenta tiene 0 de todo; es el caso más importante):
   - Actividades: caja con borde discontinuo de 1.5 px `hair`, radio 24, título display 24 "Aún
     no tienes actividades", explicación y botón "Crear la primera →".
   - Menú: "Todavía no hay platos." con el enlace "Agregar menú".

**Fase 3 — Actividades** (`/comercio/actividades`).
- Encabezado: `{n} EN TOTAL` + "Mis *actividades*".
- A la derecha, chips de filtro Todas / Borrador / Publicada / Pausada.
- Debajo, una tabla en tarjeta blanca radio 26 con las columnas ACTIVIDAD (nombre + descripción
  truncada), CATEGORÍA, FECHAS, PRECIO y ESTADO.
- Estado vacío por filtro.
- Colores de estado:

  | Estado | Fondo | Texto |
  |---|---|---|
  | Publicada | `#E9F0E8` | `#1C7A6B` |
  | Borrador | `#F1EEE5` | `#4C6461` |
  | Pausada | `#F3E6D6` | `#8A5A2B` |

  Añade estos tres colores a `AppColors` como `statusPublished`, `statusDraft` y `statusPaused`.

**Fase 4 — Menú** (`/comercio/menu`).
- Encabezado: `{n} PRODUCTOS` + "Tu *menú*".
- Botón `ink` "+ Agregar producto".
- Productos agrupados por categoría: etiqueta mono y retícula `auto-fill minmax(260, 1fr)` de
  tarjetas blancas con nombre en display 22, precio en mono y descripción.
- Si el formulario actual de "+ Menú" es una pantalla, conviértelo en modal con el mismo patrón
  del de actividad: una columna de vista previa `ink` + el formulario.

**Fase 5 — Modal "Crear actividad"** (ruta hija `/comercio/actividades/nueva`, `pageBuilder` de
diálogo).
- Overlay `ink` al 55% con blur 3.
- Caja `maxWidth: 980`, radio 34, en dos columnas 320 : resto.
- Si la ventana es más baja que el modal, este debe scrollear desde arriba sin cortarse: usa
  `SingleChildScrollView` + `ConstrainedBox(minHeight)` + `Center`, **no** un `Center` solo.

Columna izquierda `ink` — **vista previa en vivo**:
- "Así la verán / *los turistas*".
- Tarjeta blanca con el badge de categoría, el precio (o GRATIS), el nombre (placeholder en
  `textLabel` si está vacío), la descripción, las fechas y el nombre del negocio.
- Al pie, un punto de color y una nota según el estado:
  - Publicada: "Visible en el mapa al guardar".
  - Pausada: "Oculta para los turistas".
  - Borrador: "Solo tú la ves mientras sea borrador".
- La vista previa se actualiza en cada pulsación de tecla.

Columna derecha — **los mismos campos que hoy**, con este tratamiento:
- **Nombre:** campo de subrayado 2 px `ink` y texto 19.
- **Descripción:** textarea `paperDeep` radio 18, 3 líneas, redimensionable.
- **Tipo o categoría:** chips en lugar del dropdown, con las categorías reales de mi backend.
  Activo: `ink` + texto `mint`.
- **Precio, Fecha de inicio y Fecha de fin:** tres cajas `paperDeep` radio 18 en fila.
  - El checkbox "Actividad gratuita" pasa a ser un interruptor "Gratis" dentro de la caja de
    precio: lo deshabilita y lo deja al 35% de opacidad.
  - "Sin fecha de fin" pasa a ser un interruptor "Sin fin" dentro de la caja de fin, con el mismo
    comportamiento.
  - Interruptor de 30×18 con pista `hair`/`inkSoft` y knob blanco animado en `easeOutBack`.
  - El precio usa formato `$32.000` (`intl`, locale `es_CO`).
- **Estado de la actividad:** `SegmentedPill` de 3 opciones en lugar del dropdown, `maxWidth` 420.

Pie con borde superior 1 px `line`:
- "Cancelar" (borde).
- Botón primario cuyo texto depende del estado: "Publicar actividad" / "Guardar pausada" /
  "Guardar borrador". Va al 45% de opacidad y deshabilitado mientras el nombre esté vacío.
- Al guardar: cierra el modal, navega a Actividades con el filtro "Todas" y la nueva actividad
  queda primera en la lista.

Atajos: `N` abre el modal (salvo con el foco en un campo de texto) y `Esc` lo cierra.

**Fase 6 — Movimiento y cierre.**
- Hover de tarjetas: `card` → `raised` y −2 px, 160 ms.
- Chips, segmentos y items de nav: 300 ms `easeOutBack`.
- Stagger de entrada en listas.
- Modal: fade + scale 0.96 → 1.
- Corre `flutter analyze` y `flutter build web --release`.
- Mándame capturas a 1440, 1100 y 720 px, en Inicio con datos, Inicio vacío y el modal abierto.
- Dime qué quedó fuera y por qué.

Reglas:
- Ningún color fuera de `AppColors`.
- No añadas paquetes nuevos.
- No rompas rutas ni nombres públicos sin avisar.
- No toques los tests sin decírmelo.
