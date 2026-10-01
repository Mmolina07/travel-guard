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
import '../presentation/business_settings_screen.dart';


class HomeScreenComercio extends StatefulWidget {
  const HomeScreenComercio({Key? key}) : super(key: key);

  @override
  State<HomeScreenComercio> createState() => _HomeScreenComercioState();
}

class _HomeScreenComercioState extends State<HomeScreenComercio> {
  // ========== VARIABLES DE ESTADO ==========
  final List<Map<String, dynamic>> _actividades = [];
  final List<Menu> _menus = [];
  bool _isLoadingActividades = false;
  bool _isLoadingMenus = false;
  String _businessSchedule = '';
  String _businessContact = '';


  // ========== GETTERS ==========
  String get businessName => context.watch<AppAuthProvider>().displayName;

  int get _totalActividades => _actividades.length;
  int get _totalMenus => _menus.length;

  /// Actividad más próxima
  Map<String, dynamic>? get _nextActividad {
    if (_actividades.isEmpty) return null;
    return _actividades.first;
  }

  // ========== CICLO DE VIDA ==========
  @override
  void initState() {
    super.initState();
    _loadActividades();
    _loadMenus();
  }

  Future<void> _loadActividades() async {
    setState(() => _isLoadingActividades = true);
    try {
      // TODO: Cargar desde repositorio real
      if (!mounted) return;
      setState(() => _isLoadingActividades = false);
    } catch (e, st) {
      debugPrint('HomeScreenComercio._loadActividades error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingActividades = false);
    }
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoadingMenus = true);
    try {
      // TODO: Cargar desde repositorio real
      if (!mounted) return;
      setState(() => _isLoadingMenus = false);
    } catch (e, st) {
      debugPrint('HomeScreenComercio._loadMenus error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingMenus = false);
    }
  }

  // ========== MÉTODOS DE NAVEGACIÓN ==========
  void _openMenuDetail(Menu menu) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MenuDetailScreen(menu: menu)),
    );
  }

  // ========== MÉTODOS DE INTERACCIÓN ==========
  Future<void> _createMenu() async {
    final newMenu = await Navigator.push<Menu>(
      context,
      MaterialPageRoute(builder: (_) => const CreateMenuScreen()),
    );

    if (!mounted) return;

    if (newMenu != null) {
      setState(() => _menus.add(newMenu));
      _showSnack('Menú "${newMenu.name}" creado');
      
      if (!mounted) return;
      _openMenuDetail(newMenu);
    }
  }

  Future<void> _createActivity() async {
    final activity = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
    );

    if (!mounted) return;

    if (activity != null) {
      setState(() => _actividades.add(activity));
      _showSnack('Actividad "${activity['name']}" creada');
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text('Cerrar sesión', style: AppText.display(18)),
        content: Text('¿Seguro que quieres cerrar tu sesión?', style: AppText.ui(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: AppText.ui(14, color: AppColors.ink)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Cerrar sesión', style: AppText.ui(14, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AppAuthProvider>().signOut();
      if (context.mounted) context.go('/login');
    }
  }

  void _showSnack(String message, {Color color = AppColors.ink}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobile();
        }
        return _buildDesktop();
      },
    );
  }

  Future<void> _editBusiness() async {
  final result = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(
      builder: (_) => BusinessSettingsScreen(
        initialName: businessName,
        initialSchedule: _businessSchedule,
        initialContact: _businessContact,
      ),
    ),
  );

  if (!mounted || result == null) return;

  setState(() {
    _businessSchedule = result['schedule'] ?? '';
    _businessContact = result['contact'] ?? '';
  });

  _showSnack('Datos del negocio actualizados');
}


  // ========== DESKTOP ==========
  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingRow(),
                const SizedBox(height: 40),
                _buildActionGrid(),
                const SizedBox(height: 48),
                _buildMenusAndActivitiesRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingRow() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // SALUDO
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${_firstName(businessName)}.',
              style: AppText.display(42),
            ),
            Text(
              'Gestiona tu negocio fácilmente',
              style: AppText.displayItalic(42),
            ),
          ],
        ),
      ),

      const SizedBox(width: 24),

      // PRÓXIMA ACTIVIDAD
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          _nextActividad != null
              ? 'Próxima: ${_nextActividad!['name']}'
              : 'Crea tu primera actividad para tus clientes.',
          style: AppText.ui(
            14,
            color: AppColors.textMuted,
          ),
        ),
      ),

      const SizedBox(width: 24),

      // BOTONES
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: _editBusiness,
            icon: const Icon(
              Icons.store_outlined,
              size: 18,
            ),
            label: const Text('Mi negocio'),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(
              Icons.logout,
              size: 18,
            ),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    ],
  );
}


  Widget _buildActionGrid() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: _CrearMenuCard(onTap: _createMenu),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: _EstadisticasCard(
                  menus: _totalMenus,
                  actividades: _totalActividades,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: _CrearActividadCard(onTap: _createActivity),
              ),
              const SizedBox(width: 14),
              const Expanded(flex: 5, child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenusAndActivitiesRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = _buildMenusColumn();
        final right = _buildActivitiesColumn();
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 16, child: left),
              const SizedBox(width: 22),
              Expanded(flex: 10, child: right),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 32), right],
        );
      },
    );
  }

  Widget _buildMenusColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis menús', style: AppText.display(26)),
        const SizedBox(height: 16),
        if (_isLoadingMenus)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
          )
        else if (_menus.isEmpty)
          _buildEmptyMenus()
        else
          Column(
            children: [
              for (var i = 0; i < _menus.length; i++) ...[
                _MenuCard(
                  menu: _menus[i],
                  onTap: () => _openMenuDetail(_menus[i]),
                ),
                if (i != _menus.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildActivitiesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividades recientes', style: AppText.display(26)),
        const SizedBox(height: 16),
        if (_isLoadingActividades)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
          )
        else if (_actividades.isEmpty)
          _buildEmptyActivities()
        else
          _buildActivityCard(
            title: _actividades.first['name'] ?? 'Sin nombre',
            description: _actividades.first['description'] ?? '',
            date: _actividades.first['hasNoEndDate'] == true
                ? (_actividades.first['startDate'] ?? '')
                : '${_actividades.first['startDate']} - ${_actividades.first['endDate']}',
            category: _actividades.first['category'],
          ),
      ],
    );
  }

  Widget _buildEmptyMenus() {
    return GestureDetector(
      onTap: _createMenu,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.wash,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aún no tienes menús', style: AppText.display(22)),
            const SizedBox(height: 6),
            Text(
              'Crea tu primer menú para mostrar tus servicios.',
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crear menú',
                  style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.inkSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return GestureDetector(
      onTap: _createActivity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.wash,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aún no tienes actividades', style: AppText.display(22)),
            const SizedBox(height: 6),
            Text(
              'Crea tu primera actividad para tus clientes.',
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crear actividad',
                  style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.inkSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== MOBILE ==========
  Widget _buildMobile() {
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
                      description: 'Crea y gestiona los platos y servicios de tu negocio.',
                      buttonText: '+ Menú',
                      onButtonPressed: _createMenu,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _buildFeatureCard(
                      icon: Icons.event_note,
                      title: 'Crear actividad',
                      description: 'Organiza eventos y promociones para tus clientes.',
                      buttonText: '+ Actividad',
                      onButtonPressed: _createActivity,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mis actividades', style: AppText.display(22)),
                      TextButton(onPressed: () {}, child: const Text('Ver todas')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: _isLoadingActividades
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.ink),
                          )
                        : _actividades.isEmpty
                            ? _buildMobileEmptyActivities()
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _actividades.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
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
        onItemSelected: (index) {
          if (index == 1) {
            _createActivity();
          } else if (index == 2) {
            _createMenu();
          }
        },
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
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout, size: 16, color: Colors.white),
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
            icon: Icons.restaurant_menu,
            label: 'Menús',
            value: '$_totalMenus',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.event_note,
            label: 'Actividades',
            value: '$_totalActividades',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileEmptyActivities() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy_outlined, size: 44, color: AppColors.hair),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes actividades',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea tu primera actividad para tus visitantes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                Text(title, style: AppText.ui(17, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText)),
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
                  style: AppText.ui(15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(11, weight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String name) => name.trim().split(' ').first;

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

// ========== WIDGETS PRIVADOS ==========

class _CrearMenuCard extends StatelessWidget {
  const _CrearMenuCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadow.raised,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.add, color: AppColors.ink, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Crear menú', style: AppText.display(26, color: AppColors.paper)),
                const SizedBox(height: 4),
                Text(
                  'Agrega platos y servicios en segundos',
                  style: AppText.ui(12, color: AppColors.textOnInk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CrearActividadCard extends StatelessWidget {
  const _CrearActividadCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVIDADES',
                  style: AppText.label(
                    10,
                    weight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.add, color: AppColors.ink, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Crear actividad', style: AppText.display(24)),
                const SizedBox(height: 4),
                Text(
                  'Eventos y promociones para tus clientes',
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadisticasCard extends StatelessWidget {
  const _EstadisticasCard({required this.menus, required this.actividades});

  final int menus;
  final int actividades;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ESTADÍSTICAS',
            style: AppText.label(
              10,
              weight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$menus', style: AppText.display(22)),
                    Text('Menús', style: AppText.ui(12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$actividades', style: AppText.display(22)),
                    Text('Actividades', style: AppText.ui(12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.menu, required this.onTap});

  final Menu menu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.restaurant_menu, color: AppColors.inkSoft, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: AppText.ui(15, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${menu.getProductCount()} productos',
                        style: AppText.ui(12, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (menu.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Disponible',
                            style: AppText.ui(10, color: AppColors.ink, weight: FontWeight.w600),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.hair,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'No disponible',
                            style: AppText.ui(10, color: AppColors.textMuted, weight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value});

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
          Text(value, style: AppText.ui(18, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppText.ui(11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ComercioBottomNav extends StatelessWidget {
  const _ComercioBottomNav({required this.onItemSelected});

  final ValueChanged<int> onItemSelected;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    (icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Actividades'),
    (icon: Icons.storefront_outlined, activeIcon: Icons.storefront, label: 'Menú'),
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
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => onItemSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AppColors.textMuted, size: 22),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: AppText.ui(11, weight: FontWeight.w600, color: AppColors.textMuted),
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