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

  const Suscripcion({
    required this.id,
    required this.usuarioId,
    required this.plan,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory Suscripcion.fromMap(Map<String, dynamic> map) => Suscripcion(
        id: map['id'] as int,
        usuarioId: map['usuario_id'] as int,
        plan: PlanSuscripcion.fromName(map['plan'] as String),
        estado: map['estado'] as String,
        fechaInicio: DateTime.parse(map['fecha_inicio'] as String).toLocal(),
        fechaFin: DateTime.parse(map['fecha_fin'] as String).toLocal(),
      );

  bool get isActive => estado == 'activa' && fechaFin.isAfter(DateTime.now());
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
