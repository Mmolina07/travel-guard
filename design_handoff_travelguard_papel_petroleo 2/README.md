# Handoff: TravelGuard — rediseño "Papel Petróleo"

## Overview
Rediseño completo de la capa visual de TravelGuard (app Flutter, objetivo web): login, home,
creación de viaje, comercios cercanos y detalle del viaje. El objetivo es reemplazar el look de
Material 3 por defecto por una identidad propia: papel cálido + tinta petróleo + acento menta,
tipografía editorial, radios mixtos, layouts asimétricos, sombra direccional única y un sistema de
microinteracciones con rebote físico.

> **Layout web:** este README describe la anatomía de los componentes en formato móvil. Para la
> retícula de escritorio (sidebar de 248, topbar, columnas, wizard en modal, login en split screen)
> manda `WEB_LAYOUT.md`, y el objetivo visual exacto es `TravelGuard Web.dc.html`.

## About the Design Files
Los archivos de este bundle son **referencias de diseño**:
- `TravelGuard Rediseño.dc.html` — prototipo en HTML con las 5 pantallas y los paneles de sistema
  (paleta, tipografía, tabla de movimiento). Es la fuente visual de verdad, **no** código a portar.
- `flutter_reference/` — implementación Flutter de referencia de la dirección elegida (1b). Está
  escrita con datos demo y sin backend: sirve como plantilla de estructura, tokens y animaciones, no
  para reemplazar tu app. La tarea es **recrear el diseño dentro de tu codebase existente**,
  conservando tu lógica, navegación, validaciones y modelos.

## Fidelity
**Alta fidelidad.** Colores, tipografías, tamaños, radios, sombras, duraciones y curvas son finales.
Recréalos tal cual; solo la retícula puede adaptarse si tu contenido real es más largo.

## Design Tokens

### Color
| Token | Hex | Uso |
|---|---|---|
| `ink` | #0B3438 | Tinta petróleo: cabeceras, botones primarios, texto display |
| `inkSoft` | #1C7A6B | Acento medio: barras de progreso, cifras, etiquetas de enlace |
| `mint` | #7FD1B9 | Acento claro **solo sobre ink** (iconos, marca, medidor) |
| `paper` | #FBF8F1 | Fondo de pantalla |
| `paperDeep` | #F1EEE5 | Fondo de pistas/campos, shell web |
| `surface` | #FFFFFF | Tarjetas |
| `wash` | #E9F0E8 | Tarjeta secundaria / tags afirmativos |
| `line` | #E5E9E2 | Bordes de nav y pistas de medidor |
| `hair` | #DDD7C9 | Subrayado inactivo, bordes de chips |
| `textMuted` | #4C6461 | Texto secundario |
| `textLabel` | #8A8272 | Etiquetas mono |
| (sobre ink) | #9DB3B0 | Texto secundario sobre fondo petróleo |

### Tipografía
- **Instrument Serif** — display 22/24/26/32/38/40/42/44, `height: 1.05`. La segunda línea del
  título va en **itálica** con color de acento (`mint` sobre ink, `inkSoft` sobre papel).
- **Instrument Sans** — UI 11-19; pesos 400/500/600/700; `height: 1.4`.
- **JetBrains Mono** — etiquetas 9-12 en MAYÚSCULAS con `letterSpacing: size * 0.14`.

### Radios (mixtos, nunca uniformes)
- Controles chicos e iconos: **14**
- Chips: **13** · Campos de fecha: **18** · Botones: **20-22**
- Tarjetas: **22** (lista) / **24-30** (contenedor)
- Nav flotante y CTA fija: **26**
- Pantalla / cabeceras: **38-44**
- Asimetría: **una sola esquina grande por bloque** — cabecera de login
  `BorderRadius.only(bottomLeft: 120)`; cabecera de detalle `bottomRight: 44`.

### Sombras (una sola dirección, nunca `elevation`)
- `card`: color #092A2E @10%, blur 24, spread -18, offset (0,10)
- `raised`: color #092A2E @20%, blur 40, spread -26, offset (0,20)
- `inkButton`: color #0B3438 @80%, blur 26, spread -14, offset (0,14)

