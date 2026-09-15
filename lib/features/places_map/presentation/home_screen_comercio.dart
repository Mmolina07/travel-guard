import 'package:flutter/material.dart';
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
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppAuthProvider>().signOut();
      // `AuthGate` (main.dart) reacciona al cambio de estado y ya
      // muestra `WelcomeHome` de fondo, pero esta pantalla se abrió con
      // `Navigator.push` desde el login — sin este pop, sigue encima
      // en la pila y el usuario ve la sesión "sin cerrar" hasta que
      // presiona atrás.
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
            content: Text('Actividad "${activity['name']}" creada'),
            backgroundColor: AppColors.primaryLight,
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
          const SnackBar(
            content: Text('Crea tu primer menú'),
            backgroundColor: AppColors.primaryLight,
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
                      title: 'Agregar menú',
                      description:
                          'Crea y gestiona los platos, bebidas y servicios que ofrece tu negocio.',
                      buttonText: '+ Menú',
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
                              content: Text('Menú "${newMenu.name}" creado'),
                              backgroundColor: AppColors.primaryLight,
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
                      title: 'Crear actividad',
                      description:
                          'Organiza eventos, promociones y actividades especiales para tus clientes.',
                      buttonText: '+ Actividad',
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
                                'Actividad "${activity['name']}" creada',
                              ),
                              backgroundColor: AppColors.primaryLight,
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
                      const Text(
                        'Mis actividades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todas'),
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
                                  title: activity['name'] ?? 'Sin nombre',
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
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryLight, Color(0xFF0F4C5F)],
                ),
              ),
            ),
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
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
                      '¡Hola, $businessName!',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestiona tu negocio fácilmente',
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
            label: 'Actividades',
            value: '${_actividades.length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.restaurant_menu,
            label: 'Menús creados',
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
            color: Color(0xFFB0D9E8),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes actividades',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea tu primera actividad para tus visitantes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
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
      leading: Icon(icon, size: 30, color: AppColors.primaryLight),
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
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondaryLight,
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
          color: AppColors.primaryLight,
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
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
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
                  color: AppColors.textSecondaryLight,
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
                      color: AppColors.textSecondaryLight,
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
        color: AppColors.primaryLight.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
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

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    (
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Actividades',
    ),
    (
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Menú',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == selectedIndex;
            final color =
                selected ? AppColors.primaryLight : AppColors.textSecondaryLight;
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
