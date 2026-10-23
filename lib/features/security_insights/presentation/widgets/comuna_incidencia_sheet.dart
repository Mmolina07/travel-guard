import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/load_error_box.dart';
import '../../data/models/seguridad_stats.dart';
import '../../data/security_repository.dart';
import '../incidencia_style.dart';
import 'peak_times_summary.dart';

/// Ficha de una comuna al tocarla en la capa de incidencia: índice, nivel,
/// registros, posición, principales modalidades, período y fuente.
class ComunaIncidenciaSheet extends StatefulWidget {
  const ComunaIncidenciaSheet({
    super.key,
    required this.indice,
    required this.metadatos,
    required this.repository,
  });

  final ComunaIndice indice;
  final SeguridadMetadatos metadatos;
  final SecurityRepository repository;

  static Future<void> show(
    BuildContext context, {
    required ComunaIndice indice,
    required SeguridadMetadatos metadatos,
    required SecurityRepository repository,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ComunaIncidenciaSheet(
        indice: indice,
        metadatos: metadatos,
        repository: repository,
      ),
    );
  }

  @override
  State<ComunaIncidenciaSheet> createState() => _ComunaIncidenciaSheetState();
}

class _ComunaIncidenciaSheetState extends State<ComunaIncidenciaSheet> {
  late Future<List<ModalidadTotal>> _modalidades;

  /// `null` si la fuente no trae hora: la sección no se muestra.
  Future<List<CeldaDiaHora>>? _diaHora;

  @override
  void initState() {
    super.initState();
    _load();
    _loadDiaHora();
  }

  void _load() {
    _modalidades = widget.repository.fetchPorModalidad(
      comuna: widget.indice.codigo,
    );
  }

  void _loadDiaHora() {
    if (!widget.metadatos.tieneHora) return;
    _diaHora = widget.repository.fetchPorDiaHora(comuna: widget.indice.codigo);
  }

  String _anios(SeguridadMetadatos m) =>
      m.periodoInicio.year == m.periodoFin.year
      ? '${m.periodoFin.year}'
      : '${m.periodoInicio.year}–${m.periodoFin.year}';

  Widget _cargando() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Center(child: CircularProgressIndicator(color: AppColors.inkSoft)),
  );

  @override
  Widget build(BuildContext context) {
    final i = widget.indice;
    final m = widget.metadatos;
    final l10n = context.l10n;
    final nivelColor = i.nivel.color;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.hair,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                ),
              ),
              Text(
                (i.esCorregimiento
                        ? l10n.securityCorregimientoLabel(i.codigo)
                        : l10n.securityComunaLabel(i.codigo))
                    .toUpperCase(),
                style: AppText.label(10),
              ),
              const SizedBox(height: 4),
              Text(i.nombre, style: AppText.display(28)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${i.indice}',
                      style: AppText.display(48, color: AppColors.surface),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/100',
                        style: AppText.ui(13, color: AppColors.textOnInk),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: nivelColor,
                              borderRadius: BorderRadius.circular(
                                AppRadius.chip,
                              ),
                            ),
                            child: Text(
                              l10n.securityLevelBadge(i.nivel.label(context)),
                              style: AppText.ui(
                                12,
                                weight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.securityIndexTitle,
                            style: AppText.ui(
                              11,
                              color: AppColors.textOnInk,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Fact(
                icon: Icons.receipt_long_outlined,
                text: l10n.securityRecordsCount(
                  formatoEntero(context, i.total),
                ),
              ),
              _Fact(
                icon: Icons.leaderboard_outlined,
                text: i.esCorregimiento
                    ? l10n.securityRankCorregimientos(i.posicion, i.tamanoGrupo)
                    : l10n.securityRankComunas(i.posicion, i.tamanoGrupo),
              ),
              _Fact(
                icon: Icons.pie_chart_outline,
                text: l10n.securityGroupShare(
                  i.participacion.toStringAsFixed(1),
                ),
              ),
              if (_diaHora != null) ...[
                const SizedBox(height: 22),
                Text(l10n.securityWhenTitle, style: AppText.display(22)),
                const SizedBox(height: 2),
                Text(
                  l10n.securityDayHourSubtitle(_anios(m)),
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<CeldaDiaHora>>(
                  future: _diaHora,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return _cargando();
                    }
                    if (snap.hasError) {
                      return LoadErrorBox(
                        message: l10n.securityHistoryLoadError,
                        onRetry: () => setState(_loadDiaHora),
                      );
                    }
                    return PeakTimesSummary(
                      celdas: snap.data!,
                      color: nivelColor,
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),
              Text(
                l10n.securityTopModalities.toUpperCase(),
                style: AppText.label(10),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<ModalidadTotal>>(
                future: _modalidades,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return _cargando();
                  }
                  if (snap.hasError) {
                    return LoadErrorBox(
                      message: l10n.securityModalitiesError,
                      onRetry: () => setState(_load),
                    );
                  }
                  final top = snap.data!.take(4).toList();
                  return Column(
                    children: [
                      for (final mod in top)
                        _ModalidadBar(modalidad: mod, color: nivelColor),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              InkButton(
                label: l10n.securityHistoryButton,
                icon: Icons.show_chart,
                trailingArrow: true,
                expand: true,
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/seguridad/comuna/${i.codigo}');
                },
              ),
              const SizedBox(height: 18),
              _Meta(
                label: l10n.securityPeriodLabel,
                value: periodoLabel(context, m),
              ),
              _Meta(
                label: l10n.securitySourceLabel,
                value: [
                  m.publicador,
                  m.fuenteNombre,
                  m.licencia,
                ].whereType<String>().join(' · '),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paperDeep,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.securityDisclaimer,
                        style: AppText.ui(12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.ui(14))),
        ],
      ),
    );
  }
}

class _ModalidadBar extends StatelessWidget {
  const _ModalidadBar({required this.modalidad, required this.color});

  final ModalidadTotal modalidad;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(modalidad.modalidad, style: AppText.ui(13))),
              Text(
                '${modalidad.porcentaje.toStringAsFixed(1)} %',
                style: AppText.label(11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (modalidad.porcentaje / 100).clamp(0, 1),
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

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.label(10)),
          const SizedBox(height: 2),
          Text(value, style: AppText.ui(13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
