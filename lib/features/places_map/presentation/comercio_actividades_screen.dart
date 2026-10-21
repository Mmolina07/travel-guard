import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/stagger_in.dart';
import '../data/models/actividad_model.dart';
import '../providers/comercio_panel_provider.dart';
import 'widgets/comercio_scaffold.dart';
import 'widgets/comercio_ui.dart';

/// "Mis actividades" del comercio (`/comercio/actividades`): filtro por
/// estado y tabla con todas las actividades (en móvil, tarjetas). Con
/// [promociones] es "Mis promociones" (`/comercio/promociones`): la misma
/// vista, solo con las promociones exclusivas Premium.
class ComercioActividadesScreen extends StatelessWidget {
  const ComercioActividadesScreen({super.key, this.promociones = false});

  final bool promociones;

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final l10n = context.l10n;
    final panel = context.watch<ComercioPanelProvider>();
    final filtro = panel.filtroDe(promociones: promociones);
    final estado = estadoDeFiltro(filtro);
    final source = promociones ? panel.promociones : panel.soloActividades;
    final filtered = source
        .where(
          (a) =>
              estado == null || EstadoActividad.normalizar(a.estado) == estado,
        )
        .where(panel.actividadCoincide)
        .toList();
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.032).clamp(32.0, 44.0);

    return ComercioScaffold(
      section: promociones ? ComercioSection.promociones : ComercioSection.actividades,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 20,
            runSpacing: 18,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promociones
                        ? l10n.comercioPromosTotal(source.length)
                        : l10n.comercioActivitiesTotal(source.length),
                    style: AppText.label(11, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: promociones
                              ? l10n.comercioPromosTitle1
                              : l10n.comercioActivitiesTitle1,
                        ),
                        TextSpan(
                          text: promociones
                              ? l10n.comercioPromosTitle2
                              : l10n.comercioActivitiesTitle2,
                          style: AppText.displayItalic(titleSize),
                        ),
                      ],
                    ),
                    style: AppText.display(titleSize).copyWith(height: 1.04),
                  ),
                  if (promociones) ...[
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        l10n.comercioPromosSubtitle,
                        style: AppText.ui(14, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
              FilterChipsRow(
                items: [
                  for (final f in ActividadFiltro.values)
                    actividadFiltroLabel(context, f),
                ],
                selected: filtro.index,
                onSelect: (i) => panel.setFiltroDe(
                  ActividadFiltro.values[i],
                  promociones: promociones,
                ),
                duration: const Duration(milliseconds: 300),
                curve: AppMotion.enter,
              ),
              // Promociones: su propio botón de crear (la CTA del sidebar
              // crea actividades). En móvil no hay sidebar.
              if (promociones || context.isMobile)
                SmallInkButton(
                  label: promociones
                      ? l10n.comercioCreatePromoButton
                      : l10n.homeComercioCreateActivityButton,
                  onTap: () => promociones
                      ? openCreatePromotion(context)
                      : openCreateActivity(context),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!panel.hasLoaded && !panel.loadFailed)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.ink),
              ),
            )
          else if (context.isMobile)
            _ActivityCards(actividades: filtered, promociones: promociones)
          else
            _ActivityTable(actividades: filtered, promociones: promociones),
        ],
      ),
    );
  }
}

/// Mensaje del estado vacío (por filtro) con el enlace a crear.
class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter({required this.promociones});

  final bool promociones;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final panel = context.watch<ComercioPanelProvider>();
    if (panel.buscando) {
      return Text(
        l10n.comercioSearchNoResults(panel.busqueda.trim()),
        style: AppText.ui(14, color: AppColors.textMuted),
      );
    }
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          promociones ? l10n.comercioPromosEmptyFilter : l10n.comercioActivitiesEmptyFilter,
          style: AppText.ui(14, color: AppColors.textMuted),
        ),
        TextLink(
          label: promociones
              ? l10n.comercioCreatePromoTitle
              : l10n.homeComercioCreateActivityTitle,
          onTap: () => promociones ? openCreatePromotion(context) : openCreateActivity(context),
        ),
      ],
    );
  }
}

/// Tabla en tarjeta blanca radio 26: ACTIVIDAD / CATEGORÍA / FECHAS /
/// PRECIO / ESTADO (`2.2fr 1fr 1.2fr 0.9fr 110px`, gap 16).
class _ActivityTable extends StatelessWidget {
  const _ActivityTable({required this.actividades, required this.promociones});

