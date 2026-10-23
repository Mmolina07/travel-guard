# Mapa de incidencia delictiva histórica por comuna

Capa del mapa de turista que colorea las comunas de Medellín según el
**Índice histórico de incidencia delictiva** (hurtos a persona registrados
por la Alcaldía), con ficha por comuna y una pantalla de histórico. Está
disponible para todos los usuarios (no es Premium).

- Método del índice y limitaciones: [`indice_incidencia.md`](indice_incidencia.md)
- SQL: `docs/db/hu_seguridad_medellin*.sql` (orden en `docs/db/README.md`)

## Arquitectura

Adquisición, procesamiento y presentación están separados: la app nunca
descarga ni procesa los hurtos uno a uno.

```
 Alcaldía de Medellín                     Computador del equipo
 ┌─────────────────────────────┐          ┌──────────────────────────────┐
 │ MEData (SISC)               │  CSV     │ tool/importar_seguridad.dart │
 │ hurto_a_persona.csv  124 MB ├─────────▶│  · descarga en streaming     │
 ├─────────────────────────────┤          │  · normaliza comuna/modalidad│
 │ ArcGIS CartografiaBase/10   │ GeoJSON  │  · agrega por comuna/mes/hora│
 │ polígonos de comunas        ├─────────▶│  · upsert por lotes          │
 └─────────────────────────────┘          └──────────────┬───────────────┘
                                                         │ service role
                                                         ▼
 Supabase (PostgreSQL)
 ┌──────────────────────────────────────────────────────────────────────┐
 │ seguridad_fuentes · seguridad_importaciones   (trazabilidad)         │
 │ seguridad_comunas (polígono) · seguridad_config (período, umbrales)  │
 │ seguridad_agregado_mensual  comuna × modalidad × año × mes  ~20 mil  │
 │ seguridad_agregado_horario  comuna × año × día × hora       ~36 mil  │
 │                                                                      │
 │ RPC (solo lectura): seguridad_metadatos · seguridad_indice_comunas   │
 │   seguridad_totales_por_comuna · seguridad_por_modalidad             │
 │   seguridad_evolucion · seguridad_por_dia_hora                       │
 └──────────────────────────────────┬───────────────────────────────────┘
                                    │ llave pública (RLS: solo SELECT)
                                    ▼
 Flutter  lib/features/security_insights/
 ┌──────────────────────────────────────────────────────────────────────┐
 │ data/       SecurityRepository + modelos (ComunaGeo, ComunaIndice…)  │
 │ providers/  SecurityMapProvider: capa on/off, carga única en memoria │
 │ presentation/                                                        │
 │   comuna_polygons.dart           polígonos coloreados (con caché)    │
 │   widgets/security_layer_controls.dart   botón + leyenda en el mapa  │
 │   widgets/comuna_incidencia_sheet.dart   ficha al tocar una comuna   │
 │   pages/security_history_screen.dart     /seguridad/comuna/:codigo   │
 │   widgets/incidencia_charts.dart · day_hour_heatmap.dart  (fl_chart) │
 └──────────────────────────────────────────────────────────────────────┘
```

Solo se guardan **agregados** (~7 MB): el plan gratis de Supabase tiene
500 MB y los eventos individuales ocupaban ~140 MB. La trazabilidad queda en
`seguridad_fuentes` (URL oficial y licencia) y `seguridad_importaciones`
(versión del archivo, conteos, rango de fechas): volver a correr el
importador sobre el mismo CSV público da los mismos números.

Firebase no participa: este módulo solo usa Supabase.

## Puesta en marcha (una sola vez)

1. Correr en el SQL Editor, en orden: `hu_seguridad_medellin.sql`,
   `hu_seguridad_medellin_agregados.sql`,
   `hu_seguridad_medellin_estadisticas.sql`, `hu_seguridad_medellin_indice.sql`.
2. Importar (ver abajo).
3. `flutter pub get` (agrega `fl_chart`).

## Importar o actualizar los datos

Cuando la Alcaldía publique una versión nueva del CSV, o para volver a
cargar todo:

