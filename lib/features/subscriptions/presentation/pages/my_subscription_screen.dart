import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/form_section_card.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../../trips/presentation/pages/create_trip_screen.dart';
import '../../data/models/suscripcion_model.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/card_payment_dialog.dart';
import '../widgets/precio_cobro.dart';
import '../../utils/plan_change_policy.dart';

/// HU-23 (TG-269): consultar, cambiar o cancelar la suscripción activa.
///
/// - CA1/CA2: plan, estado y fecha de renovación (fin del último periodo
///   pagado — la renovación es manual, no hay débito automático).
/// - CA3: mensual → anual se paga ahora y empieza al terminar lo ya
///   pagado; anual → mensual queda programado para la renovación.
/// - CA4: cancelar mantiene el acceso hasta el final del periodo.
class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  late Future<List<PagoResumen>> _pagosFuture;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pagosFuture = context.read<SubscriptionProvider>().fetchPagos();
  }

  String _date(DateTime d) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

  String _planLabel(PlanSuscripcion plan) => plan == PlanSuscripcion.anual
      ? context.l10n.paymentResultPlanAnnual
      : context.l10n.paymentResultPlanMonthly;

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      debugPrint('MySubscriptionScreen action error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.mySubscriptionActionError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Diálogo de confirmación con las condiciones del cambio.
  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    bool danger = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: AppText.display(28)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(body, style: AppText.ui(14, color: AppColors.textMuted)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        actions: [
          InkButton(
            label: cancelLabel,
            variant: InkButtonVariant.secondary,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          InkButton(
            label: confirmLabel,
            variant: danger ? InkButtonVariant.danger : InkButtonVariant.primary,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// Paga [plan] con tarjeta; el periodo se suma al final de lo pagado.
  Future<void> _pay(PlanSuscripcion plan) async {
    final usuarioId = context.read<SubscriptionProvider>().usuarioId;
    if (usuarioId == null) return;
    final resultado = await CardPaymentDialog.show(context, usuarioId: usuarioId, plan: plan);
    if (resultado == null || !mounted) return;
    if (resultado.estado == EstadoPago.aprobado) {
      context.read<SubscriptionProvider>().refresh();
    }
    context.go('/suscripcion/resultado?pago_id=${resultado.pagoId}', extra: resultado);
  }

  /// HU-23 CA3: las condiciones las decide [decidePlanChange] (TG-295);
  /// aquí solo se muestran, se confirman y se ejecutan.
  Future<void> _changePlan(EstadoSuscripcion estado, PlanSuscripcion target) async {
    final l10n = context.l10n;
    final provider = context.read<SubscriptionProvider>();
    final decision = decidePlanChange(estado, target);

    switch (decision.type) {
      case PlanChangeType.none:
      case PlanChangeType.blocked:
        return;
      case PlanChangeType.undoScheduled:
        await _run(() => provider.programarPlan(target), l10n.mySubscriptionChangeUndoneSnackbar);
      case PlanChangeType.upgrade:
        final ok = await _confirm(
          title: l10n.mySubscriptionUpgradeDialogTitle,
          body: l10n.mySubscriptionUpgradeDialogBody(
            precioCobro(context, decision.chargeNow!),
            _date(decision.effectiveFrom!),
            _date(decision.effectiveUntil!),
          ),
          confirmLabel: l10n.mySubscriptionUpgradeConfirm,
          cancelLabel: l10n.subscriptionsDialogCancelButton,
        );
        if (ok && mounted) await _pay(target);
      case PlanChangeType.downgrade:
        final ok = await _confirm(
          title: l10n.mySubscriptionDowngradeDialogTitle,
          body: l10n.mySubscriptionDowngradeDialogBody(
            _date(decision.effectiveFrom!),
            precioCobro(context, decision.renewalCost!),
          ),
          confirmLabel: l10n.mySubscriptionDowngradeConfirm,
          cancelLabel: l10n.subscriptionsDialogCancelButton,
        );
        if (!ok || !mounted) return;
        await _run(
          () => provider.programarPlan(target),
          l10n.mySubscriptionChangeScheduledSnackbar(_planLabel(target)),
        );
    }
  }

  /// "$9.900 / mes" o "$95.000 / año".
  String _cost(PlanSuscripcion plan) => context.l10n.mySubscriptionCostValue(
        precioCobro(context, plan.precioCop, conReferencia: false),
        plan == PlanSuscripcion.anual
            ? context.l10n.subscriptionsPeriodYear
            : context.l10n.subscriptionsPeriodMonth,
      );

  Future<void> _cancel(EstadoSuscripcion estado) async {
    final l10n = context.l10n;
    final fin = _date(estado.fechaRenovacion!);
    final ok = await _confirm(
      title: l10n.mySubscriptionCancelDialogTitle,
      body: l10n.mySubscriptionCancelBody(fin),
      confirmLabel: l10n.mySubscriptionCancelConfirm,
      cancelLabel: l10n.mySubscriptionCancelKeep,
      danger: true,
    );
    if (!ok || !mounted) return;
    await _run(
      () => context.read<SubscriptionProvider>().cancelar(),
      l10n.mySubscriptionCancelledSnackbar(fin),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final provider = context.watch<SubscriptionProvider>();
    final estado = provider.estado;
    final l10n = context.l10n;

    Widget body({required bool wide}) {
      if (provider.isLoading && !estado.isActive) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (!estado.isActive) {
        return EmptyStateCard(
          icon: Icons.workspace_premium_outlined,
          title: l10n.mySubscriptionEmptyTitle,
          subtitle: l10n.mySubscriptionEmptySubtitle,
          action: InkButton(
            label: l10n.mySubscriptionSeePlans,
            trailingArrow: true,
            onPressed: () => context.go('/suscripciones'),
          ),
        );
      }
      final left = [
        if (estado.puedeRenovar) ...[_buildRenewBanner(estado), const SizedBox(height: 22)],
        _buildDetails(estado),
        const SizedBox(height: 22),
        _buildChangePlan(estado),
      ];
      final right = [
        _buildCancel(estado),
        const SizedBox(height: 22),
        _buildHistory(),
      ];
      final content = wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(children: left)),
                const SizedBox(width: 22),
                Expanded(flex: 2, child: Column(children: right)),
              ],
            )
          : Column(children: [...left, const SizedBox(height: 22), ...right]);
      return AnimatedOpacity(
        opacity: _busy ? 0.5 : 1,
        duration: AppMotion.pressIn,
        child: IgnorePointer(ignoring: _busy, child: content),
      );
    }

    InkHeader header({required bool asCard, VoidCallback? onBack}) {
      final actual = estado.actual;
      return InkHeader(
        eyebrow: l10n.mySubscriptionTitle,
        title: l10n.mySubscriptionHeroTitle,
        titleAccent: actual == null ? null : _planLabel(actual.plan),
        asCard: asCard,
        onBack: onBack,
        bottom: actual == null ? null : _buildHeaderStats(estado),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  header(
                    asCard: false,
                    onBack: () => context.canPop() ? context.pop() : context.go('/configuracion'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
                    child: body(wide: false),
                  ),
                ],
              ),
            ),
          );
        }
        return AppShell(
          section: AppSection.suscripciones,
          onNavigate: _handleSideNav,
          onCreateTrip: () => showCreateTripDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(asCard: true),
              body(wide: constraints.maxWidth >= 1100),
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
      case AppSection.comercios:
        context.go('/comercios');
      case AppSection.mapa:
        context.go('/mapa');
      case AppSection.actividades:
        context.go('/actividades');
        break;
      case AppSection.promociones:
        context.go('/promociones');
      case AppSection.suscripciones:
        context.go('/suscripciones');
    }
  }

  // ---------------------------------------------------------------- UI

  Widget _buildHeaderStats(EstadoSuscripcion estado) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusChip(cancelled: estado.isCancelada),
        const SizedBox(height: 22),
        Wrap(
          spacing: 34,
          runSpacing: 14,
          children: [
            _HeaderStat(
              label: estado.isCancelada ? l10n.mySubscriptionStatEnds : l10n.mySubscriptionStatRenewal,
              value: _date(estado.fechaRenovacion!),
            ),
            _HeaderStat(
              label: l10n.mySubscriptionStatCost,
              value: _cost(estado.actual!.plan),
            ),
            _HeaderStat(
              label: l10n.mySubscriptionStatDaysLeft,
              value: '${estado.diasRestantes}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRenewBanner(EstadoSuscripcion estado) {
    final l10n = context.l10n;
    final plan = estado.planRenovacion!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.mySubscriptionRenewSoon(estado.diasRestantes),
            style: AppText.ui(14, weight: FontWeight.w600),
          ),
          InkButton(
            label: l10n.mySubscriptionRenewNow(_planLabel(plan)),
            trailingArrow: true,
            onPressed: () => _pay(plan),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(EstadoSuscripcion estado) {
    final l10n = context.l10n;
    final actual = estado.actual!;
    final fin = _date(estado.fechaRenovacion!);
    return FormSectionCard(
      title: l10n.mySubscriptionDetailsTitle,
      children: [
        _InfoRow(label: l10n.mySubscriptionRowPlan, value: _planLabel(actual.plan)),
        _InfoRow(label: l10n.mySubscriptionRowCost, value: _cost(actual.plan)),
        _InfoRow(
          label: l10n.mySubscriptionRowStatus,
          value: estado.isCancelada ? l10n.mySubscriptionStatusCancelled : l10n.mySubscriptionStatusActive,
        ),
        _InfoRow(
          label: l10n.mySubscriptionRowPeriod,
          value: l10n.mySubscriptionPeriodRange(_date(actual.fechaInicio), _date(actual.fechaFin)),
        ),
        _InfoRow(
          label: estado.isCancelada ? l10n.mySubscriptionStatEnds : l10n.mySubscriptionRowRenewalDate,
          value: fin,
        ),
        _InfoRow(
          label: l10n.mySubscriptionRowRenewalMode,
          value: estado.isCancelada
              ? l10n.mySubscriptionRenewalCancelled(fin)
              : l10n.mySubscriptionRenewalManual,
        ),
        if (!estado.isCancelada && estado.ultimo!.planSiguiente != null)
          _InfoRow(
            label: l10n.mySubscriptionRowNextPlan,
            value: _planLabel(estado.ultimo!.planSiguiente!),
          ),
        if (!estado.isCancelada)
          _InfoRow(
            label: l10n.mySubscriptionRowRenewalCost,
            value: l10n.mySubscriptionRenewalCostValue(
              fin,
              precioCobro(context, estado.planRenovacion!.precioCop, conReferencia: false),
            ),
          ),
        if (estado.siguientes.isNotEmpty)
          _InfoRow(
            label: l10n.mySubscriptionRowPrepaid,
            value: estado.siguientes
                .map((p) => '${_planLabel(p.plan)}: ${l10n.mySubscriptionPeriodRange(_date(p.fechaInicio), _date(p.fechaFin))}')
                .join('\n'),
            last: true,
          ),
      ],
    );
  }

  Widget _buildChangePlan(EstadoSuscripcion estado) {
    final l10n = context.l10n;
    final ultimo = estado.ultimo!;
    final programado = ultimo.planSiguiente;
    return FormSectionCard(
      title: l10n.mySubscriptionChangeTitle,
      subtitle: estado.isCancelada ? l10n.mySubscriptionChangeCancelledHint : l10n.mySubscriptionChangeSubtitle,
      children: [
        for (final plan in PlanSuscripcion.values) ...[
          _PlanOption(
            label: _planLabel(plan),
            price: precioCobro(context, plan.precioCop, conReferencia: false),
            period: plan == PlanSuscripcion.anual ? l10n.subscriptionsPeriodYear : l10n.subscriptionsPeriodMonth,
            badge: plan == ultimo.plan && programado == null
                ? l10n.mySubscriptionCurrentBadge
                : plan == programado
                    ? l10n.mySubscriptionScheduledBadge
                    : null,
            actionLabel: switch (decidePlanChange(estado, plan).type) {
              PlanChangeType.upgrade => l10n.mySubscriptionUpgradeButton,
              PlanChangeType.downgrade => l10n.mySubscriptionDowngradeButton,
              PlanChangeType.undoScheduled => l10n.mySubscriptionKeepPlan(_planLabel(plan)),
              // Cancelada: se muestra el botón deshabilitado como pista.
              PlanChangeType.blocked when plan != ultimo.plan => plan == PlanSuscripcion.anual
                  ? l10n.mySubscriptionUpgradeButton
                  : l10n.mySubscriptionDowngradeButton,
              _ => null,
            },
            onAction: estado.isCancelada ? null : () => _changePlan(estado, plan),
          ),
          if (plan != PlanSuscripcion.values.last) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCancel(EstadoSuscripcion estado) {
    final l10n = context.l10n;
    final fin = _date(estado.fechaRenovacion!);
    if (estado.isCancelada) {
      return FormSectionCard(
        title: l10n.mySubscriptionCancelledTitle,
        subtitle: l10n.mySubscriptionRenewalCancelled(fin),
        children: [
          InkButton(
            label: l10n.mySubscriptionReactivateButton,
            icon: Icons.replay_rounded,
            expand: true,
            loading: _busy,
            onPressed: () => _run(
              () => context.read<SubscriptionProvider>().reactivar(),
              l10n.mySubscriptionReactivatedSnackbar,
            ),
          ),
        ],
      );
    }
    return FormSectionCard(
      title: l10n.mySubscriptionCancelTitle,
      subtitle: l10n.mySubscriptionCancelBody(fin),
      children: [
        InkButton(
          label: l10n.mySubscriptionCancelTitle,
          icon: Icons.cancel_outlined,
          variant: InkButtonVariant.danger,
          expand: true,
          onPressed: () => _cancel(estado),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final l10n = context.l10n;
    return FormSectionCard(
      title: l10n.mySubscriptionHistoryTitle,
      children: [
        FutureBuilder<List<PagoResumen>>(
          future: _pagosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final pagos = snapshot.data ?? const <PagoResumen>[];
            if (snapshot.hasError || pagos.isEmpty) {
              return Text(
                snapshot.hasError ? l10n.mySubscriptionHistoryError : l10n.mySubscriptionHistoryEmpty,
                style: AppText.ui(13, color: AppColors.textMuted),
              );
            }
            return Column(
              children: [
                for (final (i, pago) in pagos.indexed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: i == pagos.length - 1
                          ? null
                          : const Border(bottom: BorderSide(color: AppColors.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_planLabel(pago.plan), style: AppText.ui(14, weight: FontWeight.w600)),
                              Text(
                                '${_date(pago.fecha)} · #${pago.id}'.toUpperCase(),
                                style: AppText.label(10),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              precioCobro(context, pago.monto, conReferencia: false),
                              style: AppText.label(12, color: AppColors.inkSoft, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            _PaymentStatusTag(estado: pago.estado),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Fila clave-valor (14 `textMuted` / 14 w600), separadas por `line`.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppText.ui(14, color: AppColors.textMuted))),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.end, style: AppText.ui(14, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Opción de plan dentro de "Cambiar de plan" (`paperDeep` radio 18).
class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.label,
    required this.price,
    required this.period,
    this.badge,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final String price;
  final String period;
  final String? badge;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badge != null ? AppColors.wash : AppColors.paperDeep,
        borderRadius: BorderRadius.circular(AppRadius.dateField),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    badge!.toUpperCase(),
                    style: AppText.label(10, color: AppColors.inkSoft, weight: FontWeight.w700),
                  ),
                ),
              Text(label, style: AppText.ui(15, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: price, style: AppText.display(24, color: AppColors.inkSoft)),
                    TextSpan(text: ' $period', style: AppText.ui(13, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            InkButton(
              label: actionLabel!,
              variant: InkButtonVariant.secondary,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.cancelled});

  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cancelled ? AppColors.paper.withValues(alpha: 0.12) : AppColors.mint,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        (cancelled ? context.l10n.mySubscriptionStatusCancelled : context.l10n.mySubscriptionStatusActive)
            .toUpperCase(),
        style: AppText.label(10,
            weight: FontWeight.w700, color: cancelled ? AppColors.textOnInk : AppColors.ink),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.label(10, color: AppColors.textOnInk)),
        const SizedBox(height: 4),
        Text(value, style: AppText.display(28, color: AppColors.paper)),
      ],
    );
  }
}

class _PaymentStatusTag extends StatelessWidget {
  const _PaymentStatusTag({required this.estado});

  final EstadoPago estado;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, bg, fg) = switch (estado) {
      EstadoPago.aprobado => (l10n.paymentStatusApproved, AppColors.wash, AppColors.inkSoft),
      EstadoPago.enProceso => (l10n.paymentStatusInProcess, AppColors.warningWash, AppColors.warning),
      EstadoPago.pendiente => (l10n.paymentStatusPending, AppColors.paperDeep, AppColors.textMuted),
      EstadoPago.rechazado => (l10n.paymentStatusRejected, AppColors.errorWash, AppColors.error),
      EstadoPago.cancelado => (l10n.paymentStatusCancelled, AppColors.paperDeep, AppColors.textMuted),
      EstadoPago.reembolsado => (l10n.paymentStatusRefunded, AppColors.paperDeep, AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.chip)),
      child: Text(label.toUpperCase(), style: AppText.label(9, color: fg, weight: FontWeight.w700)),
    );
  }
}
