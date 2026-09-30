import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_extension.dart';
import '../core/settings/currency_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/search_focus.dart';
import '../features/auth/providers/app_auth_provider.dart';
import '../features/trips/presentation/pages/trip_model.dart';

/// Las 4 secciones de navegación del sidebar — ver
/// `design_handoff_travelguard_papel_petroleo/WEB_LAYOUT.md`. "Inicio"
/// y "Mis viajes" apuntan a la misma vista (no hay una ruta de listado
/// de viajes separada en la especificación); se mantienen como dos
/// entradas porque así las lista el diseño.
enum AppSection { inicio, misViajes, comercios, mapa }

/// Shell de escritorio/tablet: `Row` de sidebar fijo + columna de
/// contenido con topbar sticky. Úsalo únicamente cuando
/// `constraints.maxWidth >= AppBreakpoints.mobile` — por debajo de eso
/// cada pantalla arma su propio `Scaffold` mobile con nav flotante
/// (ver README), este shell no aplica ahí.
///
/// [child] es solo el CONTENIDO de la vista (sin `Scaffold` propio ni
/// scroll propio) — este widget aporta el `Scaffold`, el `TopBar` y el
/// `SingleChildScrollView` con el padding de la retícula.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.section,
    required this.child,
    required this.onNavigate,
    required this.onCreateTrip,
    this.activeTrip,
    this.activeTripSpent,
  });

  final AppSection section;
  final Widget child;
  final ValueChanged<AppSection> onNavigate;
  final VoidCallback onCreateTrip;

  /// Viaje que muestra el resumen de presupuesto del sidebar — cada
  /// pantalla decide cuál tiene sentido mostrar (Inicio: el más
  /// próximo; Detalle: el que se está viendo). `null` en pantallas sin
  /// un viaje de contexto (Comercios, Mapa): el sidebar muestra "Sin
  /// viaje activo" en vez de quedar pegado a un `Provider` que nada
  /// llenaba.
  final Trip? activeTrip;

  /// Gastado real de [activeTrip] (planeado + gastos registrados) — lo
  /// calcula quien pasa `activeTrip`, porque solo esa pantalla sabe si
  /// ya tiene los gastos reales a mano.
  final double? activeTripSpent;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Explícito porque `Scrollbar` no logra adjuntarse solo al
  // `PrimaryScrollController` en este árbol (Scaffold > Row > Column >
  // Expanded) — sin esto, el scrollbar del área principal lanza
  // "ScrollController has no ScrollPosition attached" en cada frame.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = context.isTablet;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SideNav(
            collapsed: collapsed,
            section: widget.section,
            onNavigate: widget.onNavigate,
            onCreateTrip: widget.onCreateTrip,
            activeTrip: widget.activeTrip,
            activeTripSpent: widget.activeTripSpent,
          ),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(34, 36, 34, 60),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.collapsed,
    required this.section,
    required this.onNavigate,
    required this.onCreateTrip,
    required this.activeTrip,
    required this.activeTripSpent,
  });

  final bool collapsed;
  final AppSection section;
  final ValueChanged<AppSection> onNavigate;
  final VoidCallback onCreateTrip;
  final Trip? activeTrip;
  final double? activeTripSpent;

  List<({AppSection section, IconData icon, String label})> _items(
    BuildContext context,
  ) => [
    (
      section: AppSection.inicio,
      icon: Icons.home_outlined,
      label: context.l10n.appShellNavHome,
    ),
    (
      section: AppSection.misViajes,
      icon: Icons.luggage_outlined,
      label: context.l10n.appShellNavMyTrips,
    ),
    (
      section: AppSection.comercios,
      icon: Icons.storefront_outlined,
      label: context.l10n.appShellNavCommerces,
    ),
    (
      section: AppSection.mapa,
      icon: Icons.map_outlined,
      label: context.l10n.appShellNavMap,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed ? 72 : 248,
      decoration: const BoxDecoration(
        color: AppColors.paperDeep,
        border: Border(right: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.symmetric(vertical: 26, horizontal: collapsed ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Brand(collapsed: collapsed),
          const SizedBox(height: 26),
          _CreateTripCta(collapsed: collapsed, onTap: onCreateTrip),
          const SizedBox(height: 26),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.l10n.appShellNavSectionLabel,
                style: AppText.label(10),
              ),
            ),
          const SizedBox(height: 8),
          for (final item in _items(context))
            _NavItem(
              collapsed: collapsed,
              icon: item.icon,
              label: item.label,
              active: item.section == section,
              onTap: () => onNavigate(item.section),
            ),
          const Spacer(),
          const SizedBox(height: 26),
          _BudgetSummary(collapsed: collapsed, trip: activeTrip, spent: activeTripSpent),
          const SizedBox(height: 14),
          _ProfileRow(collapsed: collapsed),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final mark = Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
    if (collapsed) return Center(child: mark);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          mark,
          const SizedBox(width: 12),
          Text(
            'TRAVELGUARD',
            style: AppText.label(11, color: AppColors.ink).copyWith(
              letterSpacing: 11 * 0.18,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTripCta extends StatelessWidget {
  const _CreateTripCta({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final plus = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(Icons.add, color: AppColors.ink, size: 18),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: collapsed
              ? const EdgeInsets.symmetric(vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppShadow.inkButton,
          ),
          child: collapsed
              ? Center(child: plus)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.appShellCreateTripButton,
                      style: AppText.ui(
                        15,
                        weight: FontWeight.w700,
                        color: AppColors.paper,
                      ),
                    ),
                    plus,
                  ],
                ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.textMuted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.toggle,
          curve: AppMotion.enter,
          margin: const EdgeInsets.only(bottom: 4),
          padding: collapsed
              ? const EdgeInsets.symmetric(vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.wash : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: collapsed
              ? Tooltip(
                  message: label,
                  child: Icon(icon, size: 20, color: color),
                )
              : AnimatedDefaultTextStyle(
                  duration: AppMotion.toggle,
                  curve: AppMotion.enter,
                  style: AppText.ui(
                    15,
                    weight: active ? FontWeight.w700 : FontWeight.w400,
                    color: color,
                  ),
                  child: Text(label),
                ),
        ),
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.collapsed, required this.trip, required this.spent});

  final bool collapsed;
  final Trip? trip;
  final double? spent;

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final budget = trip?.maxBudget ?? 0;
    final spentValue = spent ?? 0;
    final pct = budget > 0 ? (spentValue / budget).clamp(0.0, 1.0) : 0.0;
    final month = _currentMonthLabel(context).toUpperCase();

    if (collapsed) {
      return Center(
        child: Icon(
          Icons.account_balance_wallet_outlined,
          color: AppColors.inkSoft,
          size: 20,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.appShellBudgetLabel(month),
            style: AppText.label(10, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 6),
          Text(
            budget > 0 ? context.formatMoney(budget) : '—',
            style: AppText.display(26),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  const ColoredBox(color: Colors.white),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: const ColoredBox(color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            budget > 0
                ? context.l10n.appShellBudgetPercentOf(
                    (pct * 100).round(),
                    context.formatMoney(budget),
                  )
                : context.l10n.appShellNoActiveTrip,
            style: AppText.ui(11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _currentMonthLabel(BuildContext context) {
    final l10n = context.l10n;
    final months = [
      l10n.appShellMonthJan,
      l10n.appShellMonthFeb,
      l10n.appShellMonthMar,
      l10n.appShellMonthApr,
      l10n.appShellMonthMay,
      l10n.appShellMonthJun,
      l10n.appShellMonthJul,
      l10n.appShellMonthAug,
      l10n.appShellMonthSep,
      l10n.appShellMonthOct,
      l10n.appShellMonthNov,
      l10n.appShellMonthDec,
    ];
    return months[DateTime.now().month - 1];
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final name = auth.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final role = auth.comercio != null
        ? context.l10n.appShellRoleCommerce
        : context.l10n.appShellRoleTourist;

    final avatar = Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initial,
        style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.mint),
      ),
    );

    if (collapsed) {
      return Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _confirmSignOut(context),
            child: avatar,
          ),
        ),
      );
    }

    return Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(14, weight: FontWeight.w600),
              ),
              Text(role, style: AppText.label(11)),
            ],
          ),
        ),
        //botón de perfil
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: AppColors.inkSoft,
            ),
            tooltip: context.l10n.appShellSettingsTooltip,
            onPressed: () => context.go('/configuracion'),
          ),
        ),
        //botón de cerrar sesión
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(Icons.logout, size: 18, color: AppColors.textMuted),
            tooltip: context.l10n.appShellSignOutTooltip,
            onPressed: () => _confirmSignOut(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appShellSignOutDialogTitle),
        content: Text(l10n.appShellSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.appShellCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.appShellSignOutConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppAuthProvider>().signOut();
      // El redirect de `AppRouter` (Fase 5) ya manda a `/login` en cuanto
      // `AppAuthProvider` notifica el cambio de estado; este `go` solo
      // evita el parpadeo de un frame con la pantalla anterior de fondo
      // y limpia cualquier ruta apilada encima (p. ej. `/viajes/:id`).
      if (context.mounted) context.go('/login');
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final l10n = context.l10n;
    final months = [
      l10n.appShellMonthJan,
      l10n.appShellMonthFeb,
      l10n.appShellMonthMar,
      l10n.appShellMonthApr,
      l10n.appShellMonthMay,
      l10n.appShellMonthJun,
      l10n.appShellMonthJul,
      l10n.appShellMonthAug,
      l10n.appShellMonthSep,
      l10n.appShellMonthOct,
      l10n.appShellMonthNov,
      l10n.appShellMonthDec,
    ];
    final weekdays = [
      l10n.appShellWeekdayMonday,
      l10n.appShellWeekdayTuesday,
      l10n.appShellWeekdayWednesday,
      l10n.appShellWeekdayThursday,
      l10n.appShellWeekdayFriday,
      l10n.appShellWeekdaySaturday,
      l10n.appShellWeekdaySunday,
    ];
    final dateLabel =
        '${weekdays[today.weekday - 1]} ${today.day} · ${months[today.month - 1]}';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
          decoration: BoxDecoration(
            color: AppColors.paper.withValues(alpha: 0.92),
            border: const Border(
              bottom: BorderSide(color: AppColors.line),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paperDeep,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            focusNode: searchFocusNode,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: context.l10n.appShellSearchHint,
                              hintStyle: AppText.ui(
                                14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(dateLabel.toUpperCase(), style: AppText.label(11)),
              const SizedBox(width: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.line),
                    ),
                  ),
                  child: const Icon(
                    Icons.dark_mode_outlined,
                    size: 17,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
