import 'package:flutter/material.dart';

class ComerciosCercanosScreen extends StatefulWidget {
  const ComerciosCercanosScreen({Key? key}) : super(key: key);

  @override
  State<ComerciosCercanosScreen> createState() =>
      _ComerciosCercanosScreenState();
}

class _ComerciosCercanosScreenState extends State<ComerciosCercanosScreen> {
  String _selectedCategory = 'Todos';

  // Datos de prueba
  final List<Map<String, dynamic>> _comercios = [
    {
      'name': 'Restaurante La Cevichería',
      'category': 'Comida',
      'description':
          'La mejor cevichería del centro histórico, especialidad en mariscos frescos.',
      'rating': 4.7,
      'distance': '500m',
      'address': 'Centro histórico, Cartagena',
      'isOpen': true,
      'schedule': 'hasta 22:00',
    },
    {
      'name': 'Hotel Casa San Agustín',
      'category': 'Hospedaje',
      'description':
          'Hotel boutique en el corazón de Getsemaní. Piscina y desayuno incluido.',
      'rating': 4.9,
      'distance': '1.2km',
      'address': 'Getsemaní, Cartagena',
      'isOpen': true,
      'schedule': '24 horas',
    },
    {
      'name': 'Tour Nocturno por la Muralla',
      'category': 'Tours',
      'description':
          'Recorrido guiado por la muralla y el centro amurallado de noche.',
      'rating': 4.8,
      'distance': '800m',
      'address': 'Plaza de la Aduana',
      'isOpen': false,
      'schedule': 'Abre a las 19:00',
    },
    {
      'name': 'Café del Mar',
      'category': 'Comida',
      'description':
          'Café con vista al mar, ideal para atardeceres. Especialidad en café de altura.',
      'rating': 4.5,
      'distance': '300m',
      'address': 'Bocagrande, Cartagena',
      'isOpen': true,
      'schedule': 'hasta 20:00',
    },
  ];

  List<Map<String, dynamic>> get _filteredComercios {
    if (_selectedCategory == 'Todos') return _comercios;
    return _comercios
        .where((c) => c['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final comercios = _filteredComercios;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Comercios cercanos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A5F7A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda en desarrollo')),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con ubicación y contador
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1A5F7A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Cartagena, Colombia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${comercios.length} comercios encontrados',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Filtros por categoría
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Todos'),
                const SizedBox(width: 8),
                _buildFilterChip('Comida'),
                const SizedBox(width: 8),
                _buildFilterChip('Hospedaje'),
                const SizedBox(width: 8),
                _buildFilterChip('Tours'),
                const SizedBox(width: 8),
                _buildFilterChip('Entretenimiento'),
                const SizedBox(width: 8),
                _buildFilterChip('Compras'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de comercios
          Expanded(
            child: comercios.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comercios.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildComercioCard(comercios[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Chip de filtro ───
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A5F7A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A5F7A)
                : const Color(0xFFD7E8EF),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF1A5F7A),
          ),
        ),
      ),
    );
  }

  // ─── Tarjeta de comercio ───
  Widget _buildComercioCard(Map<String, dynamic> comercio) {
    final bool isOpen = comercio['isOpen'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen + chip + favorito
          Stack(
            children: [
              // Imagen placeholder
              Container(
                width: double.infinity,
                height: 160,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: Color(0xFFB0D9E8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront,
                    size: 50,
                    color: Colors.white70,
                  ),
                ),
              ),
              // Chip de categoría
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    comercio['category'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A5F7A),
                    ),
                  ),
                ),
              ),
              // Botón favorito
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
              ),
            ],
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  comercio['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 8),

                // Rating + distancia
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xFFFFB300)),
                    const SizedBox(width: 4),
                    Text(
                      '${comercio['rating']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A5F7A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBDBDBD),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.near_me_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comercio['distance'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Descripción
                Text(
                  comercio['description'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Dirección
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
                        comercio['address'],
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
                const SizedBox(height: 6),

                // Estado + horario
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFF2D8659)
                            : const Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'Abierto' : 'Cerrado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOpen
                            ? const Color(0xFF2D8659)
                            : const Color(0xFFD32F2F),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${comercio['schedule']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Detalles de ${comercio['name']}',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A5F7A),
                          side: const BorderSide(color: Color(0xFF1A5F7A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ver detalles',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cómo llegar a ${comercio['name']}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text(
                          'Cómo llegar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5F7A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  // ─── Estado vacío ───
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No hay comercios en esta categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prueba con otra categoría o amplía tu búsqueda.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}