### Espaciado
Margen lateral de pantalla 20 o 26. Gaps verticales: 6 / 12 / 14 / 18 / 22 / 26 / 34 / 44.
Padding de tarjeta 16-22. Alto de la retícula de acciones 150.

## Screens / Views

### 1. Login
**Propósito:** entrar como turista o comercio.
**Layout:** cabecera `ink` de 300 px de alto con `bottomLeft: 120` detrás del contenido (Stack);
sobre ella, fila superior con botón back fantasma (40×40, borde blanco 24%, radio 14) y marca
`TRAVELGUARD` en mono 11 `mint`; título display 44 en dos líneas ("Bienvenido" / *"de nuevo"* en
itálica mint); a 44 px, tarjeta blanca radio 30 con `raised` que contiene:
- `SegmentedPill` Turista/Comercio: pista `paperDeep` radio 20, padding 5, thumb `ink` radio 16 de
  44 px de alto, mitad del ancho.
- Campo **CORREO**: etiqueta mono 10, valor 18/w500, subrayado `ink` 2 px.
- Campo **CONTRASEÑA**: subrayado `hair` 1 px, texto oculto, trailing `VER` mono 11.
- "¿Olvidaste tu contraseña?" 13 `textMuted`, alineado a la derecha.
- Botón primario: `ink`, radio 20, padding 22/18, texto 16/w700 `paper` a la izquierda y flecha
  `mint` 20 a la derecha, sombra `inkButton`. El label cambia según el rol seleccionado.
Al pie: botón secundario blanco con borde `hair` radio 20 ("Continuar con Google") y
"¿No tienes cuenta? **Regístrate**" centrado.

### 2. Home
**Propósito:** entrar a los viajes, al mapa y a crear viaje.
**Layout:** fondo `paper`, sin AppBar.
- Saludo (padding 26): fila con `MARTES 15 · SEP` mono 11 y avatar 36×36 `ink` radio 12 con inicial
  `mint` 14/w700; a 26 px, display 42 "Hola, Mateo." + *"2 viajes activos"* en itálica `inkSoft`.
