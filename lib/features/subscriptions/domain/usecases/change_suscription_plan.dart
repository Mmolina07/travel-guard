import '../entities/subscription_plan.dart';

enum PlanChangeType { upgrade, downgrade, samePlan }

class ChangeSubscriptionPlanUseCase {
  /// Evalúa el tipo de cambio entre el plan actual y el plan destino
  PlanChangeType getChangeType(SubscriptionPlan currentPlan, SubscriptionPlan targetPlan) {
    if (currentPlan.tier == targetPlan.tier) {
      return PlanChangeType.samePlan;
    }
    return targetPlan.level > currentPlan.level
        ? PlanChangeType.upgrade
        : PlanChangeType.downgrade;
  }

  /// Ejecuta la lógica de negocio de procesamiento del cambio
  Future<bool> execute({
    required String userId,
    required SubscriptionPlan currentPlan,
    required SubscriptionPlan targetPlan,
  }) async {
    final changeType = getChangeType(currentPlan, targetPlan);

    if (changeType == PlanChangeType.samePlan) {
      throw Exception('Actualmente ya tienes activo este plan.');
    }

    if (changeType == PlanChangeType.upgrade) {
      // Regla Upgrade: Cobro inmediato / Habilitar características superiores al instante
      return await _processUpgrade(userId, targetPlan);
    } else {
      // Regla Downgrade: Programar cambio para la fecha de renovación del ciclo de facturación
      return await _processDowngrade(userId, targetPlan);
    }
  }

  Future<bool> _processUpgrade(String userId, SubscriptionPlan targetPlan) async {
    // Aquí se conecta con el repositorio / API REST de backend
    await Future.delayed(const Duration(milliseconds: 800)); // Simulación de petición
    return true;
  }

  Future<bool> _processDowngrade(String userId, SubscriptionPlan targetPlan) async {
    // Aquí se conecta con la API para registrar la bajada de plan al final del periodo
    await Future.delayed(const Duration(milliseconds: 800)); // Simulación de petición
    return true;
  }
}