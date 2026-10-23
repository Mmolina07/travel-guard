# Índice histórico de incidencia delictiva por comuna

Indicador del mapa de TravelGuard. Ordena las comunas de Medellín según
cuántos **hurtos a persona** registró la fuente oficial en un período. **No
mide la "peligrosidad real"** de una zona ni el riesgo de una persona
concreta: resume registros históricos.

## Fuente

| | |
|---|---|
| Conjunto | Hurto a persona (MEData, id `1-027-23-000011`) |
| Publicador | Alcaldía de Medellín — Secretaría de Seguridad y Convivencia, Sistema de Información para la Seguridad y la Convivencia (SISC) |
| Archivo | `http://medata.app.medellin.gov.co/sites/default/files/distribution/1-027-23-000011/hurto_a_persona.csv` |
| Licencia | CC BY-SA 4.0 |
| Cobertura | 2003-01-01 a 2023-11-30, 326.489 registros |
| Polígonos | ArcGIS de la Alcaldía, `ServiciosCiudad/CartografiaBase/MapServer/10` |

La versión importada (Last-Modified del archivo) y los conteos de cada
importación quedan en la tabla `seguridad_importaciones`.

## Cálculo

1. **Período**: por defecto 2021-01-01 a 2023-11-30 (`seguridad_config`).
   Los últimos años completos disponibles; 2023 llega hasta noviembre.
2. **Total por comuna**: suma de los registros del período cuyo
   `codigo_comuna` es esa comuna. Los registros con comuna `SIN DATO`
   (5.171 en toda la serie, 1,6 %) no se asignan a ninguna.
3. **Grupos**: las 16 comunas se comparan solo entre sí y los 5
   corregimientos solo entre sí. Los corregimientos son rurales, mucho más
   extensos y con menos población; meterlos en el mismo orden haría ver a
   casi cualquier comuna urbana como "alta".
4. **Índice** = posición percentil dentro del grupo:

   ```
   índice = round(100 × (comunas del grupo con MENOS registros) / (tamaño del grupo − 1))
   ```

   Es `PERCENT_RANK()` de PostgreSQL × 100. La comuna con menos registros
   queda en 0 y la de más en 100; comunas empatadas reciben el mismo valor.
5. **Nivel** (umbrales configurables en `seguridad_config`):

   | Índice | Nivel | Color |
   |---|---|---|
   | 0–24 | Bajo | Verde |
   | 25–49 | Medio | Amarillo |
   | 50–74 | Alto | Naranja |
   | 75–100 | Muy alto | Rojo |

La función es `seguridad_indice_comunas(p_inicio, p_fin)` en
`docs/db/hu_seguridad_medellin_indice.sql`. Con los mismos datos y período
siempre da el mismo resultado.

### Por qué percentil y no proporcional al máximo

Con un índice proporcional (`total / máximo × 100`), La Candelaria
(25.089) quedaría en 100 y la siguiente comuna, Laureles (12.346), en 49:
12 de las 16 comunas quedarían en verde y el mapa no distinguiría casi
nada. El percentil reparte las comunas en los cuatro niveles (con 16
comunas, 4 por nivel) y conserva el orden, que es lo que el mapa comunica.
La contrapartida es que el índice es **relativo**: si todas las comunas
bajaran a la mitad, el mapa se vería igual. Por eso la ficha de cada comuna
muestra también el número absoluto de registros y su participación.

### Por qué no se usa población

Una tasa por habitante necesita la población de cada comuna de una fuente
citable (proyecciones DANE / Alcaldía), y para un turista además engaña:
La Candelaria (el centro) tiene pocos residentes y una gran población
flotante, así que su tasa "por habitante" se dispara. La tabla
`seguridad_comunas` ya tiene `poblacion` y `poblacion_fuente` (obligatoria
si hay población) por si se quiere agregar después.

## Resultado con el período por defecto (2021-01 a 2023-11)

| Comuna | Registros | % del grupo | Índice | Nivel |
|---|---|---|---|---|
| 10 La Candelaria | 25.089 | 26,7 % | 100 | Muy alto |
| 11 Laureles Estadio | 12.346 | 13,1 % | 93 | Muy alto |
| 14 El Poblado | 12.295 | 13,1 % | 87 | Muy alto |
| 16 Belén | 7.744 | 8,2 % | 80 | Muy alto |
| 04 Aranjuez | 5.526 | 5,9 % | 73 | Alto |
| 05 Castilla | 5.293 | 5,6 % | 67 | Alto |
| 07 Robledo | 4.497 | 4,8 % | 60 | Alto |
| 15 Guayabal | 3.979 | 4,2 % | 53 | Alto |
| 12 La América | 3.942 | 4,2 % | 47 | Medio |
| 09 Buenos Aires | 3.697 | 3,9 % | 40 | Medio |
| 08 Villa Hermosa | 2.701 | 2,9 % | 33 | Medio |
| 13 San Javier | 1.783 | 1,9 % | 27 | Medio |
| 03 Manrique | 1.684 | 1,8 % | 20 | Bajo |
| 06 Doce de Octubre | 1.595 | 1,7 % | 13 | Bajo |
| 01 Popular | 1.009 | 1,1 % | 7 | Bajo |
| 02 Santa Cruz | 862 | 0,9 % | 0 | Bajo |

| Corregimiento | Registros | % del grupo | Índice | Nivel |
|---|---|---|---|---|
| 60 San Cristóbal | 1.384 | 43,4 % | 100 | Muy alto |
| 80 San Antonio de Prado | 786 | 24,6 % | 75 | Muy alto |
| 90 Santa Elena | 707 | 22,1 % | 50 | Alto |
| 70 Altavista | 280 | 8,8 % | 25 | Medio |
| 50 San Sebastián de Palmitas | 35 | 1,1 % | 0 | Bajo |

## Limitaciones (decirlas junto al mapa)

- **Registros, no hechos**: solo cuenta hurtos denunciados o registrados
  por la Policía. Donde se denuncia menos, el índice sale más bajo.
- **Exposición**: las comunas con más gente circulando (centro, zonas
  comerciales y turísticas como El Poblado o Laureles) acumulan más
  registros porque hay más personas, no necesariamente porque cada persona
  corra más riesgo.
- **Datos históricos**: la fuente llega a noviembre de 2023.
- **Hora reportada**: ~77 % de los registros cae en :00 o :30; el análisis
  por hora usa franjas de una hora.
- **Comuna completa**: una comuna es grande y heterogénea; el índice no
  describe una calle o un barrio puntual.
