import 'package:flutter/material.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/change_subscription_plan.dart';

class SubscriptionProvider with ChangeNotifier {
  final ChangeSubscriptionPlanUseCase _changePlanUseCase = ChangeSubscriptionPlanUseCase();

  // Plan activo por defecto (ejemplo: Plan Gratuito)
  SubscriptionPlan _currentPlan = SubscriptionPlan(
    id: 'plan_free',
    name: 'Plan Gratuito',
    tier: PlanTier.free,
    priceMonth: 0.0,
    level: 1,
    features: ['Acceso básico', 'Límite de 3 viajes'],
  );

  bool _isLoading = false;
  String? _errorMessage;

  SubscriptionPlan get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Modifica o procesa el cambio de plan
  Future<bool> changePlan(SubscriptionPlan targetPlan, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _changePlanUseCase.execute(
        userId: userId,
        currentPlan: _currentPlan,
        targetPlan: targetPlan,
      );

      if (success) {
        _currentPlan = targetPlan;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}