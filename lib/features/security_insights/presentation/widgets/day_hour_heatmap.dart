import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/seguridad_stats.dart';
import '../incidencia_style.dart';

/// Escala secuencial de un solo tono (claro → petróleo) para magnitud.
/// Arranca en 8 % para que el valor mínimo no se confunda con "sin datos".
Color _escala(double t) =>
    Color.lerp(AppColors.wash, AppColors.ink, 0.08 + 0.92 * t.clamp(0, 1))!;

/// Nombre corto del día ISO (1 = lunes) en el idioma de la app.
String diaCorto(BuildContext context, int iso) => DateFormat.E(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime(2024, 1, iso)); // 2024-01-01 fue lunes.

String _hora(int h) => '${h.toString().padLeft(2, '0')}:00';

/// Matriz día de la semana × hora reportada. Cada celda muestra su valor
/// exacto al pasar el mouse o mantenerla presionada.
class DayHourHeatmap extends StatelessWidget {
  const DayHourHeatmap({super.key, required this.celdas});

  final List<CeldaDiaHora> celdas;

  @override
  Widget build(BuildContext context) {
    final valores = <(int, int), int>{
      for (final c in celdas) (c.diaSemana, c.hora): c.total,
    };
    final maximo = celdas.fold<int>(0, (m, c) => math.max(m, c.total));
    const etiquetaDia = 34.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lado = ((constraints.maxWidth - etiquetaDia) / 24).clamp(8.0, 28.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var d = 1; d <= 7; d++)
              Row(
                children: [
                  SizedBox(
                    width: etiquetaDia,
                    child: Text(diaCorto(context, d), style: AppText.label(9)),
                  ),
                  for (var h = 0; h < 24; h++)
                    _Celda(
                      lado: lado,
                      valor: valores[(d, h)] ?? 0,
                      maximo: maximo,
                      tooltip: context.l10n.securityCellTooltip(
                        diaCorto(context, d),
                        _hora(h),
                        formatoEntero(context, valores[(d, h)] ?? 0),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: etiquetaDia),
                for (var h = 0; h < 24; h++)
                  SizedBox(
                    width: lado,
                    child: h % 6 == 0
                        ? Text('$h', style: AppText.label(9))
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _Leyenda(maximo: maximo),
          ],
        );
      },
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({
    required this.lado,
    required this.valor,
    required this.maximo,
    required this.tooltip,
  });

  final double lado;
  final int valor;
  final int maximo;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 150),
      child: Container(
        width: lado,
        height: lado,
        // 2 px de separación entre celdas.
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: valor == 0 || maximo == 0
                ? AppColors.paperDeep
                : _escala(valor / maximo),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.maximo});

  final int maximo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Text(l10n.securityDayHourFewer, style: AppText.label(9)),
        const SizedBox(width: 8),
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [_escala(0), _escala(1)]),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${l10n.securityDayHourMore} (${formatoEntero(context, maximo)})',
          style: AppText.label(9),
        ),
      ],
    );
  }
}