- **Retícula de acciones asimétrica** (sustituye a los botones sueltos), alto 150, gap 12:
  izquierda `flex 100` tarjeta `wash` radio 28 sin sombra (círculo 30 con borde ink 2, título
  "Mapa" display 22, "14 lugares cerca" 12); derecha `flex 135` tarjeta `ink` radio 28 con sombra
  `raised` (cuadro 34 `mint` radio 11, "Crear\nun viaje" display 26 `paper`, "Presupuesto e
  itinerario" 12 #9DB3B0).
- Encabezado de sección: "Mis viajes" display 24 + `VER TODOS` mono 11 `inkSoft`.
- Lista de `TripCard` (gap 12): tarjeta blanca radio 22 padding 16, sombra `card`, thumb 62×72
  `wash` radio 16 con etiqueta `FOTO` mono 7, título 16/w600, rango mono 11 `textMuted`,
  `BudgetBar` 5 px y "gastado de tope" 11. **Toda la tarjeta es el target**; no hay botón interno.
- **Nav flotante** (margen 22, padding 12/10): blanca, borde `line`, radio 26, sombra `raised`, con
  Inicio / Mapa / FAB / Comercios. El item activo lleva fondo `wash` radio 18 y peso 700. El FAB es
  48×48 `ink` radio 18, icono `+` `mint`, sombra `inkButton`.

### 3. Crear Viaje (3 pasos)
**Propósito:** crear el viaje sin un formulario largo de scroll único.
**Layout:** cabecera (padding 26) con back en caja de borde `hair` radio 14 y `PASO n DE 3` mono 11;
título display 38 por paso ("¿A dónde\nvamos?", "¿Dónde\ndormimos?", "¿Cómo nos\nmovemos?");
`StepProgress`: 3 tramos de 4 px, gap 6, activos `inkSoft`, inactivos `hair`.
Cuerpo en `PageView` sin scroll horizontal manual. Paso 1:
- Tarjeta blanca radio 28 padding 20/22 con sombra `card`: NOMBRE DEL VIAJE (19/w500, divisor `ink`
  2 px), DESTINO (19 `textMuted`, divisor `hair`), y fila de dos `_DateBox` (fondo `paperDeep`
  radio 18, etiqueta mono 10, valor display 26).
- `TIPO DE VIAJE` + `FilterChipsRow` horizontal: Vacaciones / Trabajo / Mochilero / Familia.
- `PRESUPUESTO MÁXIMO` con la cifra como protagonista: display 32 `inkSoft`; slider de 500.000 a
  10.000.000, 19 divisiones, track 6 px `ink`/`hair`, thumb `mint` radio 12.
**CTA fija al pie:** tarjeta blanca radio 26 (margen 20, bottom 22) con `SIGUIENTE` mono 10 + nombre
del próximo paso 15/w600 a la izquierda, y botón `ink` radio 20 "Continuar →" a la derecha.

### 4. Comercios cercanos
**Propósito:** descubrir lugares y comercios verificados cerca.
**Layout:** cabecera `ink` con `bottomRight: 44`, contador `14 LUGARES` mono 11 `mint`, título
display 36 "Cerca / *de ti*" y subtítulo 13. Debajo, `FilterChipsRow` con scroll horizontal
(Todos / Restaurante / Museo / Mirador / Parque / Tour / Discoteca). Tarjetas:
- **Destacada**: radio 28, imagen 150 px arriba (placeholder `wash`), badge de categoría `ink` con
  texto `mint` mono 10 arriba-izquierda, badge de distancia `paper` 92% arriba-derecha; cuerpo con
  nombre display 26, dirección 13 `textMuted`, tags ("Verificado" `wash`/`inkSoft`, "Abierto ahora"
  `paperDeep`) y flecha `inkSoft` a la derecha.
- **Compacta**: fila con imagen 116 px a la izquierda, etiqueta mono 10 `LUGAR · 4.5 KM`, título
  display 22 y descripción 12.
- **Sin botón "Ver detalles"**: la tarjeta completa navega.
- Píldora flotante centrada al pie: `ink` radio 22, punto `mint` 8 px + "Ver en el mapa".

### 5. Detalle del Viaje
**Propósito:** ver y editar el viaje, controlar el presupuesto.
**Layout:** cabecera `ink` con `bottomRight: 44`, padding 26/30: back fantasma + thumb Hero 44×44
`inkSoft` radio 14; título display 40 "Viaje a / *Destino*" (itálica `mint`); metadatos mono 11
#9DB3B0; bloque de presupuesto con `GASTADO` mono 10 + cifra display 40 `paper` a la izquierda y
`TOPE` + cifra 18 #9DB3B0 a la derecha; `BudgetBar` de 8 px (pista blanca 24%, relleno `mint`).
Debajo: `TabBar` scrollable Resumen / Hospedaje / Transporte / Gastos, indicador `ink` 2 px, label
14/w700 activo. Contenido: tarjeta blanca radio 24 con título display 22 + monto mono 12 `inkSoft`,
filas clave-valor (14 `textMuted` / 14 w600) y tags; luego dos `_MiniCard` radio 24 en fila
(izquierda `ink`, derecha `wash`) con etiqueta mono 10, título display 24 y detalle 12.
Pie fijo: botón `ink` radio 22 "Añadir gasto" (flex) + botón cuadrado 58×58 con borde `hair` y `⋯`.

## Interactions & Behavior

### Tabla de movimiento (aplicar tal cual)
| Elemento | Widget | Curva / duración |
|---|---|---|
| Toggle Turista/Comercio | `AnimatedAlign` + `AnimatedDefaultTextStyle` | `easeOutBack` / 320 ms |
| Cualquier botón o tarjeta al presionar | `AnimatedScale` 1→0.96 + `AnimatedContainer` | `easeOutCubic` / 120 ms |
| Chips de filtro | `AnimatedContainer` (color+borde) + `Transform.scale` | `elasticOut` / 380 ms |
| Progreso de pasos | `AnimatedContainer` | `easeOutBack` / 360 ms |
| Cambio de título de paso | `TweenAnimationBuilder` con key (fade + y 12→0) | `easeOutBack` / 360 ms |
| Barra de presupuesto | `TweenAnimationBuilder<double>` desde 0 | `easeOutQuart` / 700 ms |
| Entrada de lista | `SlideTransition` y 16→0 + opacidad, 60 ms por índice | `easeOutCubic` / 300 ms |
| Tarjeta de viaje → Detalle | `Hero` `trip-thumb-{id}` y `trip-title-{id}` + `TripDetailRoute` (slide 0.06 + fade) | `easeOutBack` / 420 ms |
| FAB → Crear viaje | `Hero` `create-trip` + `HeroScaleRoute` (scale 0.92→1 + fade) | `easeInOutCubicEmphasized` / 500 ms |
| Ítem de nav activo | `AnimatedContainer` (padding+fondo) + `AnimatedDefaultTextStyle` | `easeOutBack` / 320 ms |

Reglas: nada de `Curves.linear`; `elasticOut` solo en micro-elementos (chips); `MaterialRectArcTween`
en los Hero de tarjetas. El splash de Material se desactiva (`NoSplash.splashFactory`,
`highlightColor: transparent`) porque el feedback lo da la escala.

### Estados
- **Press**: escala 0.96 + sombra recogida. **Hover (web)**: `SystemMouseCursors.click`; opcional,
  subir la sombra a `raised`.
- **Focus** de campo: subrayado `ink` 2 px, cursor `inkSoft`.
- **Loading**: en el botón primario, reemplazar el texto por un indicador `mint` de 18 px
  manteniendo el alto; el resto de la pantalla con `AnimatedOpacity` 0.5.
- **Error** de campo: subrayado y texto de ayuda en #B4413A, 12/w500, sin mover el layout.
- **Vacío** ("Mis viajes" sin datos): tarjeta `wash` radio 22 con texto display 22 y CTA de crear.

## State Management
Por pantalla, mínimo local (`StatefulWidget`) mientras no haya store:
- Login: `role: int` (0 turista / 1 comercio), `obscure: bool`, `loading`, `error`.
- Home: `tab: int`, lista de viajes.
- Crear Viaje: `step: int` (0-2) + `PageController`, `type: int`, `budget: double`, campos del form.
- Comercios: `selectedFilter: int`, resultados, ubicación.
- Detalle: `TabController` de 4.
Conserva tu gestión de estado y tus llamadas de datos actuales; el rediseño no las cambia.

## Assets
No hay assets binarios. Las fotos aparecen como placeholders `wash` con etiqueta `FOTO` mono: usa
tus imágenes reales (`Image.network` con `fit: BoxFit.cover`) respetando radio 16 (thumb) y 28
(tarjeta destacada). Tipografías vía paquete `google_fonts` (Instrument Serif, Instrument Sans,
JetBrains Mono). Iconografía: `Icons.arrow_back`, `Icons.arrow_forward`, `Icons.add`,
`Icons.more_horiz`.

## Files
- `WEB_LAYOUT.md` — retícula y navegación de escritorio (manda sobre este README en layout).
- `TravelGuard Web.dc.html` — prototipo de la app web de escritorio: objetivo visual exacto.
- `TravelGuard Rediseño.dc.html` — prototipo visual (dirección 1b "Papel Petróleo"; la sección 1a es
  la alternativa descartada, útil solo como contexto).
- `flutter_reference/lib/theme/app_theme.dart` — tokens listos para copiar.
- `flutter_reference/lib/widgets/` — Pressable, SegmentedPill, FilterChipsRow, BudgetBar,
  StepProgress, StaggerIn, FloatingNavBar, TripCard.
- `flutter_reference/lib/routes/hero_scale_route.dart` — rutas con Hero.
- `flutter_reference/lib/screens/` — Login, Home, Crear Viaje, Detalle.
- `flutter_reference/README.md` — estructura y comandos.
- `PROMPT.md` — el prompt a pegar en Claude Code.

## Pendiente
Pasos 2 y 3 de Crear Viaje y la pantalla de Comercios no están implementadas en la referencia
(sí especificadas arriba); los widgets necesarios ya existen.