```bash
SUPABASE_SERVICE_ROLE_KEY='<secret key>' dart run tool/importar_seguridad.dart
```

- La llave es la *secret key* (o `service_role`) de Supabase → Settings →
  API Keys. Nunca va en el código ni en el repo.
- Tarda unos minutos (descarga 124 MB). Deja Supabase igual a la versión
  actual de la fuente: actualiza lo que cambió y borra lo que ya no está.
- Si falla a mitad de camino, la importación queda con `estado = 'error'` y
  el mensaje; basta con volver a correrlo.
- Opciones: `--dry-run` (procesa sin escribir), `--csv <ruta>` (usa un CSV
  ya descargado), `--solo-comunas` (solo polígonos).

La app no se tiene que volver a publicar: lee los datos nuevos la próxima
vez que se abra.

### Comprobar una importación

```sql
select id, estado, version_fuente, filas_leidas, filas_sin_comuna,
       filas_omitidas, fecha_min, fecha_max, terminada_at
from seguridad_importaciones order by id desc limit 3;

select codigo, nombre, total, indice, nivel from seguridad_indice_comunas();
```

Importación del 2026-10-23: 326.489 filas, 5.171 sin comuna, 0 omitidas,
2003-01-01 → 2023-11-30. Los totales se cruzaron contra el CSV original y
coinciden exactamente.

## Cambiar el período o los colores

Sin tocar la app:

```sql
update seguridad_config
set periodo_inicio = '2022-01-01',
    periodo_fin    = '2023-11-30',
    umbral_medio = 25, umbral_alto = 50, umbral_muy_alto = 75;
```

La leyenda, la ficha y el histórico toman los valores nuevos al recargar.

## Agregar otra fuente (p.ej. hurto de moto)

MEData publica con el mismo formato hurto de moto (`1-027-23-000014`), de
carro (`…000013`), a residencia (`…000012`), a establecimiento comercial
(`…000010`) y en transporte público (`…000308`). Para sumar una:

1. `INSERT INTO seguridad_fuentes (...)` con su URL, `tipo_delito` y
   `tiene_hora`.
2. En el importador, parametrizar `_fuenteHurtos` / `_urlHurtos` (hoy son
   constantes de una sola fuente) y correrlo por fuente.
3. Para que el mapa la use: `update seguridad_config set fuente_id = '…'`.

Las tablas y funciones ya filtran por `fuente_id`, no hay que cambiarlas.

## Decisiones tomadas

| Decisión | Por qué |
|---|---|
| MEData y no el MapServer `VM_Indicador_Seguridad` | El MapServer es una foto vieja (2015–2017, sin hora, 17.719 hurtos a persona en 2017) de la misma serie que MEData (2003–2023, con hora, 26.307 en 2017). |
| Solo hurto a persona | Es el delito que más afecta a un turista; decisión del equipo. |
| Agregados en vez de eventos | Espacio en Supabase; la app nunca necesita el evento individual. |
| Percentil por grupo | Con proporcional al máximo, 12 de 16 comunas salían verdes. Ver `indice_incidencia.md`. |
| Comunas y corregimientos por separado | Los corregimientos son rurales, más extensos y con menos población. |
| Sin población | No hay fuente citada cargada y engaña en el centro (población flotante). |
| Importador local, no Edge Function | El CSV (124 MB) no cabe en los límites de memoria/tiempo de una Edge Function. |
| Unificar "Rompimiento cerraduta" → "cerradura" | La fuente cambió la ortografía en 2022; sin unificar, la modalidad sale partida en dos. |
| Sin datos personales | Sexo, edad, etc. de las víctimas no hacen falta para el índice. |

## Limitaciones conocidas

- Datos hasta noviembre de 2023 (última versión publicada).
- El índice es relativo (orden entre comunas) y cuenta registros, no hechos.
- La hora es la reportada por la víctima; el análisis por hora usa años
  completos del período (el agregado horario no tiene mes).
- El polígono de una comuna no describe calles o barrios puntuales.
