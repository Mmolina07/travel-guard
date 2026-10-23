import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/form_section_card.dart';
import '../../../../widgets/ink_header.dart';
import '../../../../widgets/load_error_box.dart';
import '../../../trips/presentation/pages/create_trip_screen.dart';
import '../../data/models/seguridad_stats.dart';
import '../../providers/security_map_provider.dart';
import '../incidencia_style.dart';
import '../widgets/day_hour_heatmap.dart';
import '../widgets/incidencia_charts.dart';
import '../widgets/peak_times_summary.dart';

/// Histórico de una comuna: registros por año (toda la serie de la
/// fuente), por mes (período del índice), comparación entre años y
/// modalidades. Se abre desde la ficha de la comuna en el mapa.
class SecurityHistoryScreen extends StatefulWidget {
  const SecurityHistoryScreen({super.key, required this.codigo});

  final String codigo;

  @override
  State<SecurityHistoryScreen> createState() => _SecurityHistoryScreenState();
}

class _HistoryData {
  const _HistoryData({
    required this.metadatos,
    required this.indice,
    required this.anual,
    required this.mensual,
    required this.modalidades,
    required this.diaHora,
  });

  final SeguridadMetadatos metadatos;
  final ComunaIndice indice;
  final List<PuntoEvolucion> anual;
  final List<PuntoEvolucion> mensual;
  final List<ModalidadTotal> modalidades;

  /// Vacío si la fuente no trae hora (`metadatos.tieneHora`).
  final List<CeldaDiaHora> diaHora;
}

class _SecurityHistoryScreenState extends State<SecurityHistoryScreen> {
  static const _maxModalidades = 7;
  static const _aniosEnTabla = 8;

  late Future<_HistoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryData> _load() async {
    final repo = context.read<SecurityMapProvider>().repository;
    final metadatos = await repo.fetchMetadatos();
    if (metadatos == null || !metadatos.hayDatos) {
      throw StateError('Sin datos de seguridad importados');
    }
    final codigo = widget.codigo;
    final results = await Future.wait([
      repo.fetchIndiceComunas(),
      // Toda la serie de la fuente, no solo el período del índice.
      repo.fetchEvolucion(
        comuna: codigo,
        granularidad: Granularidad.anio,
        inicio: metadatos.datosDesde,
        fin: metadatos.datosHasta,
      ),
      repo.fetchEvolucion(comuna: codigo),
      repo.fetchPorModalidad(comuna: codigo),
      // Sin hora en la fuente no se pide: no se inventa una distribución.
      if (metadatos.tieneHora)
        repo.fetchPorDiaHora(comuna: codigo)
      else
        Future.value(const <CeldaDiaHora>[]),
    ]);
    final indice = (results[0] as List<ComunaIndice>)
        .where((i) => i.codigo == codigo)
        .firstOrNull;
    if (indice == null) throw StateError('Comuna $codigo no existe');
    return _HistoryData(
      metadatos: metadatos,
      indice: indice,
      anual: results[1] as List<PuntoEvolucion>,
      mensual: results[2] as List<PuntoEvolucion>,
      modalidades: results[3] as List<ModalidadTotal>,
      diaHora: results[4] as List<CeldaDiaHora>,
    );
  }

  void _retry() => setState(() => _future = _load());

