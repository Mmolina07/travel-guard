import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/hover_card.dart';
import '../../../widgets/stagger_in.dart';
import '../../auth/providers/app_auth_provider.dart';
import '../data/models/actividad_model.dart';
import '../providers/comercio_panel_provider.dart';
import 'menu_model.dart';
import 'widgets/comercio_scaffold.dart';
import 'widgets/comercio_ui.dart';

/// Inicio del panel del comercio (`/comercio`): cabecera `ink` con los
/// contadores, tarjetas de acción y el resumen de actividades y menú.
/// Los datos vienen de [ComercioPanelProvider] (mismas consultas que
/// antes hacía esta pantalla en su `State`).
class HomeScreenComercio extends StatelessWidget {
  const HomeScreenComercio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final panel = context.watch<ComercioPanelProvider>();
    final auth = context.watch<AppAuthProvider>();
    final businessName = panel.comercio?.nombreComercio ?? auth.displayName;

    return ComercioScaffold(
      section: ComercioSection.inicio,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            businessName: businessName,
            activityCount: panel.soloActividades.length,
            promoCount: panel.promociones.length,
            menuCount: panel.menus.length,
          ),
          const SizedBox(height: 30),
          const _ActionCards(),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final activities = _ActivitiesColumn(panel: panel);
              final menu = _MenuColumn(panel: panel);
              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [activities, const SizedBox(height: 30), menu],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 16, child: activities),
                  const SizedBox(width: 22),
                  Expanded(flex: 10, child: menu),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Cabecera `ink` radio 30 con `bottomRight: 60` y halo `mint`.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.businessName,
    required this.activityCount,
    required this.promoCount,
    required this.menuCount,
  });

  final String businessName;
  final int activityCount;
  final int promoCount;
  final int menuCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final mobile = context.isMobile;
    final titleSize = mobile ? 32.0 : (width * 0.036).clamp(34.0, 48.0);
    final counters = [
      _HeaderCounter(
        value: activityCount,
        label: l10n.homeComercioStatActivitiesLabel,
        compact: mobile,
        onTap: () => context.go(ComercioRoutes.actividades),
      ),
      _HeaderCounter(
        value: promoCount,
        label: l10n.comercioNavPromos,
        compact: mobile,
        onTap: () => context.go(ComercioRoutes.promociones),
      ),
      _HeaderCounter(
        value: menuCount,
        label: l10n.homeComercioStatMenusLabel,
        compact: mobile,
        onTap: () => context.go(ComercioRoutes.menu),
      ),
    ];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: -120,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.2),
                  colors: [
                    AppColors.mint.withValues(alpha: 0.20),
                    AppColors.mint.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 22 : 36,
              vertical: mobile ? 26 : 32,
            ),
            // En móvil los contadores iban uno debajo del otro (media
            // pantalla): ahí van en una sola fila de tres.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 28,
              runSpacing: 24,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.comercioPanelEyebrow,
                      style: AppText.label(11, color: AppColors.textOnInk),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: l10n.comercioGreetingPrefix),
                            TextSpan(
                              text: '$businessName!',
                              style: AppText.displayItalic(
                                titleSize,
                                color: AppColors.mint,
                              ),
                            ),
                          ],
                        ),
                        style: AppText.display(
                          titleSize,
                          color: AppColors.paper,
                        ).copyWith(height: 1.02),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.homeComercioHeroSubtitle,
                      style: AppText.ui(mobile ? 14 : 15, color: AppColors.textOnInk),
                    ),
                  ],
                ),
                if (mobile)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < counters.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: counters[i]),
                        ],
                      ],
                    ),
                  )
                else
                  Wrap(spacing: 12, runSpacing: 12, children: counters),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contador translúcido (display 40 + etiqueta mono), pulsable.
