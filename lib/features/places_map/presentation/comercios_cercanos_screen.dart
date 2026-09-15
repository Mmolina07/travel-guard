import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/location_service.dart';
import '../data/models/category_visuals.dart';
import '../data/models/map_place.dart';
import '../data/places_map_repository.dart';
import 'widgets/place_details_sheet.dart';
import '../../../core/theme/app_theme.dart';

/// HU-07: comercios y lugares de interés cercanos, con datos reales de
/// Supabase y distancia real a la ubicación actual del turista — nada
/// quemado (antes esta pantalla tenía una lista fija de Cartagena).
class ComerciosCercanosScreen extends StatefulWidget {
  const ComerciosCercanosScreen({Key? key}) : super(key: key);

  @override
  State<ComerciosCercanosScreen> createState() =>
      _ComerciosCercanosScreenState();
}

class _ComerciosCercanosScreenState extends State<ComerciosCercanosScreen> {
  static const Color _primary = Color(0xFF1A5F7A);

  final PlacesMapRepository _repository = PlacesMapRepository();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  List<MapPlace> _places = [];
  Position? _userPosition;
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _repository.fetchNearbyPlaces(),
      _locationService.getCurrentPosition(),
    ]);
    if (!mounted) return;

    final places = results[0] as List<MapPlace>;
    final locationResult = results[1] as LocationResult;

    setState(() {
      _places = places;
      _userPosition = locationResult.position;
      _isLoading = false;
    });
  }

  double? _distanceMeters(MapPlace place) {
    final user = _userPosition;
    if (user == null) return null;
    return Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      place.latitud,
      place.longitud,
    );
  }

  String? _formatDistance(double? meters) {
    if (meters == null) return null;
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<String> get _categories {
    final categorias = _places.map((p) => p.categoria).toSet().toList()
      ..sort();
    return ['Todos', ...categorias];
  }

  List<MapPlace> get _filteredPlaces {
    final filtered = _selectedCategory == 'Todos'
        ? _places
        : _places.where((p) => p.categoria == _selectedCategory).toList();
    final sorted = [...filtered]
      ..sort((a, b) {
        final da = _distanceMeters(a) ?? double.infinity;
        final db = _distanceMeters(b) ?? double.infinity;
        return da.compareTo(db);
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final comercios = _filteredPlaces;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Comercios cercanos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con ubicación y contador
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: _primary,
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
                          Text(
                            _userPosition != null
                                ? 'Cerca de tu ubicación actual'
                                : 'Ubicación no disponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${comercios.length} lugar(es) encontrados',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filtros por categoría (dinámicos: los que realmente
                // existen en los datos, no una lista fija).
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) =>
                        _buildFilterChip(_categories[index]),
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de lugares
                Expanded(
                  child: comercios.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: comercios.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildPlaceCard(comercios[index]);
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
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primary : const Color(0xFFD7E8EF),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _primary,
          ),
        ),
      ),
    );
  }

  // ─── Fallback: degradado + ícono según categoría (sin foto real) ───
  Widget _buildCategoryHeader(CategoryVisual visual, {bool loading = false}) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.color, visual.color.withOpacity(0.65)],
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(visual.icon, size: 48, color: Colors.white),
      ),
    );
  }

  // ─── Tarjeta de lugar (comercio o lugar de interés) ───
  Widget _buildPlaceCard(MapPlace place) {
    final distancia = _formatDistance(_distanceMeters(place));
    final isComercio = place.type == MapPlaceType.comercio;
    final visual = CategoryVisual.forCategory(place.categoria);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: foto real del lugar si hay, si no degradado + ícono
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: place.fotoUrl != null
                    ? Image.network(
                        place.fotoUrl!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _buildCategoryHeader(visual, loading: true);
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCategoryHeader(visual),
                      )
                    : _buildCategoryHeader(visual),
              ),
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
                    place.categoria,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: visual.color,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isComercio ? Icons.storefront : Icons.place,
                        size: 13,
                        color: _primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isComercio ? 'Comercio' : 'Lugar',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
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
                Text(
                  place.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                if (distancia != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.near_me_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'A $distancia de ti',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
                if (place.descripcion != null &&
                    place.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    place.descripcion!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (place.direccion != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.direccion!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => PlaceDetailsSheet.show(
                      context,
                      place: place,
                      repository: _repository,
                      distanceLabel: distancia ?? '',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver detalles',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  // ─── Estado vacío ───
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              _selectedCategory == 'Todos'
                  ? 'Todavía no hay comercios ni lugares registrados'
                  : 'No hay lugares en esta categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Prueba con otra categoría o vuelve más tarde.',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
