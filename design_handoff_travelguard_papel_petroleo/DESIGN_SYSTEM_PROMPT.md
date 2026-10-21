# Prompt: crear el sistema de diseño desde Claude Code

Úsalo con la opción **Nuevo sistema de diseño → Using Claude Code**. Pégalo en Claude Code dentro
de tu repo Flutter, cuando las fases del rediseño ya estén aplicadas (necesita `lib/theme/` y
`lib/widgets/` terminados).

---

Crea el sistema de diseño de TravelGuard ("Papel Petróleo") a partir de este repo. Fuentes, en
orden de prioridad:

1. `lib/theme/app_theme.dart`: es la fuente de verdad de los tokens.
2. `lib/widgets/` y `lib/shell/`: los componentes reales.
3. `design_handoff_travelguard_papel_petroleo/README.md` y `WEB_LAYOUT.md`: reglas de uso, layout
   web y movimiento.
4. `design_handoff_travelguard_papel_petroleo/TravelGuard Web.dc.html`: referencia visual.

Debe incluir:

**Tokens**
- Color: `ink #0B3438`, `inkSoft #1C7A6B`, `mint #7FD1B9`, `paper #FBF8F1`, `paperDeep #F1EEE5`,
  `wash #E9F0E8`, `line #E5E9E2`, `hair #DDD7C9`, `textMuted #4C6461`, `textLabel #8A8272`, y los
  de modo oscuro si existen en el tema. Cada uno con su rol (fondo, superficie, texto, acento).
- Tipografía: Instrument Serif (display, con itálica para la segunda línea de títulos), Instrument
  Sans (UI) y JetBrains Mono (etiquetas en mayúsculas con letterSpacing 0.14–0.18em). Escala
  completa con tamaños y pesos.
- Radios (10 → 34, más los asimétricos `bottomRight: 60/120`), sombras (`card`, `raised`,
  `inkButton`), espaciado y breakpoints (720 / 1024).
- Movimiento: curvas y duraciones de `AppMotion` (easeOutBack 300 ms, 160 ms en hover, stagger).

**Componentes**, cada uno con variantes y estados (reposo, hover, activo, foco, deshabilitado):
botón primario `ink`, botón `mint`, botón de borde, `SegmentedPill`, chips de filtro, campos con
etiqueta mono y subrayado, `BudgetBar`, `StepProgress`, `TripCard`, `PlaceCard` (destacada y
compacta), `MiniCard` (`ink` / `wash`), `MapPanel`, `SideNav`, `TopBar`, modal de wizard,
`FloatingNavBar` (móvil).

**Patrones de layout**: shell de escritorio (sidebar 248 + topbar + contenido fluido), cabecera
`ink` como tarjeta, retículas `auto-fit minmax()`, columnas 1.6:1 y 1.5:1, login en split.

**Reglas**: nada de ancho tipo celular en escritorio; nada de colores fuera de los tokens; títulos
siempre en display con segunda línea en itálica; etiquetas siempre en mono mayúsculas; sin splash
de Material.

Si encuentras diferencias entre el código y el README, manda el código y anótalas en una sección
"Discrepancias" al final.
