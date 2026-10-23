import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/seguridad_stats.dart';

/// Una sola serie por gráfica (la comuna): un solo color de marca, sin
/// leyenda — el título de la tarjeta dice qué se mide.
const _serie = AppColors.inkSoft;

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

FlGridData _grid(double interval) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (_) =>
          const FlLine(color: AppColors.line, strokeWidth: 1),
    );

/// Paso "redondo" del eje Y para ~4 líneas de cuadrícula.
double _intervalo(int maximo) {
  if (maximo <= 4) return 1;
  final bruto = maximo / 4;
  final base = math.pow(10, (math.log(bruto) / math.ln10).floor()).toDouble();
  for (final m in const [1, 2, 2.5, 5, 10]) {
    if (bruto <= base * m) return base * m;
  }
  return base * 10;
}

AxisTitles _ejeY(BuildContext context, double intervalo) {
  final compacto = NumberFormat.compact(locale: _locale(context));
  return AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 40,
      interval: intervalo,
      getTitlesWidget: (value, meta) {
        if (value == meta.max && value % intervalo != 0) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          child: Text(compacto.format(value), style: AppText.label(9)),
        );
      },
    ),
  );
}

const _sinTitulos = AxisTitles(sideTitles: SideTitles(showTitles: false));

/// Registros por año (barras).
class AnnualBarChart extends StatelessWidget {
  const AnnualBarChart({super.key, required this.puntos});

  final List<PuntoEvolucion> puntos;

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) return const SizedBox.shrink();
    final maximo = puntos.fold<int>(0, (m, p) => math.max(m, p.total));
    final intervalo = _intervalo(maximo);
    final numero = NumberFormat.decimalPattern(_locale(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        // Etiquetas del eje X sin chocar: cada 2, 4 o 5 años según el ancho.
        final porEtiqueta = constraints.maxWidth / math.max(puntos.length, 1);
        final cada = porEtiqueta >= 34 ? 1 : porEtiqueta >= 17 ? 2 : 4;
        final ancho = (porEtiqueta * 0.62).clamp(4.0, 22.0);
        return SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maximo == 0 ? 1 : maximo * 1.08,
              gridData: _grid(intervalo),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: _ejeY(context, intervalo),
                rightTitles: _sinTitulos,
                topTitles: _sinTitulos,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final anio = value.toInt();
                      final ultimo = puntos.last.periodo.year;
                      if ((ultimo - anio) % cada != 0) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('$anio', style: AppText.label(9)),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.ink,
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    '${group.x}\n',
                    AppText.label(10, color: AppColors.textOnInk),
                    children: [
                      TextSpan(
                        text: numero.format(rod.toY),
                        style: AppText.ui(
                          13,
                          weight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              barGroups: [
                for (final p in puntos)
                  BarChartGroupData(
                    x: p.periodo.year,
                    barRods: [
                      BarChartRodData(
                        toY: p.total.toDouble(),
                        color: _serie,
                        width: ancho,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Registros por mes (línea).
class MonthlyLineChart extends StatelessWidget {
  const MonthlyLineChart({super.key, required this.puntos});

  final List<PuntoEvolucion> puntos;

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) return const SizedBox.shrink();
    final maximo = puntos.fold<int>(0, (m, p) => math.max(m, p.total));
    final intervalo = _intervalo(maximo);
    final locale = _locale(context);
    final numero = NumberFormat.decimalPattern(locale);
    final mesAnio = DateFormat.yMMM(locale);
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(puntos.length - 1, 1).toDouble(),
          minY: 0,
          maxY: maximo == 0 ? 1 : maximo * 1.1,
          gridData: _grid(intervalo),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: _ejeY(context, intervalo),
            rightTitles: _sinTitulos,
            topTitles: _sinTitulos,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  // Una etiqueta por año, en enero.
                  if (i < 0 ||
                      i >= puntos.length ||
                      value != i ||
                      puntos[i].periodo.month != 1) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${puntos[i].periodo.year}',
                      style: AppText.label(9),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${mesAnio.format(puntos[s.x.toInt()].periodo)}\n',
                    AppText.label(10, color: AppColors.textOnInk),
                    children: [
                      TextSpan(
                        text: numero.format(s.y),
                        style: AppText.ui(
                          13,
                          weight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            getTouchedSpotIndicator: (_, indexes) => [
              for (final _ in indexes)
                const TouchedSpotIndicatorData(
                  FlLine(color: AppColors.hair, strokeWidth: 1),
                  FlDotData(),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < puntos.length; i++)
                  FlSpot(i.toDouble(), puntos[i].total.toDouble()),
              ],
              color: _serie,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _serie.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
