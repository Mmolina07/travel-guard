// Importador del mapa de incidencia delictiva histórica por comuna (Fase 3).
//
// Descarga los datos oficiales de la Alcaldía de Medellín, los agrega por
// comuna y los sube a Supabase. Corre en el computador, no en la app: la app
// nunca descarga ni procesa los ~326 mil hurtos.
//
//   SUPABASE_SERVICE_ROLE_KEY=... dart run tool/importar_seguridad.dart
//
// Opciones:
//   --csv <ruta>      usa un CSV ya descargado en vez de bajarlo (124 MB).
//   --solo-comunas    solo actualiza los polígonos de las comunas.
//   --dry-run         descarga y agrega, pero no escribe nada en Supabase.
//
// Se puede correr las veces que se quiera: los agregados se escriben con
// upsert sobre su llave natural y al final se borran los que la fuente ya
// no trae, así que Supabase queda igual a la última importación.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _fuenteHurtos = 'medata_hurto_persona';
const _urlHurtos =
    'http://medata.app.medellin.gov.co/sites/default/files/distribution/'
    '1-027-23-000011/hurto_a_persona.csv';
const _urlComunas =
    'https://www.medellin.gov.co/servidormapas/rest/services/ServiciosCiudad/'
    'CartografiaBase/MapServer/10/query';

/// El servidor de la Alcaldía rechaza peticiones sin User-Agent de navegador.
const _userAgent = 'Mozilla/5.0 (TravelGuard importador)';

const _comunas = {
  '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', //
  '13', '14', '15', '16', '50', '60', '70', '80', '90',
};

/// Errores de digitación de la fuente que parten una misma modalidad en dos.
const _modalidadCorregida = {'Rompimiento cerraduta': 'Rompimiento cerradura'};

const _lote = 1000;

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final soloComunas = args.contains('--solo-comunas');
  final csvIndex = args.indexOf('--csv');
  final csvLocal = csvIndex >= 0 && csvIndex + 1 < args.length
      ? args[csvIndex + 1]
      : null;

  final url = Platform.environment['SUPABASE_URL'] ??
      'https://wtyofjlzjkzjlpdynvay.supabase.co';
  final key = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  if (key.isEmpty && !dryRun) {
    stderr.writeln(
      'Falta SUPABASE_SERVICE_ROLE_KEY (Supabase → Settings → API Keys → '
      'secret). No la escribas en el código ni la subas al repo.',
    );
    exit(64);
  }

  final db = _Supabase(url, key, dryRun: dryRun);
  try {
    await _importarComunas(db);
    if (!soloComunas) await _importarHurtos(db, csvLocal);
  } on _ImportError catch (e) {
    stderr.writeln('\n✗ ${e.message}');
    exit(1);
  } finally {
    db.close();
  }
}

// ── Polígonos ──────────────────────────────────────────────────────────

Future<void> _importarComunas(_Supabase db) async {
  stdout.writeln('→ Polígonos de comunas (ArcGIS de la Alcaldía)…');
  final uri = Uri.parse(_urlComunas).replace(queryParameters: {
    'where': '1=1',
    'outFields': 'codigo',
    'outSR': '4326',
    // ~11 m: suficiente para el mapa y deja las 21 geometrías en ~100 KB.
    'maxAllowableOffset': '0.0001',
    'geometryPrecision': '6',
    'f': 'geojson',
  });
  final res = await http.get(uri, headers: {'User-Agent': _userAgent});
  if (res.statusCode != 200) {
    throw _ImportError('ArcGIS respondió ${res.statusCode} al pedir comunas.');
  }
  final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  if (body['error'] != null) {
    throw _ImportError('ArcGIS: ${body['error']}');
  }

  var actualizadas = 0;
  for (final f in (body['features'] as List).cast<Map<String, dynamic>>()) {
    final codigo = (f['properties'] as Map)['codigo'] as String?;
    if (codigo == null || !_comunas.contains(codigo)) continue; // SN01/SN02
    await db.patch(
      'seguridad_comunas',
      {'codigo': 'eq.$codigo'},
      {'geometria': f['geometry']},
    );
    actualizadas++;
  }
  if (actualizadas != _comunas.length) {
    throw _ImportError(
      'Se esperaban ${_comunas.length} comunas y llegaron $actualizadas.',
    );
  }
  stdout.writeln('  ✓ $actualizadas polígonos actualizados');
}

// ── Hurtos ─────────────────────────────────────────────────────────────

