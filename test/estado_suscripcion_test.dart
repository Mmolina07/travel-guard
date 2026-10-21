import 'package:flutter_test/flutter_test.dart';
import 'package:travelguard/features/subscriptions/data/models/suscripcion_model.dart';

Suscripcion periodo(int id, PlanSuscripcion plan, DateTime inicio, DateTime fin,
        {DateTime? canceladaAt, PlanSuscripcion? siguiente}) =>
    Suscripcion(
      id: id,
      usuarioId: 1,
      plan: plan,
      estado: 'activa',
      fechaInicio: inicio,
      fechaFin: fin,
      canceladaAt: canceladaAt,
      planSiguiente: siguiente,
    );

void main() {
  final hoy = DateTime.now();
  final d = (int dias) => hoy.add(Duration(days: dias));

  test('sin periodos vigentes no es Premium (HU-23)', () {
    final e = EstadoSuscripcion([
      periodo(1, PlanSuscripcion.mensual, d(-40), d(-10)),
    ]);
    expect(e.isActive, isFalse);
    expect(e.actual, isNull);
  });

  test('periodo actual, periodos ya pagados y fecha de renovación (CA1/CA2)', () {
    final e = EstadoSuscripcion([
      periodo(2, PlanSuscripcion.anual, d(20), d(385)),
      periodo(1, PlanSuscripcion.mensual, d(-10), d(20)),
    ]);
    expect(e.actual!.id, 1);
    expect(e.siguientes.map((p) => p.id), [2]);
    expect(e.fechaRenovacion, d(385));
    expect(e.planRenovacion, PlanSuscripcion.anual);
    expect(e.puedeRenovar, isFalse);
  });

  test('plan programado al renovar (CA3)', () {
    final e = EstadoSuscripcion([
      periodo(1, PlanSuscripcion.anual, d(-300), d(5), siguiente: PlanSuscripcion.mensual),
    ]);
    expect(e.planRenovacion, PlanSuscripcion.mensual);
    expect(e.diasRestantes, 5);
    expect(e.puedeRenovar, isTrue);
  });

  test('cancelada: sigue activa pero no ofrece renovar (CA4)', () {
    final e = EstadoSuscripcion([
      periodo(1, PlanSuscripcion.mensual, d(-25), d(5), canceladaAt: d(-1)),
    ]);
    expect(e.isActive, isTrue);
    expect(e.isCancelada, isTrue);
    expect(e.puedeRenovar, isFalse);
  });
}
