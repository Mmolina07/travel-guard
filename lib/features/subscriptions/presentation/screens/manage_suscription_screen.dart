import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/change_subscription_plan.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final currentPlan = subscriptionProvider.currentPlan;

    // Lista de planes disponibles para selección
    final List<SubscriptionPlan> availablePlans = [
      SubscriptionPlan(
        id: 'plan_free',
        name: 'Plan Gratuito',
        tier: PlanTier.free,
        priceMonth: 0.0,
        level: 1,
        features: ['Acceso a mapas', 'Hasta 3 viajes'],
      ),
      SubscriptionPlan(
        id: 'plan_basic',
        name: 'Plan Básico',
        tier: PlanTier.basic,
        priceMonth: 15000.0,
        level: 2,
        features: ['Viajes ilimitados', 'Alertas de presupuesto'],
      ),
      SubscriptionPlan(
        id: 'plan_premium',
        name: 'Plan Premium',
        tier: PlanTier.premium,
        priceMonth: 35000.0,
        level: 3,
        features: ['Todo lo Básico', 'Soporte prioritario', 'Sin publicidad'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Suscripción'),
      ),
      body: subscriptionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Actual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      title: Text(
                        currentPlan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('\$${currentPlan.priceMonth.toStringAsFixed(0)} COP / mes'),
                      trailing: const Chip(
                        label: Text('Activo'),
                        backgroundColor: Colors.blue,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cambiar de Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availablePlans.length,
                      itemBuilder: (context, index) {
                        final plan = availablePlans[index];
                        final isCurrent = plan.tier == currentPlan.tier;
                        final isUpgrade = plan.level > currentPlan.level;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            title: Text(plan.name),
                            subtitle: Text('\$${plan.priceMonth.toStringAsFixed(0)} COP / mes'),
                            trailing: isCurrent
                                ? const Text('En uso', style: TextStyle(color: Colors.grey))
                                : ElevatedButton(
                                    onPressed: () => _confirmPlanChange(
                                      context,
                                      subscriptionProvider,
                                      currentPlan,
                                      plan,
                                      isUpgrade,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isUpgrade ? Colors.green : Colors.orange,
                                    ),
                                    child: Text(
                                      isUpgrade ? 'Upgrade' : 'Downgrade',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _confirmPlanChange(
    BuildContext context,
    SubscriptionProvider provider,
    SubscriptionPlan current,
    SubscriptionPlan target,
    bool isUpgrade,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUpgrade ? 'Confirmar Upgrade' : 'Confirmar Downgrade'),
        content: Text(
          isUpgrade
              ? '¿Deseas subir al ${target.name}? Los nuevos beneficios se aplicarán de inmediato.'
              : '¿Deseas bajar al ${target.name}? El cambio se aplicará al finalizar tu ciclo de facturación actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await provider.changePlan(target, 'user_123');
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUpgrade
                          ? '¡Upgrade exitoso! Bienvenido al ${target.name}.'
                          : 'Downgrade programado para el siguiente ciclo.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}