class _HeaderCounter extends StatelessWidget {
  const _HeaderCounter({
    required this.value,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final int value;
  final String label;
  final VoidCallback onTap;

  /// Móvil: ficha angosta para que quepan las tres en una fila.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.paper.withValues(alpha: 0.08),
      radius: 22,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      baseShadow: const [],
      hoverShadow: const [],
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: compact ? 0 : 114),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: AppText.display(
                compact ? 30 : 40,
                color: AppColors.paper,
              ).copyWith(height: 1),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              maxLines: 2,
              // Compacta: 9 px y menos tracking para que "ACTIVIDADES" no
              // se parta a mitad de palabra en ~85 px.
              style: AppText.label(
                compact ? 9 : 10,
                color: AppColors.textOnInk,
              ).copyWith(letterSpacing: compact ? 9 * 0.06 : 10 * 0.16),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Crear actividad" (blanca, sombra `card`) y "Agregar menú" (`wash`)
/// en `auto-fit minmax(300, 1fr)`.
class _ActionCards extends StatelessWidget {
  const _ActionCards();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = _ActionCard(
      color: AppColors.surface,
      shadow: AppShadow.card,
      icon: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      button: SmallInkButton(
        label: l10n.homeComercioCreateActivityButton,
        onTap: () => openCreateActivity(context),
      ),
      title: l10n.homeComercioCreateActivityTitle,
      description: l10n.homeComercioCreateActivityDescription,
      onTap: () => openCreateActivity(context),
    );
    final menu = _ActionCard(
      color: AppColors.wash,
      shadow: const [],
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
      ),
      button: SmallInkButton(
        label: l10n.homeComercioAddMenuButton,
        outlined: true,
        onTap: () => openCreateMenu(context),
      ),
      title: l10n.homeComercioAddMenuTitle,
      description: l10n.homeComercioAddMenuDescription,
      onTap: () => context.go(ComercioRoutes.menu),
    );

    final promo = _ActionCard(
      color: AppColors.surface,
      shadow: AppShadow.card,
      icon: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.workspace_premium_outlined, size: 20, color: AppColors.mint),
      ),
      button: SmallInkButton(
        label: l10n.comercioCreatePromoButton,
        onTap: () => openCreatePromotion(context),
      ),
      title: l10n.comercioCreatePromoTitle,
      description: l10n.comercioCreatePromoDescription,
      onTap: () => openCreatePromotion(context),
    );
    final cards = [activity, promo, menu];

    // Móvil: las tres tarjetas grandes llenaban la pantalla y repetían
    // la nav de abajo; ahí son tres accesos rápidos en una fila.
    if (context.isMobile) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.event_note_outlined,
                label: l10n.homeComercioCreateActivityButton,
                onTap: () => openCreateActivity(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.workspace_premium_outlined,
                label: l10n.comercioCreatePromoButton,
                onTap: () => openCreatePromotion(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.restaurant_menu_outlined,
                label: l10n.homeComercioAddMenuButton,
                onTap: () => openCreateMenu(context),
              ),
            ),
          ],
        ),
      );
    }

    // `auto-fit minmax(300, 1fr)`: tantas columnas como quepan (máx. 3),
    // con las tarjetas de cada fila a la misma altura.
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = ((constraints.maxWidth + gap) / (300 + gap)).floor().clamp(1, cards.length);
        final rows = <Widget>[];
        for (var start = 0; start < cards.length; start += columns) {
          final rowCards = cards.sublist(start, (start + columns).clamp(0, cards.length));
          if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < rowCards.length; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    Expanded(child: StaggerIn(index: start + i, child: rowCards[i])),
                  ],
                  // Fila incompleta: huecos para que no se estiren.
                  for (var i = rowCards.length; i < columns; i++) ...[
                    const SizedBox(width: gap),
                    const Expanded(child: SizedBox()),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// Acceso rápido de móvil: cuadro `ink` con icono `mint` + etiqueta.
class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      radius: AppRadius.card,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.mint),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppText.ui(13, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.shadow,
    required this.icon,
    required this.button,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Color color;
  final List<BoxShadow> shadow;
  final Widget icon;
  final Widget button;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: color,
      radius: AppRadius.cardLg,
      padding: const EdgeInsets.all(24),
      baseShadow: shadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [icon, button],
          ),
          const SizedBox(height: 28),
          Text(title, style: AppText.display(28).copyWith(height: 1.08)),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppText.ui(14, color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de columna: display 26 + enlace mono a la derecha.
class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.title,
    required this.link,
    required this.onLink,
  });

  final String title;
  final String link;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppText.display(26))),
        TextLink(label: link, mono: true, onTap: onLink),
      ],
    );
  }
}

class _ActivitiesColumn extends StatelessWidget {
  const _ActivitiesColumn({required this.panel});

