enum PlanTier { free, basic, premium, pro }

class SubscriptionPlan {
  final String id;
  final String name;
  final PlanTier tier;
  final double priceMonth;
  final int level; // 1: Free, 2: Basic, 3: Premium, 4: Pro
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.priceMonth,
    required this.level,
    required this.features,
  });
}