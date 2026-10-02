import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../core/settings/currency_provider.dart';
import '../../../../core/utils/money_formatter.dart';

/// Precio de un plan tal como se cobra: siempre en COP (Mercado Pago
/// cobra en pesos). Si el usuario eligió otra moneda en Configuración,
/// se agrega la conversión solo como referencia — antes se mostraba
/// únicamente el monto convertido y parecía que se cobraba en dólares.
String precioCobro(BuildContext context, num amountCop, {bool conReferencia = true}) {
  final cop = '${formatCOP(amountCop)} COP';
  final currency = context.read<CurrencyProvider>();
  if (!conReferencia || currency.currency == CurrencyProvider.defaultCurrency) return cop;
  return '$cop (≈ ${currency.format(amountCop)})';
}