Future<void> _importarHurtos(_Supabase db, String? csvLocal) async {
  final File archivo;
  String? version;
  if (csvLocal != null) {
    archivo = File(csvLocal);
    if (!archivo.existsSync()) throw _ImportError('No existe $csvLocal');
    version = 'archivo local, modificado ${archivo.lastModifiedSync()}';
  } else {
    stdout.writeln('→ Descargando hurtos (MEData, ~124 MB)…');
    archivo = File('${Directory.systemTemp.path}/tg_hurto_a_persona.csv');
    version = await _descargar(Uri.parse(_urlHurtos), archivo);
  }

  final importacionId = await db.crearImportacion(_fuenteHurtos, version);
  try {
    stdout.writeln('→ Agregando por comuna…');
    final agg = await _Agregador.desde(archivo);
    if (agg.porFecha.isEmpty) {
      throw _ImportError('El CSV no trajo ninguna fila válida.');
    }

    stdout.writeln(
      '  ${agg.leidas} filas · ${agg.sinComuna} sin comuna · '
      '${agg.omitidas} omitidas · ${agg.fechaMin} → ${agg.fechaMax}',
    );

    await db.upsertEnLotes(
      'seguridad_agregado_mensual',
      'fuente_id,comuna_codigo,modalidad,anio,mes',
      agg.filasMensuales(_fuenteHurtos, importacionId),
    );
    await db.upsertEnLotes(
      'seguridad_agregado_horario',
      'fuente_id,comuna_codigo,anio,dia_semana,hora',
      agg.filasHorarias(_fuenteHurtos, importacionId),
    );

    // Lo que no tocó esta importación ya no está en la fuente.
    for (final tabla in [
      'seguridad_agregado_mensual',
      'seguridad_agregado_horario',
    ]) {
      await db.delete(tabla, {
        'fuente_id': 'eq.$_fuenteHurtos',
        'importacion_id': 'neq.$importacionId',
      });
    }

    await db.cerrarImportacion(importacionId, {
      'estado': 'ok',
      'filas_leidas': agg.leidas,
      'filas_sin_comuna': agg.sinComuna,
      'filas_omitidas': agg.omitidas,
      'fecha_min': agg.fechaMin,
      'fecha_max': agg.fechaMax,
    });
    stdout.writeln('✓ Importación $importacionId terminada');
  } catch (e) {
    await db.cerrarImportacion(importacionId, {
      'estado': 'error',
      'mensaje': e.toString(),
    });
    rethrow;
  }
}

/// Baja [uri] a [destino] sin cargarlo en memoria. Devuelve el
/// Last-Modified del servidor, que identifica la versión publicada.
Future<String?> _descargar(Uri uri, File destino) async {
  final client = HttpClient()..userAgent = _userAgent;
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    if (res.statusCode != 200) {
      throw _ImportError('MEData respondió ${res.statusCode}.');
    }
    await res.pipe(destino.openWrite());
    return res.headers.value(HttpHeaders.lastModifiedHeader);
  } on SocketException catch (e) {
    throw _ImportError('No se pudo descargar el CSV: ${e.message}');
  } finally {
    client.close();
  }
}

class _Agregador {
  int leidas = 0;
  int sinComuna = 0;
  int omitidas = 0;
  String? fechaMin;
  String? fechaMax;

  /// comuna|modalidad|año|mes → total
  final porFecha = <String, int>{};

  /// comuna|año|díaSemana|hora → total
  final porHora = <String, int>{};

  static Future<_Agregador> desde(File archivo) async {
    final agg = _Agregador();
    final lineas = archivo
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    Map<String, int>? col;
    await for (final linea in lineas) {
      if (linea.isEmpty) continue;
      final campos = _parseCsv(linea);
      if (col == null) {
        col = {for (var i = 0; i < campos.length; i++) campos[i]: i};
        for (final c in ['fecha_hecho', 'codigo_comuna', 'modalidad']) {
          if (!col.containsKey(c)) {
            throw _ImportError('El CSV ya no trae la columna "$c".');
          }
        }
        continue;
      }
      agg._agregar(campos, col);
    }
    return agg;
  }

  void _agregar(List<String> campos, Map<String, int> col) {
    leidas++;
    String campo(String nombre) {
      final i = col[nombre]!;
      return i < campos.length ? campos[i].trim() : '';
    }

    // "2017-01-01T15:00:00.000-05:00": se toma la hora local tal cual.
    final f = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})')
        .firstMatch(campo('fecha_hecho'));
    if (f == null) {
      omitidas++;
      return;
    }
    final anio = int.parse(f[1]!);
    final mes = int.parse(f[2]!);
    final dia = int.parse(f[3]!);
    final hora = int.parse(f[4]!);
    if (mes < 1 || mes > 12 || hora > 23) {
      omitidas++;
      return;
    }

    final rawComuna = campo('codigo_comuna');
    if (rawComuna.toUpperCase() == 'SIN DATO' || rawComuna.isEmpty) {
      sinComuna++;
      return;
    }
    final comuna = rawComuna.padLeft(2, '0');
    if (!_comunas.contains(comuna)) {
      omitidas++;
      return;
    }

    var modalidad = campo('modalidad');
    if (modalidad.isEmpty) modalidad = 'Sin dato';
    modalidad = _modalidadCorregida[modalidad] ?? modalidad;

    final fecha = '${f[1]}-${f[2]}-${f[3]}T${f[4]}:${f[5]}:00';
    if (fechaMin == null || fecha.compareTo(fechaMin!) < 0) fechaMin = fecha;
    if (fechaMax == null || fecha.compareTo(fechaMax!) > 0) fechaMax = fecha;

    // weekday: 1 = lunes … 7 = domingo, igual que ISODOW en Postgres.
    final diaSemana = DateTime.utc(anio, mes, dia).weekday;

    porFecha.update('$comuna|$modalidad|$anio|$mes', (n) => n + 1,
        ifAbsent: () => 1);
    porHora.update('$comuna|$anio|$diaSemana|$hora', (n) => n + 1,
        ifAbsent: () => 1);
  }

  List<Map<String, dynamic>> filasMensuales(String fuente, int importacion) => [
        for (final e in porFecha.entries)
          if (e.key.split('|') case [final c, final m, final a, final mes])
            {
              'fuente_id': fuente,
              'comuna_codigo': c,
              'modalidad': m,
              'anio': int.parse(a),
              'mes': int.parse(mes),
              'total': e.value,
              'importacion_id': importacion,
            },
      ];

  List<Map<String, dynamic>> filasHorarias(String fuente, int importacion) => [
        for (final e in porHora.entries)
          if (e.key.split('|') case [final c, final a, final d, final h])
            {
              'fuente_id': fuente,
              'comuna_codigo': c,
              'anio': int.parse(a),
              'dia_semana': int.parse(d),
              'hora': int.parse(h),
              'total': e.value,
              'importacion_id': importacion,
            },
      ];
}

