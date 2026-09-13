//pantalla principal del turista, crear viaje 
import 'package:flutter/material.dart';
import '../Pages/create_trip_screen.dart';
import '../../../places_map/presentation/map_screen.dart';

class HomeScreenClient extends StatefulWidget {
  const HomeScreenClient({Key? key}) : super(key: key);

  @override
  State<HomeScreenClient> createState() => _HomeScreenClientState();
}

class _HomeScreenClientState extends State<HomeScreenClient> {
  int _selectedIndex = 0;
  final String userName = 'Ana';

  Map<String, String>? _newTrip;

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
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
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
                    // Elementos decorativos
                    Positioned(
                      right: 20,
                      top: 40,
                      child: Icon(
                        Icons.flight,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 20,
                      child: Icon(
                        Icons.landscape,
                        size: 100,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    // Texto principal
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
                            '¡Hola, $userName!',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explora, planifica y viaja seguro',
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
                  // Tarjeta "Crear un viaje"
                  _buildFeatureCard(
                    icon: Icons.luggage_outlined,
                    title: 'Crear un viaje',
                    description:
                        'Organiza tu próxima aventura, establece tu presupuesto y descubre los mejores destinos.',
                    buttonText: '+ Crear viaje',
                    onButtonPressed: () async {
                      final trip = await Navigator.push<Map<String, String>>(context, MaterialPageRoute(builder: (context) => const CreateTripScreen()));
                      if (trip != null) {
                        setState(() {
                          _newTrip = trip;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta "Mapa"
                  _buildMapCard(),
                  const SizedBox(height: 40),

                  // Sección "Mis viajes"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis viajes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5F7A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lista de viajes
                  // Lista de viajes
                  SizedBox(
                    height: 220,
                    child: _newTrip == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.luggage_outlined,
                                  size: 50,
                                  color: Color(0xFFB0D9E8),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Aún no tienes viajes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A5F7A),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Crea tu primer viaje para comenzar a planificar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildTripCard(
                                image: '',
                                title: _newTrip!['name']!,
                                dates:
                                    '${_newTrip!['startDate']} - ${_newTrip!['endDate']}',
                                location: _newTrip!['destination']!,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 30),

                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              // Inicio
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTripScreen(),
                ),
              );
              break;

            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTripScreen(), // Cambia esto a la pantalla de comercios cuando esté disponible
                ),
              );
              break;
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
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Crear viaje',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Comercios',
          ),
        ],
      ),
    );
  }


  // Widget para tarjeta de característica
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
                horizontal: 20,
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

  // Widget para tarjeta de mapa
  Widget _buildMapCard() {
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
            child: const Icon(
              Icons.location_on_outlined,
              size: 32,
              color: Color(0xFF1A5F7A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explora destinos, encuentra comercios seguros y planifica tu ruta.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF1A5F7A),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Ver mapa',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A5F7A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE8F4F8),
            ),
            child: Stack(
              children: [
                // Simulación de mapa
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFC8E6F5),
                  ),
                ),
                const Positioned(
                  left: 20,
                  top: 15,
                  child: Icon(
                    Icons.location_on,
                    color: Color(0xFF1A5F7A),
                    size: 24,
                  ),
                ),
                const Positioned(
                  right: 25,
                  bottom: 20,
                  child: Icon(
                    Icons.shield,
                    color: Color(0xFF1A5F7A),
                    size: 20,
                  ),
                ),
                const Positioned(
                  left: 40,
                  bottom: 30,
                  child: Icon(
                    Icons.restaurant,
                    color: Color(0xFF1A5F7A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para tarjeta de viaje
  Widget _buildTripCard({
    required String image,
    required String title,
    required String dates,
    required String location,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              color: const Color(0xFFE8F4F8),
            ),
            child: Stack(
              children: [
                // Placeholder de imagen
                Container(
                  color: const Color(0xFFB0D9E8),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(child: Text('Ver detalles')),
                      const PopupMenuItem(child: Text('Editar')),
                      const PopupMenuItem(child: Text('Eliminar')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
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
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dates,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}