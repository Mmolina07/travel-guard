import 'package:flutter/material.dart';
import '../presentation/menu_model.dart';
import '../presentation/create_activity_screen.dart';
import '../presentation/create_menu_screen.dart';
import '../presentation/menu_detail_screen.dart';

class HomeScreenComercio extends StatefulWidget {
  const HomeScreenComercio({Key? key}) : super(key: key);

  @override
  State<HomeScreenComercio> createState() => _HomeScreenComercioState();
}

class _HomeScreenComercioState extends State<HomeScreenComercio> {
  int _selectedIndex = 0;
  final String businessName = 'Mi Negocio';
  final List<Map<String, dynamic>> _actividades = [];
  final List<Menu> _menus = [];  // ← AGREGAR LISTA DE MENÚS

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar personalizado
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A5F7A),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A5F7A),
                      const Color(0xFF0F4C5F),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 40,
                      child: Icon(
                        Icons.storefront,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 20,
                      child: Icon(
                        Icons.restaurant,
                        size: 100,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 60,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, $businessName!',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestiona tu negocio fácilmente',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta "Agregar Menú"
                  _buildFeatureCard(
                    icon: Icons.restaurant_menu,
                    title: 'Agregar Menú',
                    description:
                        'Crea y gestiona los platos, bebidas y servicios que ofrece tu negocio.',
                    buttonText: '+ Menú',
                    onButtonPressed: () async {
                      // ← CAMBIO: Agregar menú como con actividades
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

                        // Mostrar detalles del menú creado
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuDetailScreen(menu: newMenu),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Menú "${newMenu.name}" creado'),
                            backgroundColor: const Color(0xFF1A5F7A),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta "Crear Actividad"
                  _buildFeatureCard(
                    icon: Icons.event_note,
                    title: 'Crear Actividad',
                    description:
                        'Organiza eventos, promociones y actividades especiales para tus clientes.',
                    buttonText: '+ Actividad',
                    onButtonPressed: () async {
                      final activity = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateActivityScreen(),
                        ),
                      );

                      if (activity != null) {
                        setState(() {
                          _actividades.add(activity);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Actividad "${activity['name']}" creada'),
                            backgroundColor: const Color(0xFF1A5F7A),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),

                  // Sección "Mis Actividades"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis Actividades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5F7A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lista de actividades
                  SizedBox(
                    height: 220,
                    child: _actividades.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 50,
                                  color: Color(0xFFB0D9E8),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Aún no tienes actividades',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A5F7A),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Crea tu primera actividad.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _actividades.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final activity = _actividades[index];
                              return _buildActivityCard(
                                title: activity['name'] ?? 'Sin nombre',
                                description: activity['description'] ?? '',
                                date: activity['hasNoEndDate'] == true
                                    ? (activity['startDate'] ?? '')
                                    : '${activity['startDate']} - ${activity['endDate']}',
                                color: _colorForCategory(activity['category']),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            // Inicio - ya estamos aquí
          } else if (index == 1) {
            // Crear Actividad
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateActivityScreen(),
              ),
            );
          } else if (index == 2) {
              // Menú
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
                    backgroundColor: Color(0xFF1A5F7A),
                  ),
                );
              }
            }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A5F7A),
        unselectedItemColor: const Color(0xFF9E9E9E),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Menú',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0EEF7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF1A5F7A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F7A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String description,
    required String date,
    required Color color,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 14,
                  color: Color(0xFF1A5F7A),
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForCategory(String? category) {
    switch (category) {
      case 'Fiesta':
        return const Color(0xFFF3E5F5);
      case 'Tour':
        return const Color(0xFFE3F2FD);
      case 'Promoción':
        return const Color(0xFFFFF3E0);
      case 'Clase':
        return const Color(0xFFE8F5E9);
      case 'Evento':
        return const Color(0xFFFCE4EC);
      default:
        return const Color(0xFFE8F4F8);
    }
  }
}