import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/suscripcion_model.dart';
import '../../data/subscription_repository.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/precio_cobro.dart';

/// `/suscripcion/resultado?pago_id=N` — resultado de un pago (TG-291).
/// Llega con el [ResultadoPago] ya calculado desde el formulario; si se
/// abre directo por URL (recarga, enlace), lo vuelve a consultar al
/// servidor por `pago_id` — nunca se toma un estado de la URL.
class PaymentResultScreen extends StatefulWidget {
  const PaymentResultScreen({super.key, this.pagoId, this.initial});

  final int? pagoId;
  final ResultadoPago? initial;

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();

  ResultadoPago? _resultado;
  bool _isLoading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _resultado = initial;
      _isLoading = false;
    } else {
      _confirm();
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final pagoId = widget.pagoId ?? _resultado?.pagoId;
      if (pagoId == null) throw const PaymentException('Sin pago_id');

      final resultado = await _repository.confirmarPago(pagoId);
      if (!mounted) return;
      setState(() {
        _resultado = resultado;
        _isLoading = false;
      });
      if (resultado.estado == EstadoPago.aprobado) {
        context.read<SubscriptionProvider>().refresh();
      }
    } catch (e, st) {
      debugPrint('PaymentResultScreen._confirm error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
                boxShadow: AppShadow.card,
              ),
              child: AnimatedSwitcher(
                duration: AppMotion.toggle,
                child: _isLoading ? _buildLoading() : _buildResult(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.ink),
        const SizedBox(height: 20),
        Text(context.l10n.paymentResultChecking, style: AppText.ui(14, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildResult() {
    final l10n = context.l10n;
    final resultado = _resultado;
    final estado = _failed ? null : resultado?.estado;

    final (IconData icon, Color color, String title, String body) = switch (estado) {
      EstadoPago.aprobado => (
          Icons.verified_rounded,
          AppColors.inkSoft,
          l10n.paymentResultApprovedTitle,
          resultado!.suscripcion == null
              ? l10n.paymentResultApprovedBodyNoDate
              : l10n.paymentResultApprovedBody(
                  DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(resultado.suscripcion!.fechaFin),
                ),
        ),
      EstadoPago.enProceso => (
          Icons.hourglass_top_rounded,
          AppColors.warning,
          l10n.paymentResultPendingTitle,
          l10n.paymentResultPendingBody,
        ),
      EstadoPago.rechazado => (
          Icons.credit_card_off_outlined,
          AppColors.error,
          l10n.paymentResultRejectedTitle,
          l10n.paymentResultRejectedBody,
        ),
      EstadoPago.pendiente || EstadoPago.cancelado || EstadoPago.reembolsado => (
          Icons.remove_shopping_cart_outlined,
          AppColors.textMuted,
          l10n.paymentResultCancelledTitle,
          l10n.paymentResultCancelledBody,
        ),
      null => (
          Icons.cloud_off_outlined,
          AppColors.error,
          l10n.paymentResultErrorTitle,
          l10n.paymentResultErrorBody,
        ),
    };

    return Column(
      key: ValueKey(estado),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 56, color: color),
        const SizedBox(height: 16),
        Text(title, style: AppText.display(26), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(body, style: AppText.ui(14, color: AppColors.textMuted), textAlign: TextAlign.center),
        if (resultado != null && !_failed) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.paperDeep,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  resultado.plan == PlanSuscripcion.anual
                      ? l10n.paymentResultPlanAnnual
                      : l10n.paymentResultPlanMonthly,
                  style: AppText.ui(13, weight: FontWeight.w600),
                ),
                Text(precioCobro(context, resultado.monto, conReferencia: false), style: AppText.ui(13, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(l10n.paymentResultReference(resultado.pagoId), style: AppText.label(10)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => estado == EstadoPago.aprobado ? context.go('/') : context.go('/suscripciones'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.paper,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
            child: Text(
              estado == EstadoPago.aprobado ? l10n.paymentResultGoHome : l10n.paymentResultBackToPlans,
              style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.paper),
            ),
          ),
        ),
        if (_failed || estado == EstadoPago.enProceso) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: _confirm, child: Text(l10n.paymentResultRetry)),
        ],
      ],
    );
  }
}
