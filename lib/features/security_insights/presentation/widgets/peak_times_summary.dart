import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/seguridad_stats.dart';
import '../incidencia_style.dart';
import 'day_hour_heatmap.dart' show diaCorto;

/// Franjas horarias y días de la semana con más registros, a partir de la
/// matriz día × hora. Lo usan la ficha de la comuna y el histórico.
class PeakTimesSummary extends StatelessWidget {
  const PeakTimesSummary({
    super.key,
    required this.celdas,
    this.franjas = 3,
    this.color = AppColors.inkSoft,
  });

  final List<CeldaDiaHora> celdas;

  /// Cuántas franjas mostrar (de mayor a menor).
  final int franjas;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = celdas.fold<int>(0, (s, c) => s + c.total);
    if (total == 0) return const SizedBox.shrink();

    final top = [...celdas]..sort((a, b) => b.total.compareTo(a.total));
    final porDia = List<int>.filled(7, 0);
    for (final c in celdas) {
      porDia[c.diaSemana - 1] += c.total;
    }
    final maxDia = porDia.reduce((a, b) => a > b ? a : b);

    String franja(CeldaDiaHora c) {
      final h = c.hora.toString().padLeft(2, '0');
      final h2 = ((c.hora + 1) % 24).toString().padLeft(2, '0');
      return '${diaCorto(context, c.diaSemana)} $h:00–$h2:00';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.securityTopSlots.toUpperCase(), style: AppText.label(10)),
        const SizedBox(height: 10),
        for (final c in top.take(franjas))
          _Barra(
            nombre: franja(c),
            valor: c.total,
            total: total,
            color: color,
          ),
        const SizedBox(height: 10),
        Text(l10n.securityByWeekday.toUpperCase(), style: AppText.label(10)),
        const SizedBox(height: 10),
        for (var d = 1; d <= 7; d++)
          _Barra(
            nombre: diaCorto(context, d),
            valor: porDia[d - 1],
            total: total,
            color: color,
            destacado: porDia[d - 1] == maxDia,
          ),
      ],
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.nombre,
    required this.valor,
    required this.total,
    required this.color,
    this.destacado = false,
  });

  final String nombre;
  final int valor;
  final int total;
  final Color color;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : 100 * valor / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: AppText.ui(
                    13,
                    weight: destacado ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${formatoEntero(context, valor)} · ${pct.toStringAsFixed(1)} %',
                style: AppText.label(10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1),
              minHeight: 6,
              color: color,
              backgroundColor: AppColors.paperDeep,
            ),
          ),
        ],
      ),
    );
  }
}
