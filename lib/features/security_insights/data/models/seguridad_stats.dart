/// Modelos de las funciones `seguridad_*` de Supabase
/// (docs/db/hu_seguridad_medellin_estadisticas.sql). Todos los números son
/// conteos reales de la fuente oficial; aquí no se calcula nada.
library;

int _toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

DateTime? _toDate(dynamic v) => v == null ? null : DateTime.tryParse('$v');

/// Total de hurtos registrados en una comuna durante el período.
class ComunaTotal {
  final String codigo;
  final String nombre;
  final bool esCorregimiento;
  final int total;

  const ComunaTotal({
    required this.codigo,
    required this.nombre,
    required this.esCorregimiento,
    required this.total,
  });

  factory ComunaTotal.fromRow(Map<String, dynamic> row) => ComunaTotal(
        codigo: row['codigo'] as String,
        nombre: row['nombre'] as String,
        esCorregimiento: row['tipo'] == 'corregimiento',
        total: _toInt(row['total']),
      );
}

/// Nivel del índice según los umbrales de `seguridad_config`.
enum NivelIncidencia {
  bajo,
  medio,
  alto,
  muyAlto;

  static NivelIncidencia fromDb(String? v) => switch (v) {
        'muy_alto' => muyAlto,
        'alto' => alto,
        'medio' => medio,
        _ => bajo,
      };
}

/// "Índice histórico de incidencia delictiva" de una comuna: posición
/// percentil (0–100) de sus registros dentro de su grupo (comunas o
/// corregimientos). Método en docs/seguridad/indice_incidencia.md.
class ComunaIndice {
  final String codigo;
  final String nombre;
  final bool esCorregimiento;
  final int total;

  /// % de los registros de su grupo en el período.
  final double participacion;

  /// 1 = la de más registros de su grupo; de [tamanoGrupo].
  final int posicion;
  final int tamanoGrupo;
  final int indice;
  final NivelIncidencia nivel;

  const ComunaIndice({
    required this.codigo,
    required this.nombre,
    required this.esCorregimiento,
    required this.total,
    required this.participacion,
    required this.posicion,
    required this.tamanoGrupo,
    required this.indice,
    required this.nivel,
  });

  factory ComunaIndice.fromRow(Map<String, dynamic> row) => ComunaIndice(
        codigo: row['codigo'] as String,
        nombre: row['nombre'] as String,
        esCorregimiento: row['tipo'] == 'corregimiento',
        total: _toInt(row['total']),
        participacion: _toDouble(row['participacion']),
        posicion: _toInt(row['posicion']),
        tamanoGrupo: _toInt(row['tamano_grupo']),
        indice: _toInt(row['indice']),
        nivel: NivelIncidencia.fromDb(row['nivel'] as String?),
      );
}

/// Modalidad del hurto (atraco, descuido, cosquilleo…) con su peso.
class ModalidadTotal {
  final String modalidad;
  final int total;

  /// 0–100, sobre el total de la comuna (o de la ciudad) en el período.
  final double porcentaje;

  const ModalidadTotal({
    required this.modalidad,
    required this.total,
    required this.porcentaje,
  });

  factory ModalidadTotal.fromRow(Map<String, dynamic> row) => ModalidadTotal(
        modalidad: row['modalidad'] as String,
        total: _toInt(row['total']),
        porcentaje: _toDouble(row['porcentaje']),
      );
}

enum Granularidad { mes, anio }

/// Un punto de la serie de tiempo: primer día del mes o del año.
class PuntoEvolucion {
  final DateTime periodo;
  final int total;

  const PuntoEvolucion({required this.periodo, required this.total});

  factory PuntoEvolucion.fromRow(Map<String, dynamic> row) => PuntoEvolucion(
        periodo: _toDate(row['periodo'])!,
        total: _toInt(row['total']),
      );
}

/// Celda de la matriz día de la semana × hora reportada.
class CeldaDiaHora {
  /// 1 = lunes … 7 = domingo (igual que `DateTime.weekday`).
  final int diaSemana;

  /// 0–23, hora local de Medellín reportada por la víctima.
  final int hora;
  final int total;

  const CeldaDiaHora({
    required this.diaSemana,
    required this.hora,
    required this.total,
  });

  factory CeldaDiaHora.fromRow(Map<String, dynamic> row) => CeldaDiaHora(
        diaSemana: _toInt(row['dia_semana']),
        hora: _toInt(row['hora']),
        total: _toInt(row['total']),
      );
}

/// Fuente, período configurado y última importación: lo que la app cita
/// junto a cualquier cifra ("Fuente: … · 2021–2023").
class SeguridadMetadatos {
  final String fuenteNombre;
  final String publicador;
  final String urlDatos;
  final String? licencia;

  /// La fuente trae hora del hecho: habilita el análisis día × hora.
  final bool tieneHora;
  final DateTime periodoInicio;
  final DateTime periodoFin;

  /// Rangos de color del índice (0–100), configurables en `seguridad_config`.
  final int umbralMedio;
  final int umbralAlto;
  final int umbralMuyAlto;

  /// Rango real de los datos importados; `null` si aún no se ha importado.
  final DateTime? datosDesde;
  final DateTime? datosHasta;
  final DateTime? importadoAt;

  const SeguridadMetadatos({
    required this.fuenteNombre,
    required this.publicador,
    required this.urlDatos,
    required this.licencia,
    required this.tieneHora,
    required this.periodoInicio,
    required this.periodoFin,
    required this.umbralMedio,
    required this.umbralAlto,
    required this.umbralMuyAlto,
    required this.datosDesde,
    required this.datosHasta,
    required this.importadoAt,
  });

  bool get hayDatos => importadoAt != null;

  factory SeguridadMetadatos.fromRow(Map<String, dynamic> row) =>
      SeguridadMetadatos(
        fuenteNombre: row['fuente_nombre'] as String,
        publicador: row['publicador'] as String,
        urlDatos: row['url_datos'] as String,
        licencia: row['licencia'] as String?,
        tieneHora: row['tiene_hora'] as bool? ?? false,
        periodoInicio: _toDate(row['periodo_inicio'])!,
        periodoFin: _toDate(row['periodo_fin'])!,
        umbralMedio: _toInt(row['umbral_medio']),
        umbralAlto: _toInt(row['umbral_alto']),
        umbralMuyAlto: _toInt(row['umbral_muy_alto']),
        datosDesde: _toDate(row['datos_desde']),
        datosHasta: _toDate(row['datos_hasta']),
        importadoAt: _toDate(row['importado_at']),
      );
}