  final List<Actividad> actividades;
  final bool promociones;

  static Widget _row(List<Widget> cells, {required EdgeInsets padding}) {
    const flexes = [22, 10, 12, 9];
    return Padding(
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Expanded(flex: flexes[i], child: cells[i]),
            const SizedBox(width: 16),
          ],
          SizedBox(width: 140, child: cells[4]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headerStyle = AppText.label(10);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: _row(
              [
                Text(l10n.comercioColActivity, style: headerStyle),
                Text(l10n.comercioColCategory, style: headerStyle),
                Text(l10n.comercioColDates, style: headerStyle),
                Text(l10n.comercioColPrice, style: headerStyle),
                Text(l10n.comercioColStatus, style: headerStyle),
              ],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          if (actividades.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _EmptyFilter(promociones: promociones),
            ),
          for (var i = 0; i < actividades.length; i++)
            StaggerIn(
              index: i,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: _EditableRow(
                  actividad: actividades[i],
                  child: _tableRow(context, actividades[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, Actividad a) {
    final name = a.nombre.isEmpty
        ? context.l10n.homeComercioNoNameFallback
        : a.nombre;
    final desc = (a.descripcion ?? '').trim();
    return _row([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(15, weight: FontWeight.w600),
                ),
              ),
              // En "Promociones" todas lo son; aquí solo se marca la
              // actividad que se publicó "Solo Premium".
              if (a.soloPremium && !promociones) ...[
                const SizedBox(width: 8),
                const PremiumTag(),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            desc.isEmpty ? context.l10n.comercioNoDescription : desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.ui(12, color: AppColors.textMuted),
          ),
        ],
      ),
      Text(
        (a.categoria ?? '—').toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.label(
          11,
          color: AppColors.inkSoft,
        ).copyWith(letterSpacing: 11 * 0.1),
      ),
      Text(
        formatActividadFechas(
          context,
          inicio: a.fechaInicio,
          fin: a.fechaFin,
        ).toUpperCase(),
        style: AppText.label(
          11,
          color: AppColors.textMuted,
        ).copyWith(letterSpacing: 0),
      ),
      Text(
        formatActividadPrecio(context, a),
        style: AppText.ui(14, weight: FontWeight.w600),
      ),
      Row(
        children: [
          EstadoBadge(estado: a.estado),
          const Spacer(),
          Tooltip(
            message: context.l10n.comercioEditTooltip,
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    ], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18));
  }
}

/// Móvil: la misma información en tarjetas apiladas.
class _ActivityCards extends StatelessWidget {
  const _ActivityCards({required this.actividades, required this.promociones});

  final List<Actividad> actividades;
  final bool promociones;

  @override
  Widget build(BuildContext context) {
    if (actividades.isEmpty) {
      return DashedBox(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: _EmptyFilter(promociones: promociones),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < actividades.length; i++)
          StaggerIn(
            index: i,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadow.card,
              ),
              child: _EditableRow(
                actividad: actividades[i],
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _card(context, actividades[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, Actividad a) {
    final desc = (a.descripcion ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                (a.categoria ?? '').toUpperCase(),
                style: AppText.label(10, color: AppColors.inkSoft),
              ),
            ),
            if (a.soloPremium && !promociones) ...[
              const PremiumTag(),
              const SizedBox(width: 6),
            ],
            EstadoBadge(estado: a.estado),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          a.nombre.isEmpty ? context.l10n.homeComercioNoNameFallback : a.nombre,
          style: AppText.ui(16, weight: FontWeight.w600),
        ),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.ui(12, color: AppColors.textMuted),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '${formatActividadFechas(context, inicio: a.fechaInicio, fin: a.fechaFin).toUpperCase()} · ${formatActividadPrecio(context, a)}',
          style: AppText.label(
            11,
            color: AppColors.textMuted,
          ).copyWith(letterSpacing: 0),
        ),
      ],
    );
  }
}

/// Fila/tarjeta que abre la edición de la actividad al tocarla.
class _EditableRow extends StatelessWidget {
  const _EditableRow({required this.actividad, required this.child});

  final Actividad actividad;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => openEditActivity(context, actividad),
        hoverColor: AppColors.wash.withValues(alpha: 0.5),
        child: child,
      ),
    );
  }
}
