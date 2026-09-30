import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/menu_model.dart';
import '../presentation/create_activity_screen.dart';
import '../presentation/create_menu_screen.dart';
import '../presentation/menu_detail_screen.dart';
import '../../auth/providers/app_auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boarding_pass_card.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../core/widgets/route_pattern_background.dart';
import '../../../core/widgets/travel_guard_badge.dart';
import '../../../core/l10n/l10n_extension.dart';

class HomeScreenComercio extends StatefulWidget {
  const HomeScreenComercio({Key? key}) : super(key: key);

  @override
  State<HomeScreenComercio> createState() => _HomeScreenComercioState();
}

class _HomeScreenComercioState extends State<HomeScreenComercio> {
  int _selectedIndex = 0;

  String get businessName => context.watch<AppAuthProvider>().displayName;
  final List<Map<String, dynamic>> _actividades = [];
  final List<Menu> _menus = []; // ← AGREGAR LISTA DE MENÚS

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.homeComercioSignOut),
        content: Text(context.l10n.homeComercioSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.homeComercioCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.homeComercioSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppAuthProvider>().signOut();
      // El redirect de `AppRouter` ya manda a `/login` en cuanto
      // `AppAuthProvider` notifica el cambio; este `go` solo evita el
      // parpadeo de un frame con esta pantalla de fondo.
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _handleBottomNavTap(int index) async {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Inicio - ya estamos aquí
    } else if (index == 1) {
      final activity = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateActivityScreen(),
        ),
      );
      if (!mounted) return;

      if (activity != null) {
        setState(() {
          _actividades.add(activity);
          _selectedIndex = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.homeComercioActivityCreatedSnackbar(
                activity['name'],
              ),
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    } else if (index == 2) {
      if (_menus.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailScreen(menu: _menus[0]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.homeComercioCreateFirstMenuSnackbar),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(),
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: 760,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsStrip(),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    child: _buildFeatureCard(
                      icon: Icons.restaurant_menu,
                      title: context.l10n.homeComercioAddMenuTitle,
                      description: context.l10n.homeComercioAddMenuDescription,
                      buttonText: context.l10n.homeComercioAddMenuButton,
                      onButtonPressed: () async {
                        final Menu? newMenu = await Navigator.push<Menu>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateMenuScreen(),
                          ),
                        );

                        if (newMenu != null) {
                          setState(() {
                            _menus.add(newMenu);
                          });

                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MenuDetailScreen(menu: newMenu),
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.homeComercioMenuCreatedSnackbar(
                                  newMenu.name,
                                ),
                              ),
                              backgroundColor: AppColors.ink,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _buildFeatureCard(
                      icon: Icons.event_note,
                      title: context.l10n.homeComercioCreateActivityTitle,
                      description:
                          context.l10n.homeComercioCreateActivityDescription,
                      buttonText: context.l10n.homeComercioCreateActivityButton,
                      onButtonPressed: () async {
                        final activity =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateActivityScreen(),
                              ),
                            );

                        if (activity != null) {
                          setState(() {
                            _actividades.add(activity);
                          });

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.homeComercioActivityCreatedSnackbar(
                                  activity['name'],
                                ),
                              ),
                              backgroundColor: AppColors.ink,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.homeComercioMyActivitiesTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(context.l10n.homeComercioSeeAllButton),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 150,
                    child: _actividades.isEmpty
                        ? _buildEmptyActivities()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _actividades.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final activity = _actividades[index];
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 70 * index),
                                offset: const Offset(0.12, 0),
                                child: _buildActivityCard(
                                  title: activity['name'] ??
                                      context.l10n.homeComercioNoNameFallback,
                                  description: activity['description'] ?? '',
                                  date: activity['hasNoEndDate'] == true
                                      ? (activity['startDate'] ?? '')
                                      : '${activity['startDate']} - ${activity['endDate']}',
                                  category: activity['category'],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ComercioBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.ink,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.ink),
            const RoutePatternBackground(opacity: 0.12),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TravelGuardBadge(size: 42, animate: false),
                        InkWell(
                          onTap: () => _confirmSignOut(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.homeComercioSignOut,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.homeComercioGreeting(businessName),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.homeComercioHeroSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsStrip() {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.event_note,
            label: context.l10n.homeComercioStatActivitiesLabel,
            value: '${_actividades.length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.restaurant_menu,
            label: context.l10n.homeComercioStatMenusLabel,
            value: '${_menus.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyActivities() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 44,
            color: AppColors.hair,
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.homeComercioEmptyActivitiesTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.homeComercioEmptyActivitiesSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return BoardingPassCard(
      leading: Icon(icon, size: 30, color: AppColors.ink),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onButtonPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String description,
    required String date,
    required String? category,
  }) {
    return SizedBox(
      width: 210,
      child: BoardingPassCard(
        padding: const EdgeInsets.all(14),
        leadingWidth: 48,
        leading: Icon(
          _iconForCategory(category),
          color: AppColors.ink,
          size: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case 'Fiesta':
        return Icons.celebration_outlined;
      case 'Tour':
        return Icons.tour_outlined;
      case 'Promoción':
        return Icons.local_offer_outlined;
      case 'Clase':
        return Icons.school_outlined;
      case 'Evento':
        return Icons.event_outlined;
      default:
        return Icons.event_note_outlined;
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.ink),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación flotante tipo píldora — mismos 3 ítems y misma
/// lógica que la `BottomNavigationBar` original de esta pantalla.
class _ComercioBottomNav extends StatelessWidget {
  const _ComercioBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  List<({IconData icon, IconData activeIcon, String label})> _items(
    BuildContext context,
  ) => [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: context.l10n.homeComercioNavHome,
    ),
    (
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: context.l10n.homeComercioNavActivities,
    ),
    (
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: context.l10n.homeComercioNavMenu,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == selectedIndex;
            final color =
                selected ? AppColors.ink : AppColors.textMuted;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => onItemSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? item.activeIcon : item.icon,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