  final ComercioPanelProvider panel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actividades = panel.actividades
        .where(panel.actividadCoincide)
        .take(3)
        .toList();
    final Widget body;
    if (!panel.hasLoaded && !panel.loadFailed) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    } else if (actividades.isEmpty && panel.buscando) {
      body = _NoResults(query: panel.busqueda);
    } else if (actividades.isEmpty) {
      body = DashedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeComercioEmptyActivitiesTitle,
              style: AppText.display(24),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                l10n.comercioEmptyActivitiesBody,
                style: AppText.ui(14, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            SmallInkButton(
              label: l10n.comercioCreateFirstActivity,
              onTap: () => openCreateActivity(context),
              radius: 16,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        children: [
          for (var i = 0; i < actividades.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            StaggerIn(
              index: i,
              child: _ActivityRow(actividad: actividades[i]),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ColumnHeader(
          title: l10n.homeComercioMyActivitiesTitle,
          link: l10n.homeComercioSeeAllButton,
          onLink: () => context.go(ComercioRoutes.actividades),
        ),
        const SizedBox(height: 12),
        body,
      ],
    );
  }
}

/// Fila de actividad: thumb 60, categoría mono, nombre, fechas · precio
/// y badge de estado.
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.actividad});

  final Actividad actividad;

  @override
  Widget build(BuildContext context) {
    final name = actividad.nombre.isEmpty
        ? context.l10n.homeComercioNoNameFallback
        : actividad.nombre;
    final dates = formatActividadFechas(
      context,
      inicio: actividad.fechaInicio,
      fin: actividad.fechaFin,
    );
    final mobile = context.isMobile;
    final badges = <Widget>[
      if (actividad.soloPremium) ...[
        const PremiumTag(),
        if (!mobile) const SizedBox(width: 8),
      ],
      EstadoBadge(estado: actividad.estado),
    ];
    return HoverCard(
      // Abre su edición directamente (antes solo llevaba a la lista).
      onTap: () => openEditActivity(context, actividad),
      radius: AppRadius.card,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              activityCategoryIcon(actividad.categoria),
              color: AppColors.inkSoft,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((actividad.categoria ?? '').isNotEmpty)
                  Text(
                    actividad.categoria!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label(10, color: AppColors.inkSoft),
                  ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(16, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${dates.toUpperCase()} · ${formatActividadPrecio(context, actividad)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label(
                    11,
                    color: AppColors.textMuted,
                  ).copyWith(letterSpacing: 0),
                ),
                // Móvil: al lado se comían el ancho y cortaban el nombre.
                if (mobile) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: badges),
                ],
              ],
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 12),
            ...badges,
          ],
        ],
      ),
    );
  }
}

class _MenuColumn extends StatelessWidget {
  const _MenuColumn({required this.panel});

  final ComercioPanelProvider panel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productos = [
      for (final m in panel.menus)
        ...m.products.where(
          (p) => panel.menuCoincide(m) || panel.productoCoincide(p),
        ),
    ].take(5).toList();
    final Widget body;
    if (!panel.hasLoaded && !panel.loadFailed) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    } else if (productos.isEmpty && panel.buscando) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: _NoResults(query: panel.busqueda),
      );
    } else if (productos.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.comercioEmptyMenuShort,
              style: AppText.ui(14, color: AppColors.textMuted),
            ),
            TextLink(
              label: l10n.homeComercioAddMenuTitle,
              onTap: () => openCreateMenu(context),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        children: [
          for (var i = 0; i < productos.length; i++)
            StaggerIn(
              index: i,
              child: _MenuRow(producto: productos[i]),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ColumnHeader(
          title: l10n.comercioYourMenuTitle,
          link: l10n.comercioEditLink,
          onLink: () => context.go(ComercioRoutes.menu),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadow.card,
          ),
          child: body,
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.producto});

  final MenuItem producto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              producto.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.ui(15, weight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.formatMoney(producto.price),
            style: AppText.label(
              12,
              color: AppColors.inkSoft,
            ).copyWith(letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

/// Sin coincidencias para la búsqueda del topbar.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.comercioSearchNoResults(query.trim()),
      style: AppText.ui(14, color: AppColors.textMuted),
    );
  }
}
