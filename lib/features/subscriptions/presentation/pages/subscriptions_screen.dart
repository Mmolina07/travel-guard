import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../trips/presentation/pages/create_trip_screen.dart';
import '../../data/models/suscripcion_model.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/card_payment_dialog.dart';
import '../widgets/precio_cobro.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late bool _isAnnual;
  late String _selectedPlan;

  PlanSuscripcion get _plan =>
      _isAnnual ? PlanSuscripcion.anual : PlanSuscripcion.mensual;

  /// Lo que desbloquea Premium — exactamente lo que restringe
  /// `PremiumGate` (TG-298); si se agrega un beneficio, va en los dos.
  List<String> _benefits(BuildContext context) => [
    context.l10n.subscriptionsBenefitPromos,
    context.l10n.subscriptionsBenefitDailyAlerts,
    context.l10n.subscriptionsBenefitOverspendWarning,
    context.l10n.subscriptionsBenefitReminder,
  ];

  @override
  void initState() {
    super.initState();
    _isAnnual = false;
    _selectedPlan = 'turista'; // Plan seleccionado por defecto
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final isMobile = MediaQuery.of(context).size.width < 600;
    final priceCop = _plan.precioCop;
    final formattedPrice = precioCobro(context, priceCop, conReferencia: false);
    final period = _isAnnual
        ? context.l10n.subscriptionsPeriodYear
        : context.l10n.subscriptionsPeriodMonth;

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ========== HEADER ==========
            Text(
              context.l10n.subscriptionsHeaderTitle,
              style: AppText.display(28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.subscriptionsHeaderSubtitle,
              style: AppText.ui(15, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildActivePlanBanner(),

            // ========== TOGGLE: MENSUAL / ANUAL ==========
            Container(
              decoration: BoxDecoration(
                color: AppColors.wash,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BillingToggle(
                    label: context.l10n.subscriptionsBillingMonthly,
                    isSelected: !_isAnnual,
                    onTap: () {
                      setState(() {
                        _isAnnual = false;
                      });
                    },
                  ),
                  _BillingToggle(
                    label: context.l10n.subscriptionsBillingAnnual,
                    isSelected: _isAnnual,
                    onTap: () {
                      setState(() {
                        _isAnnual = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ========== PLANES ==========
            isMobile
                ? Column(
                    children: [
                      _PlanCard(
                        name: context.l10n.subscriptionsPlanTouristName,
                        subtitle: context.l10n.subscriptionsPlanTouristSubtitle,
                        price: formattedPrice,
                        period: period,
                        color: AppColors.mint,
                        features: _benefits(context),
                        isSelected: _selectedPlan == 'turista',
                        onTap: () {
                          setState(() {
                            _selectedPlan = 'turista';
                          });
                          _showSubscriptionDialog(
                            context,
                            context.l10n.subscriptionsPlanTouristName,
                            priceCop,
                          );
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _PlanCard(
                          name: context.l10n.subscriptionsPlanTouristName,
                          subtitle:
                              context.l10n.subscriptionsPlanTouristSubtitle,
                          price: formattedPrice,
                          period: period,
                          color: AppColors.mint,
                          features: _benefits(context),
                          isSelected: _selectedPlan == 'turista',
                          onTap: () {
                            setState(() {
                              _selectedPlan = 'turista';
                            });
                            _showSubscriptionDialog(
                              context,
                              context.l10n.subscriptionsPlanTouristName,
                              priceCop,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 48),

            // ========== FAQ ==========
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.subscriptionsFaqTitle,
                  style: AppText.display(20),
                ),
                const SizedBox(height: 20),
                _FAQItem(
                  question: context.l10n.subscriptionsFaqChangePlanQuestion,
                  answer: context.l10n.subscriptionsFaqChangePlanAnswer,
                ),
                const SizedBox(height: 12),
                _FAQItem(
                  question: context.l10n.subscriptionsFaqFreeTrialQuestion,
                  answer: context.l10n.subscriptionsFaqFreeTrialAnswer,
                ),
                const SizedBox(height: 12),
                _FAQItem(
                  question: context.l10n.subscriptionsFaqPaymentMethodsQuestion,
                  answer: context.l10n.subscriptionsFaqPaymentMethodsAnswer,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // ========== FOOTER ==========
            Center(
              child: Text(
                context.l10n.subscriptionsFooterNote,
                style: AppText.label(
                  10,
                  weight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                // Se llega con `go` desde la barra lateral: puede no
                // haber nada en la pila a qué volver.
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
              title: Text(
                context.l10n.subscriptionsAppBarTitle,
                style: AppText.ui(18, weight: FontWeight.w600),
              ),
              backgroundColor: AppColors.paper,
              elevation: 0,
              foregroundColor: AppColors.ink,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: content,
            ),
          );
        }
        // Escritorio: dentro del shell, para que el atajo "Planes" de la
        // barra lateral no la haga desaparecer.
        return AppShell(
          section: AppSection.suscripciones,
          onNavigate: _handleSideNav,
          onCreateTrip: () => showCreateTripDialog(context),
          child: content,
        );
      },
    );
  }

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        context.go('/');
        break;
      case AppSection.comercios:
        context.go('/comercios');
        break;
      case AppSection.mapa:
        context.go('/mapa');
        break;
      case AppSection.promociones:
        context.go('/promociones');
        break;
      case AppSection.suscripciones:
        break; // ya estamos aquí.
    }
  }

  /// Plan vigente, si ya es Premium — pagar de nuevo extiende la fecha
  /// de fin en vez de reemplazarla (ver `activarSuscripcion` en
  /// `supabase/functions/_shared/mercadopago.ts`).
  Widget _buildActivePlanBanner() {
    final suscripcion = context.watch<SubscriptionProvider>().suscripcion;
    if (suscripcion == null || !suscripcion.isActive)
      return const SizedBox.shrink();
    final fecha = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(suscripcion.fechaFin);
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.mint),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              context.l10n.subscriptionsActivePlanBanner(fecha),
              style: AppText.ui(
                14,
                weight: FontWeight.w600,
                color: AppColors.paper,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TG-291: formulario de tarjeta → Mercado Pago → pantalla de
  /// resultado (aprobado / rechazado / en proceso).
  Future<void> _openCardPayment() async {
    final usuarioId = context.read<AppAuthProvider>().usuario?.id;
    if (usuarioId == null) return;
    final resultado = await CardPaymentDialog.show(
      context,
      usuarioId: usuarioId,
      plan: _plan,
    );
    if (resultado == null || !mounted) return;
    if (resultado.estado == EstadoPago.aprobado) {
      context.read<SubscriptionProvider>().refresh();
    }
    context.go(
      '/suscripcion/resultado?pago_id=${resultado.pagoId}',
      extra: resultado,
    );
  }

  void _showSubscriptionDialog(
    BuildContext context,
    String planName,
    num priceCop,
  ) {
    final price = precioCobro(context, priceCop);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          context.l10n.subscriptionsDialogPlanTitle(planName),
          style: AppText.display(18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.subscriptionsDialogPriceLabel(price),
              style: AppText.ui(
                16,
                weight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.subscriptionsDialogBody,
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.subscriptionsDialogCancelButton,
              style: AppText.ui(14, color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openCardPayment();
            },
            child: Text(
              context.l10n.subscriptionsDialogContinueButton,
              style: AppText.ui(
                14,
                color: AppColors.inkSoft,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== WIDGET: TOGGLE DE FACTURACIÓN ==========
class _BillingToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BillingToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.control),
          boxShadow: isSelected ? AppShadow.card : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          label,
          style: AppText.ui(
            13,
            weight: FontWeight.w600,
            color: isSelected ? AppColors.inkSoft : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ========== WIDGET: TARJETA DE PLAN ==========
class _PlanCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final String period;
  final Color color;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? color : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadow.raised : AppShadow.card,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.display(22, color: color)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppText.ui(12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Precio
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(price, style: AppText.display(32, color: color)),
                const SizedBox(width: 8),
                Text(period, style: AppText.ui(14, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 24),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? color : AppColors.wash,
                  foregroundColor: isSelected ? AppColors.surface : color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isSelected
                      ? context.l10n.subscriptionsPlanSelectedButton
                      : context.l10n.subscriptionsPlanSelectButton,
                  style: AppText.ui(13, weight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Características
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 18),
                      const SizedBox(width: 12),
                      Expanded(child: Text(feature, style: AppText.ui(13))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET: ITEM FAQ ==========
class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    // `Material` (no un `Container` decorado): el `ListTile` interno de
    // `ExpansionTile` pinta su fondo e ink sobre el `Material` más
    // cercano, y una caja con color encima lo tapaba (assertion
    // "ListTile background color or ink splashes may be invisible").
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.line),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(question, style: AppText.ui(14, weight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
