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
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../../../widgets/segmented_pill.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _isAnnual = false;

  PlanSuscripcion get _plan =>
      _isAnnual ? PlanSuscripcion.anual : PlanSuscripcion.mensual;

  /// Lo que desbloquea Premium — exactamente lo que restringe
  /// `PremiumGate` (TG-298); si se agrega un beneficio, va en los dos.
  List<String> _benefits(BuildContext context) => [
    context.l10n.subscriptionsBenefitPromos,
    context.l10n.subscriptionsBenefitDailyAlerts,
    context.l10n.subscriptionsBenefitOverspendWarning,
    context.l10n.subscriptionsBenefitReminder,
    context.l10n.subscriptionsBenefitChecklist,
    context.l10n.subscriptionsBenefitEstimate,
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final l10n = context.l10n;
    final priceCop = _plan.precioCop;
    final formattedPrice = precioCobro(context, priceCop, conReferencia: false);
    final period = _isAnnual ? l10n.subscriptionsPeriodYear : l10n.subscriptionsPeriodMonth;

    Widget body({required bool desktop}) {
      final planCard = _PlanCard(
        name: l10n.subscriptionsPlanTouristName,
        subtitle: l10n.subscriptionsPlanTouristSubtitle,
        price: formattedPrice,
        period: period,
        features: _benefits(context),
        onSubscribe: () => _showSubscriptionDialog(context, l10n.subscriptionsPlanTouristName, priceCop),
      );
      final faq = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.subscriptionsFaqTitle, style: AppText.display(26)),
          const SizedBox(height: 18),
          _FAQItem(
            question: l10n.subscriptionsFaqChangePlanQuestion,
            answer: l10n.subscriptionsFaqChangePlanAnswer,
          ),
          const SizedBox(height: 12),
          _FAQItem(
            question: l10n.subscriptionsFaqFreeTrialQuestion,
            answer: l10n.subscriptionsFaqFreeTrialAnswer,
          ),
          const SizedBox(height: 12),
          _FAQItem(
            question: l10n.subscriptionsFaqPaymentMethodsQuestion,
            answer: l10n.subscriptionsFaqPaymentMethodsAnswer,
          ),
          const SizedBox(height: 22),
          Text(
            l10n.subscriptionsFooterNote.toUpperCase(),
            style: AppText.label(10, color: AppColors.textLabel),
          ),
        ],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivePlanBanner(),
          SizedBox(
            width: 340,
            child: SegmentedPill(
              labels: [l10n.subscriptionsBillingMonthly, l10n.subscriptionsBillingAnnual],
              index: _isAnnual ? 1 : 0,
              onChanged: (i) => setState(() => _isAnnual = i == 1),
            ),
          ),
          const SizedBox(height: 26),
          if (desktop)
            // Escritorio: plan y preguntas en dos columnas 1 : 1.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: planCard),
                const SizedBox(width: 22),
                Expanded(child: faq),
              ],
            )
          else ...[
            planCard,
            const SizedBox(height: 34),
            faq,
          ],
        ],
      );
    }

    final header = InkHeader(
      eyebrow: l10n.subscriptionsAppBarTitle,
      title: l10n.subscriptionsHeroTitle,
      titleAccent: l10n.subscriptionsHeroAccent,
      subtitle: l10n.subscriptionsHeaderSubtitle,
      asCard: true,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  InkHeader(
                    eyebrow: l10n.subscriptionsAppBarTitle,
                    title: l10n.subscriptionsHeroTitle,
                    titleAccent: l10n.subscriptionsHeroAccent,
                    subtitle: l10n.subscriptionsHeaderSubtitle,
                    // Se llega con `go` desde la barra lateral: puede no
                    // haber nada en la pila a qué volver.
                    onBack: () => context.canPop() ? context.pop() : context.go('/'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
                    child: body(desktop: false),
                  ),
                ],
              ),
            ),
          );
        }
        // Escritorio: dentro del shell, para que el atajo "Planes" de la
        // barra lateral no la haga desaparecer.
        return AppShell(
          section: AppSection.suscripciones,
          onNavigate: _handleSideNav,
          onCreateTrip: () => showCreateTripDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              body(desktop: constraints.maxWidth >= 1100),
            ],
          ),
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
      case AppSection.actividades:
        context.go('/actividades');
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
    if (suscripcion == null || !suscripcion.isActive) {
      return const SizedBox.shrink();
    }
    final fecha = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(suscripcion.fechaFin);
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final message = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.inkSoft),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  context.l10n.subscriptionsActivePlanBanner(fecha),
                  style: AppText.ui(14, weight: FontWeight.w600),
                ),
              ),
            ],
          );
          final button = InkButton(
            label: context.l10n.mySubscriptionManageButton,
            variant: InkButtonVariant.secondary,
            onPressed: () => context.go('/mi-suscripcion'),
          );
          // En teléfono el botón al lado dejaba el texto en una columna de
          // una palabra por línea; ahí va debajo.
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [message, const SizedBox(height: 12), button],
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: message),
              const SizedBox(width: 16),
              button,
            ],
          );
        },
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
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.l10n.subscriptionsDialogPlanTitle(planName),
          style: AppText.display(28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.subscriptionsDialogPriceLabel(price),
              style: AppText.ui(16, weight: FontWeight.w600, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.subscriptionsDialogBody,
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        actions: [
          InkButton(
            label: context.l10n.subscriptionsDialogCancelButton,
            variant: InkButtonVariant.secondary,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          InkButton(
            label: context.l10n.subscriptionsDialogContinueButton,
            trailingArrow: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              _openCardPayment();
            },
          ),
        ],
      ),
    );
  }
}

// ========== WIDGET: TARJETA DE PLAN ==========
/// Tarjeta del plan en `ink` (radio 28, sombra `raised`): es el único
/// fondo donde el handoff permite el acento `mint`.
class _PlanCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final String period;
  final List<String> features;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 28),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: AppShadow.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.workspace_premium_outlined, color: AppColors.ink, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: AppText.label(11, color: AppColors.mint, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(subtitle, style: AppText.display(26, color: AppColors.paper)),
          const SizedBox(height: 22),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Flexible(child: Text(price, style: AppText.display(44, color: AppColors.paper))),
              const SizedBox(width: 8),
              Text(period, style: AppText.ui(14, color: AppColors.textOnInk)),
            ],
          ),
          const SizedBox(height: 22),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.mint, size: 18),
                  const SizedBox(width: 12),
                  Expanded(child: Text(feature, style: AppText.ui(14, color: AppColors.paper))),
                ],
              ),
            ),
          const SizedBox(height: 14),
          InkButton(
            label: context.l10n.subscriptionsSubscribeButton,
            variant: InkButtonVariant.mint,
            trailingArrow: true,
            expand: true,
            onPressed: onSubscribe,
          ),
        ],
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