  void _back() => context.canPop() ? context.pop() : context.go('/mapa');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoryData>(
      future: _future,
      builder: (context, snap) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < AppBreakpoints.mobile;
            final header = _header(snap.data, asCard: !mobile);
            final body = _body(snap, wide: constraints.maxWidth >= 1100);
            if (mobile) {
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      header,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
                        child: body,
                      ),
                    ],
                  ),
                ),
              );
            }
            return AppShell(
              section: AppSection.mapa,
              onNavigate: _handleSideNav,
              onCreateTrip: () => showCreateTripDialog(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [header, body],
              ),
            );
          },
        );
      },
    );
  }

  InkHeader _header(_HistoryData? data, {required bool asCard}) {
    final l10n = context.l10n;
    final i = data?.indice;
    return InkHeader(
      eyebrow: i == null
          ? l10n.securityHistoryTitle
          : (i.esCorregimiento
              ? l10n.securityCorregimientoLabel(i.codigo)
              : l10n.securityComunaLabel(i.codigo)),
      title: i?.nombre ?? l10n.securityIndexTitle,
      titleAccent: l10n.securityHistoryTitle,
      subtitle: data == null
          ? null
          : l10n.securityLegendSubtitle(periodoLabel(context, data.metadatos)),
      asCard: asCard,
      onBack: asCard ? null : _back,
      bottom: i == null ? null : _headerStats(i),
    );
  }

  Widget _headerStats(ComunaIndice i) {
    final l10n = context.l10n;
    Widget stat(String label, Widget value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppText.label(10, color: AppColors.textOnInk),
            ),
            const SizedBox(height: 4),
            value,
          ],
        );
    return Wrap(
      spacing: 28,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        stat(
          l10n.securityIndexShort,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${i.indice}',
                style: AppText.display(32, color: AppColors.surface),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: i.nivel.color,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  i.nivel.label(context),
                  style: AppText.ui(
                    12,
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        stat(
          l10n.securityRecordsInPeriod,
          Text(
            formatoEntero(context, i.total),
            style: AppText.display(32, color: AppColors.surface),
          ),
        ),
      ],
    );
  }

  Widget _body(AsyncSnapshot<_HistoryData> snap, {required bool wide}) {
    if (snap.connectionState != ConnectionState.done) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snap.hasError) {
      debugPrint('SecurityHistoryScreen._load error: ${snap.error}');
      return LoadErrorBox(
        message: context.l10n.securityHistoryLoadError,
        onRetry: _retry,
      );
    }
    final data = snap.data!;
    final left = [
      _annualCard(data),
      const SizedBox(height: 22),
      _monthlyCard(data),
      const SizedBox(height: 22),
      _dayHourCard(data),
    ];
    final right = [
      _yearTableCard(data),
      const SizedBox(height: 22),
      _modalidadesCard(data),
      const SizedBox(height: 16),
      Text(
        context.l10n.securityDisclaimer,
        style: AppText.ui(12, color: AppColors.textMuted),
      ),
    ];
    if (!wide) {
      return Column(children: [...left, const SizedBox(height: 22), ...right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: Column(children: left)),
        const SizedBox(width: 22),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: right,
          ),
        ),
      ],
    );
  }

  /// El último año de la fuente está incompleto si no llega a diciembre.
  bool _ultimoParcial(SeguridadMetadatos m) =>
      m.datosHasta != null && m.datosHasta!.month < 12;

  Widget _annualCard(_HistoryData data) {
    final m = data.metadatos;
    final hasta = m.datosHasta;
    return FormSectionCard(
      title: context.l10n.securityAnnualTitle,
      subtitle: data.anual.isEmpty
          ? null
          : '${data.anual.first.periodo.year} – ${data.anual.last.periodo.year}',
      children: [
        AnnualBarChart(puntos: data.anual),
        if (hasta != null && _ultimoParcial(m)) ...[
          const SizedBox(height: 12),
          Text(
            context.l10n.securityAnnualNote(
              '${hasta.year}',
              DateFormat.MMMM(Localizations.localeOf(context).toLanguageTag())
                  .format(hasta),
            ),
            style: AppText.ui(12, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _monthlyCard(_HistoryData data) {
    return FormSectionCard(
      title: context.l10n.securityMonthlyTitle,
      subtitle: periodoLabel(context, data.metadatos),
      children: [MonthlyLineChart(puntos: data.mensual)],
    );
  }

  /// Día × hora. El agregado horario solo tiene año, así que cubre los años
  /// completos del período (p.ej. 2021–2023), no el mes exacto.
  Widget _dayHourCard(_HistoryData data) {
    final l10n = context.l10n;
    final m = data.metadatos;
    final anios = m.periodoInicio.year == m.periodoFin.year
        ? '${m.periodoFin.year}'
        : '${m.periodoInicio.year}–${m.periodoFin.year}';

    if (!m.tieneHora) {
      return FormSectionCard(
        title: l10n.securityDayHourTitle,
        children: [
          Text(
            l10n.securityDayHourUnavailable,
            style: AppText.ui(13, color: AppColors.textMuted),
          ),
        ],
      );
    }

    return FormSectionCard(
      title: l10n.securityDayHourTitle,
      subtitle: l10n.securityDayHourSubtitle(anios),
      children: [
        DayHourHeatmap(celdas: data.diaHora),
        const SizedBox(height: 12),
        Text(
          l10n.securityDayHourNote,
          style: AppText.ui(12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        PeakTimesSummary(celdas: data.diaHora),
      ],
    );
  }

  Widget _yearTableCard(_HistoryData data) {
    final l10n = context.l10n;
    final anual = data.anual;
    final desde = (anual.length - _aniosEnTabla).clamp(0, anual.length);
    final parcial = _ultimoParcial(data.metadatos);
    final pct = NumberFormat.decimalPercentPattern(
      locale: Localizations.localeOf(context).toLanguageTag(),
      decimalDigits: 1,
    );

    TableRow fila(List<Widget> celdas, {bool header = false}) => TableRow(
          decoration: header
              ? null
              : const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
          children: [
            for (final c in celdas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: c,
              ),
          ],
        );

    Widget headerCell(String t, {bool end = false}) => Text(
          t.toUpperCase(),
          textAlign: end ? TextAlign.end : TextAlign.start,
          style: AppText.label(9),
        );

    return FormSectionCard(
      title: l10n.securityYearTableTitle,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.4),
            2: FlexColumnWidth(1.4),
          },
          children: [
            fila(
              [
                headerCell(l10n.securityYearColumn),
                headerCell(l10n.securityRecordsColumn, end: true),
                headerCell(l10n.securityChangeColumn, end: true),
              ],
              header: true,
            ),
            for (var k = anual.length - 1; k >= desde; k--)
              fila([
                Text(
                  '${anual[k].periodo.year}'
                  '${parcial && k == anual.length - 1 ? ' (${l10n.securityPartialYear})' : ''}',
                  style: AppText.ui(13),
                ),
                Text(
                  formatoEntero(context, anual[k].total),
                  textAlign: TextAlign.end,
                  style: AppText.ui(13, weight: FontWeight.w600),
                ),
                Text(
                  _variacion(anual, k, parcial, pct),
                  textAlign: TextAlign.end,
                  style: AppText.ui(13, color: AppColors.textMuted),
                ),
              ]),
          ],
        ),
      ],
    );
  }

  /// Variación frente al año anterior. No se calcula para el año parcial
  /// (compararía 11 meses contra 12) ni si el año anterior tuvo 0.
  String _variacion(
    List<PuntoEvolucion> anual,
    int k,
    bool parcial,
    NumberFormat pct,
  ) {
    if (k == 0 || (parcial && k == anual.length - 1)) return '—';
    final antes = anual[k - 1].total;
    if (antes == 0) return '—';
    final v = (anual[k].total - antes) / antes;
    return '${v > 0 ? '+' : ''}${pct.format(v)}';
  }

  Widget _modalidadesCard(_HistoryData data) {
    final l10n = context.l10n;
    final todas = data.modalidades;
    final top = todas.take(_maxModalidades).toList();
    final resto = todas.skip(_maxModalidades);
    final filas = [
      for (final m in top) (m.modalidad, m.total, m.porcentaje),
      if (resto.isNotEmpty)
        (
          l10n.securityOtherModalities,
          resto.fold<int>(0, (s, m) => s + m.total),
          resto.fold<double>(0, (s, m) => s + m.porcentaje),
        ),
    ];
    return FormSectionCard(
      title: l10n.securityByModality,
      subtitle: periodoLabel(context, data.metadatos),
      children: [
        for (final (nombre, total, porcentaje) in filas)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(nombre, style: AppText.ui(13))),
                    Text(
                      '${formatoEntero(context, total)} · '
                      '${porcentaje.toStringAsFixed(1)} %',
                      style: AppText.label(10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (porcentaje / 100).clamp(0, 1),
                    minHeight: 6,
                    color: AppColors.inkSoft,
                    backgroundColor: AppColors.paperDeep,
                  ),
                ),
              ],
            ),
          ),
      ],
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
      case AppSection.promociones:
        context.go('/promociones');
      case AppSection.suscripciones:
        context.go('/suscripciones');
    }
  }
}
