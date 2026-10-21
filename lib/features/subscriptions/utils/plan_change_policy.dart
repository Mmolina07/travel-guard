import '../data/models/suscripcion_model.dart';

/// Qué pasa si el turista pide cambiar a otro plan (HU-23 CA3 / TG-295).
enum PlanChangeType {
  /// Ya tiene ese plan y no hay nada programado.
  none,

  /// Mensual → anual: se paga ahora y el anual empieza cuando termina
  /// lo ya pagado (no se pierde ningún día).
  upgrade,

  /// Anual → mensual: no se cobra nada; queda programado para la
  /// renovación.
  downgrade,

  /// Vuelve al plan que ya tiene: se quita el cambio programado.
  undoScheduled,

  /// La suscripción está cancelada o no está activa: primero hay que
  /// reactivarla.
  blocked,
}

/// Resultado de [decidePlanChange]: las condiciones del cambio, para
/// mostrarlas antes de confirmar y para ejecutarlo.
class PlanChangeDecision {
  const PlanChangeDecision({
    required this.type,
    required this.from,
    required this.to,
    this.chargeNow,
    this.effectiveFrom,
    this.effectiveUntil,
    this.renewalCost,
  });

  final PlanChangeType type;
  final PlanSuscripcion? from;
  final PlanSuscripcion to;

  /// COP que se cobran ahora (solo en [PlanChangeType.upgrade]).
  final double? chargeNow;

  /// Desde cuándo rige el plan nuevo: siempre al terminar lo ya pagado.
  final DateTime? effectiveFrom;

  /// Hasta cuándo queda cubierto si es un pago ([PlanChangeType.upgrade]).
  final DateTime? effectiveUntil;

  /// Lo que costará la siguiente renovación tras el cambio.
  final double? renewalCost;

  bool get requiresPayment => type == PlanChangeType.upgrade;
  bool get isScheduledChange =>
      type == PlanChangeType.downgrade || type == PlanChangeType.undoScheduled;
}

/// Meses que cubre cada plan (los mismos que aplica el trigger
/// `activar_premium_por_pago()` en la base de datos).
int mesesDelPlan(PlanSuscripcion plan) => plan == PlanSuscripcion.anual ? 12 : 1;

/// Reglas de negocio del cambio de plan (TG-295).
///
/// - Siempre se compara contra el **último** periodo pagado, que es el
///   que define la renovación.
/// - Subir a anual se cobra completo ahora y empieza al terminar lo ya
///   pagado: nunca se pisan días ya pagados ni se prorratea.
/// - Bajar a mensual no reembolsa nada: el anual se respeta hasta su fin
///   y la renovación pasa a costar el mensual.
/// - Con la suscripción cancelada no se cambia de plan (reactivar antes).
PlanChangeDecision decidePlanChange(EstadoSuscripcion estado, PlanSuscripcion target) {
  final ultimo = estado.ultimo;
  if (!estado.isActive || ultimo == null || estado.isCancelada) {
    return PlanChangeDecision(type: PlanChangeType.blocked, from: ultimo?.plan, to: target);
  }
  final fin = ultimo.fechaFin;

  if (target == ultimo.plan) {
    return PlanChangeDecision(
      type: ultimo.planSiguiente == null ? PlanChangeType.none : PlanChangeType.undoScheduled,
      from: ultimo.plan,
      to: target,
      effectiveFrom: fin,
      renewalCost: target.precioCop,
    );
  }

  if (mesesDelPlan(target) > mesesDelPlan(ultimo.plan)) {
    return PlanChangeDecision(
      type: PlanChangeType.upgrade,
      from: ultimo.plan,
      to: target,
      chargeNow: target.precioCop,
      effectiveFrom: fin,
      effectiveUntil: DateTime(fin.year, fin.month + mesesDelPlan(target), fin.day, fin.hour, fin.minute),
      renewalCost: target.precioCop,
    );
  }

  return PlanChangeDecision(
    type: PlanChangeType.downgrade,
    from: ultimo.plan,
    to: target,
    effectiveFrom: fin,
    renewalCost: target.precioCop,
  );
}
