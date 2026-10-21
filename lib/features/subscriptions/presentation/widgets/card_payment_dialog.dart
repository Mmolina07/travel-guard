import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/pressable.dart';
import '../../data/models/suscripcion_model.dart';
import '../../data/models/tarjeta_model.dart';
import '../../data/subscription_repository.dart';
import 'precio_cobro.dart';

/// TG-291: formulario de pago con tarjeta. Los datos se tokenizan
/// directo con Mercado Pago y solo el token viaja a la Edge Function que
/// cobra. Devuelve el [ResultadoPago] (aprobado, rechazado o en proceso)
/// o `null` si el usuario cancela.
class CardPaymentDialog extends StatefulWidget {
  const CardPaymentDialog({super.key, required this.usuarioId, required this.plan});

  final int usuarioId;
  final PlanSuscripcion plan;

  static Future<ResultadoPago?> show(
    BuildContext context, {
    required int usuarioId,
    required PlanSuscripcion plan,
  }) {
    return showDialog<ResultadoPago>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CardPaymentDialog(usuarioId: usuarioId, plan: plan),
    );
  }

  @override
  State<CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<CardPaymentDialog> {
  static const _tiposDocumento = ['CC', 'CE', 'NIT', 'PAS'];

  final _formKey = GlobalKey<FormState>();
  final _numero = TextEditingController();
  final _titular = TextEditingController();
  final _vencimiento = TextEditingController();
  final _codigo = TextEditingController();
  final _documento = TextEditingController();
  final SubscriptionRepository _repository = SubscriptionRepository();

  String _tipoDocumento = 'CC';
  bool _isPaying = false;
  String? _error;

  MarcaTarjeta? get _marca => MarcaTarjeta.detectar(_numero.text);

  @override
  void dispose() {
    for (final c in [_numero, _titular, _vencimiento, _codigo, _documento]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final (mes, anio) = parseVencimiento(_vencimiento.text)!;

    setState(() => _isPaying = true);
    try {
      final resultado = await _repository.pagarConTarjeta(
        usuarioId: widget.usuarioId,
        plan: widget.plan,
        tarjeta: DatosTarjeta(
          numero: soloDigitos(_numero.text),
          titular: _titular.text.trim(),
          mesVencimiento: mes,
          anioVencimiento: anio,
          codigoSeguridad: _codigo.text.trim(),
          tipoDocumento: _tipoDocumento,
          numeroDocumento: soloDigitos(_documento.text),
        ),
      );
      if (mounted) Navigator.pop(context, resultado);
    } catch (e, st) {
      debugPrint('CardPaymentDialog._pay error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _error = context.l10n.cardPaymentError;
      });
    }
  }

  /// El relleno, radio y bordes los da el tema global
  /// (`AppTheme.light().inputDecorationTheme`).
  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) =>
      InputDecoration(labelText: label, hintText: hint, suffixIcon: suffix);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final marca = _marca;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.cardPaymentTitle, style: AppText.display(28))),
                    _CloseButton(onTap: _isPaying ? null : () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.cardPaymentSummary(
                    widget.plan == PlanSuscripcion.anual ? l10n.paymentResultPlanAnnual : l10n.paymentResultPlanMonthly,
                    precioCobro(context, widget.plan.precioCop),
                  ),
                  style: AppText.ui(14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                _buildTestModeHint(),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _numero,
                  enabled: !_isPaying,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardNumber],
                  inputFormatters: [_CardNumberFormatter()],
                  onChanged: (_) => setState(() {}),
                  decoration: _decoration(
                    l10n.cardPaymentNumberLabel,
                    hint: '0000 0000 0000 0000',
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        widthFactor: 1,
                        child: Text(marca?.nombre ?? '', style: AppText.ui(12, weight: FontWeight.w700, color: AppColors.inkSoft)),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (!numeroTarjetaValido(v ?? '')) return l10n.cardPaymentNumberInvalid;
                    if (MarcaTarjeta.detectar(v ?? '') == null) return l10n.cardPaymentBrandUnsupported;
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _titular,
                  enabled: !_isPaying,
                  textCapitalization: TextCapitalization.characters,
                  autofillHints: const [AutofillHints.creditCardName],
                  // Solo letras: un titular no lleva números ni símbolos.
                  inputFormatters: [
                    AppInputFormatters.personName,
                    AppInputFormatters.maxLength(60),
                  ],
                  decoration: _decoration(l10n.cardPaymentHolderLabel, hint: l10n.cardPaymentHolderHint),
                  validator: (v) {
                    if ((v ?? '').trim().length < 3) return l10n.cardPaymentHolderInvalid;
                    return Validators.personName(context, v, max: 60) == null
                        ? null
                        : l10n.valCardHolder;
                  },
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vencimiento,
                        enabled: !_isPaying,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.creditCardExpirationDate],
                        inputFormatters: [_ExpiryFormatter()],
                        decoration: _decoration(l10n.cardPaymentExpiryLabel, hint: 'MM/AA'),
                        validator: (v) => parseVencimiento(v ?? '') == null ? l10n.cardPaymentExpiryInvalid : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _codigo,
                        enabled: !_isPaying,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.creditCardSecurityCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: _decoration(l10n.cardPaymentCvvLabel, hint: '123'),
                        validator: (v) {
                          final digitos = marca?.digitosCodigo ?? 3;
                          return (v ?? '').length != digitos ? l10n.cardPaymentCvvInvalid(digitos) : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 104,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoDocumento,
                        decoration: _decoration(l10n.cardPaymentDocTypeLabel),
                        items: [
                          for (final t in _tiposDocumento) DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: _isPaying ? null : (v) => setState(() => _tipoDocumento = v ?? 'CC'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _documento,
                        enabled: !_isPaying,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: _decoration(l10n.cardPaymentDocNumberLabel),
                        validator: (v) {
                          final length = (v ?? '').length;
                          return length < 5 || length > 12 ? l10n.valDocLength : null;
                        },
                      ),
                    ),
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: AppText.ui(12, color: AppColors.error)),
                ],
                const SizedBox(height: 22),
                InkButton(
                  label: _isPaying
                      ? l10n.cardPaymentProcessing
                      : l10n.cardPaymentPayButton(precioCobro(context, widget.plan.precioCop, conReferencia: false)),
                  icon: Icons.lock_outline,
                  trailingArrow: true,
                  expand: true,
                  loading: _isPaying,
                  onPressed: _pay,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(l10n.cardPaymentSecureNote, style: AppText.label(10), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ayuda para la demo: Mercado Pago está en modo de prueba, así que
  /// solo funcionan sus tarjetas de prueba.
  Widget _buildTestModeHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningWash,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.cardPaymentTestModeHint,
              style: AppText.ui(12, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// `4013540682746260` → `4013 5406 8274 6260`.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = soloDigitos(newValue.text);
    final limited = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// `1130` → `11/30`.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = soloDigitos(newValue.text);
    if (digits.length > 4) digits = digits.substring(0, 4);
    final deleting = newValue.text.length < oldValue.text.length;
    final text = digits.length > 2 || (digits.length == 2 && !deleting)
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Botón cerrar del modal (34×34, radio 12, borde `line`).
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.close, size: 18, color: AppColors.ink),
      ),
    );
  }
}