/// Una línea de CSV con campos opcionalmente entre comillas (la fuente
/// trae p.ej. "Dinero, joyas, piedras preciosas y título valor").
List<String> _parseCsv(String linea) {
  final campos = <String>[];
  final actual = StringBuffer();
  var entreComillas = false;
  for (var i = 0; i < linea.length; i++) {
    final ch = linea[i];
    if (entreComillas) {
      if (ch == '"') {
        if (i + 1 < linea.length && linea[i + 1] == '"') {
          actual.write('"');
          i++;
        } else {
          entreComillas = false;
        }
      } else {
        actual.write(ch);
      }
    } else if (ch == '"') {
      entreComillas = true;
    } else if (ch == ',') {
      campos.add(actual.toString());
      actual.clear();
    } else {
      actual.write(ch);
    }
  }
  campos.add(actual.toString());
  return campos;
}

// ── Supabase (PostgREST con la service role) ───────────────────────────

class _Supabase {
  _Supabase(this._url, String key, {required this.dryRun})
      : _headers = {
          'apikey': key,
          // Las llaves nuevas (sb_secret_…) no son JWT y van solo en apikey;
          // la service_role clásica (eyJ…) también va como Bearer.
          if (key.startsWith('eyJ')) 'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        };

  final String _url;
  final Map<String, String> _headers;
  final bool dryRun;
  final _http = http.Client();

  Uri _uri(String tabla, [Map<String, String>? query]) =>
      Uri.parse('$_url/rest/v1/$tabla').replace(queryParameters: query);

  void _check(http.Response res, String que) {
    if (res.statusCode >= 300) {
      throw _ImportError('$que: HTTP ${res.statusCode} ${res.body}');
    }
  }

  Future<int> crearImportacion(String fuente, String? version) async {
    if (dryRun) return 0;
    final res = await _http.post(
      _uri('seguridad_importaciones'),
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: jsonEncode({'fuente_id': fuente, 'version_fuente': version}),
    );
    _check(res, 'Crear importación');
    return (jsonDecode(res.body) as List).first['id'] as int;
  }

  Future<void> cerrarImportacion(int id, Map<String, dynamic> datos) => patch(
        'seguridad_importaciones',
        {'id': 'eq.$id'},
        {...datos, 'terminada_at': DateTime.now().toUtc().toIso8601String()},
      );

  Future<void> patch(
    String tabla,
    Map<String, String> filtro,
    Map<String, dynamic> datos,
  ) async {
    if (dryRun) return;
    final res = await _http.patch(
      _uri(tabla, filtro),
      headers: _headers,
      body: jsonEncode(datos),
    );
    _check(res, 'Actualizar $tabla');
  }

  Future<void> delete(String tabla, Map<String, String> filtro) async {
    if (dryRun) return;
    final res = await _http.delete(_uri(tabla, filtro), headers: _headers);
    _check(res, 'Limpiar $tabla');
  }

  Future<void> upsertEnLotes(
    String tabla,
    String onConflict,
    List<Map<String, dynamic>> filas,
  ) async {
    stdout.writeln('→ $tabla: ${filas.length} filas');
    if (dryRun) return;
    for (var i = 0; i < filas.length; i += _lote) {
      final lote = filas.sublist(i, (i + _lote).clamp(0, filas.length));
      final res = await _http.post(
        _uri(tabla, {'on_conflict': onConflict}),
        headers: {..._headers, 'Prefer': 'resolution=merge-duplicates'},
        body: jsonEncode(lote),
      );
      _check(res, 'Subir $tabla (filas $i–${i + lote.length})');
      stdout.write('\r  ${i + lote.length}/${filas.length}');
    }
    stdout.writeln();
  }

  void close() => _http.close();
}

class _ImportError implements Exception {
  _ImportError(this.message);
  final String message;
  @override
  String toString() => message;
}
