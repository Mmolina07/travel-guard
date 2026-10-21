/// Planes que se pueden pagar (HU-22), en COP. El monto que se cobra lo
/// define el servidor (`PLANES` en `supabase/functions/_shared/
/// mercadopago.ts`); estos deben coincidir y son solo para mostrar.
enum PlanSuscripcion {
  mensual(9900),
  anual(95000);

  const PlanSuscripcion(this.precioCop);
  final double precioCop;

  static PlanSuscripcion fromName(String name) =>
      PlanSuscripcion.values.firstWhere((p) => p.name == name, orElse: () => PlanSuscripcion.mensual);
}

/// Fila de `suscripciones` (HU-22 / HU-24). La crea únicamente la Edge
/// Function cuando Mercado Pago aprueba el pago.
class Suscripcion {
  final int id;
  final int usuarioId;
  final PlanSuscripcion plan;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  /// HU-23: si el usuario canceló la renovación (sigue teniendo acceso
  /// hasta [fechaFin]).
  final DateTime? canceladaAt;

  /// HU-23: plan al que pasa al renovar (cambio anual → mensual).
  final PlanSuscripcion? planSiguiente;

  const Suscripcion({
    required this.id,
    required this.usuarioId,
    required this.plan,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    this.canceladaAt,
    this.planSiguiente,
  });

  factory Suscripcion.fromMap(Map<String, dynamic> map) => Suscripcion(
        id: map['id'] as int,
        usuarioId: map['usuario_id'] as int,
        plan: PlanSuscripcion.fromName(map['plan'] as String),
        estado: map['estado'] as String,
        fechaInicio: DateTime.parse(map['fecha_inicio'] as String).toLocal(),
        fechaFin: DateTime.parse(map['fecha_fin'] as String).toLocal(),
        canceladaAt: map['cancelada_at'] == null
            ? null
            : DateTime.parse(map['cancelada_at'] as String).toLocal(),
        planSiguiente: map['plan_siguiente'] == null
            ? null
            : PlanSuscripcion.fromName(map['plan_siguiente'] as String),
      );

  bool get isActive => estado == 'activa' && fechaFin.isAfter(DateTime.now());
  bool get isCancelada => canceladaAt != null;
}

/// HU-23: la suscripción como la ve el usuario. Un pago hecho siendo ya
/// Premium crea otro periodo que empieza cuando termina el anterior
/// (trigger `activar_premium_por_pago`), así que "la suscripción" es la
/// cadena de periodos vigentes, ordenados por inicio.
class EstadoSuscripcion {
  EstadoSuscripcion(List<Suscripcion> periodos, {DateTime? ahora})
      : periodos = List.unmodifiable(
          [...periodos.where((p) => p.isActive)]
            ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio)),
        ),
        _ahora = ahora ?? DateTime.now();

  final List<Suscripcion> periodos;
  final DateTime _ahora;

  bool get isActive => periodos.isNotEmpty;

  /// El periodo que cubre hoy (o el primero, si por desfase de reloj
  /// todavía no empezó).
  Suscripcion? get actual {
    if (periodos.isEmpty) return null;
    return periodos.firstWhere(
      (p) => !p.fechaInicio.isAfter(_ahora),
      orElse: () => periodos.first,
    );
  }

  /// Periodos ya pagados que empiezan después del actual.
  List<Suscripcion> get siguientes =>
      periodos.where((p) => p.id != actual?.id).toList();

  /// El último periodo: define cuándo termina el Premium y guarda la
  /// cancelación y el plan programado.
  Suscripcion? get ultimo => periodos.isEmpty ? null : periodos.last;

  DateTime? get fechaRenovacion => ultimo?.fechaFin;
  bool get isCancelada => ultimo?.isCancelada ?? false;

  /// Plan con el que se renueva: el programado o el del último periodo.
  PlanSuscripcion? get planRenovacion => ultimo?.planSiguiente ?? ultimo?.plan;

  int get diasRestantes {
    final fin = fechaRenovacion;
    if (fin == null) return 0;
    final dias = fin.difference(_ahora).inHours / 24;
    return dias <= 0 ? 0 : dias.ceil();
  }

  /// Faltan 7 días o menos y no canceló: se ofrece renovar.
  bool get puedeRenovar => isActive && !isCancelada && diasRestantes <= 7;
}

/// Fila de `pagos` para el historial de "Mi suscripción".
class PagoResumen {
  final int id;
  final PlanSuscripcion plan;
  final double monto;
  final EstadoPago estado;
  final DateTime fecha;

  const PagoResumen({
    required this.id,
    required this.plan,
    required this.monto,
    required this.estado,
    required this.fecha,
  });

  factory PagoResumen.fromMap(Map<String, dynamic> map) => PagoResumen(
        id: map['id'] as int,
        plan: PlanSuscripcion.fromName(map['plan'] as String),
        monto: (map['monto'] as num).toDouble(),
        estado: EstadoPago.fromDb(map['estado'] as String),
        fecha: DateTime.parse(map['created_at'] as String).toLocal(),
      );
}

/// Estado de un pago según `pagos.estado`.
enum EstadoPago {
  pendiente,
  enProceso,
  aprobado,
  rechazado,
  cancelado,
  reembolsado;

  static EstadoPago fromDb(String value) => switch (value) {
        'en_proceso' => EstadoPago.enProceso,
        'aprobado' => EstadoPago.aprobado,
        'rechazado' => EstadoPago.rechazado,
        'cancelado' => EstadoPago.cancelado,
        'reembolsado' => EstadoPago.reembolsado,
        _ => EstadoPago.pendiente,
      };
}

/// Respuesta de `mp-confirmar-pago`.
class ResultadoPago {
  final int pagoId;
  final PlanSuscripcion plan;
  final double monto;
  final EstadoPago estado;
  final Suscripcion? suscripcion;

  const ResultadoPago({
    required this.pagoId,
    required this.plan,
    required this.monto,
    required this.estado,
    this.suscripcion,
  });

  factory ResultadoPago.fromMap(Map<String, dynamic> map) {
    final pago = map['pago'] as Map<String, dynamic>;
    final suscripcion = map['suscripcion'] as Map<String, dynamic>?;
    return ResultadoPago(
      pagoId: pago['id'] as int,
      plan: PlanSuscripcion.fromName(pago['plan'] as String),
      monto: (pago['monto'] as num).toDouble(),
      estado: EstadoPago.fromDb(pago['estado'] as String),
      suscripcion: suscripcion == null ? null : Suscripcion.fromMap(suscripcion),
    );
  }
}
