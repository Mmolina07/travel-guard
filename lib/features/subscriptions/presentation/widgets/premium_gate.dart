import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/subscription_provider.dart';

/// HU-24 / TG-298: validador de acceso a funciones Premium. Muestra
/// [child] solo si el usuario tiene una suscripción vigente; si no, en
/// su lugar va una invitación a suscribirse que lleva a `/suscripciones`.
///
/// Mientras se consulta la suscripción no se muestra la invitación (un
/// Premium la vería parpadear al abrir la pantalla).
///
/// [compact] es para restringir una tarjeta dentro de otra pantalla
/// (p. ej. las alertas del presupuesto diario en el detalle del viaje);
/// sin él, la invitación ocupa la vista completa.
class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.icon = Icons.workspace_premium_outlined,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    if (subscription.isPremium) return child;
    if (subscription.isLoading) {
      return compact
          ? const SizedBox.shrink()
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
            );
    }
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.inkSoft, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.ui(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description, style: AppText.ui(12.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _SubscribeButton(compact: true),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            boxShadow: AppShadow.raised,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.mint, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.premiumGateBadge,
                style: AppText.label(11, color: AppColors.mint, weight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppText.display(28, color: AppColors.paper),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppText.ui(14, color: AppColors.textOnInk),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              for (final benefit in [
                l10n.subscriptionsBenefitPromos,
                l10n.subscriptionsBenefitDailyAlerts,
                l10n.subscriptionsBenefitReminder,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.mint, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(benefit, style: AppText.ui(13.5, color: AppColors.paper))),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: _SubscribeButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.push('/suscripciones'),
      style: ElevatedButton.styleFrom(
        backgroundColor: compact ? AppColors.ink : AppColors.mint,
        foregroundColor: compact ? AppColors.paper : AppColors.ink,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: compact ? 12 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
      child: Text(
        compact ? context.l10n.premiumGateCompactButton : context.l10n.premiumGateButton,
        style: AppText.ui(13.5, weight: FontWeight.w700, color: compact ? AppColors.paper : AppColors.ink),
      ),
    );
  }
}
