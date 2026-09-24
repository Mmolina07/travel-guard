import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/hover_card.dart';
import '../../../widgets/map_panel.dart';
import '../../../widgets/place_card.dart';
import '../../trips/presentation/pages/create_trip_screen.dart';
import '../data/location_service.dart';
import '../data/models/map_place.dart';
import '../data/places_map_repository.dart';
import 'widgets/place_details_sheet.dart';

/// HU-07: comercios y lugares de interés cercanos, con datos reales de
/// Supabase y distancia real a la ubicación actual del turista — nada
/// quemado (antes esta pantalla tenía una lista fija de Cartagena).
class ComerciosCercanosScreen extends StatefulWidget {
  const ComerciosCercanosScreen({super.key});

  @override
  State<ComerciosCercanosScreen> createState() => _ComerciosCercanosScreenState();
}

class _ComerciosCercanosScreenState extends State<ComerciosCercanosScreen> {
  final PlacesMapRepository _repository = PlacesMapRepository();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  String? _loadError;
  List<MapPlace> _places = [];
  Position? _userPosition;
  int _selectedCategoryIndex = 0;
  MapPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Antes un solo `Future.wait` combinaba comercios + ubicación: si
  /// fallaba la ubicación (GPS apagado, permiso denegado), toda la
  /// promesa rechazaba sin que nada la atrapara y la pantalla se
  /// quedaba en "cargando" para siempre, aunque los comercios sí se
  /// hubieran podido traer. Ahora van por separado: los comercios son
  /// obligatorios (si fallan, se ve un estado de error con reintentar),
  /// la ubicación es "mejor esfuerzo" (si falla, la lista igual se
  /// muestra, solo sin ordenar por distancia).
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final places = await _repository.fetchNearbyPlaces();
      if (!mounted) return;
      setState(() {
        _places = places;
        _isLoading = false;
        _selectedPlace = places.isNotEmpty ? places.first : null;
      });
    } catch (e, st) {
      debugPrint('ComerciosCercanosScreen._load fetchNearbyPlaces error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'No se pudieron cargar los comercios. Intenta de nuevo.';
      });
      return;
    }

    try {
      final locationResult = await _locationService.getCurrentPosition();
      if (!mounted || !locationResult.isSuccess) return;
      setState(() => _userPosition = locationResult.position);
    } catch (e, st) {
      debugPrint('ComerciosCercanosScreen._load getCurrentPosition error: $e\n$st');
    }
  }

  double? _distanceMeters(MapPlace place) {
    final user = _userPosition;
    if (user == null) return null;
    return Geolocator.distanceBetween(user.latitude, user.longitude, place.latitud, place.longitud);
  }

  String? _formatDistance(double? meters) {
    if (meters == null) return null;
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  List<String> get _categories {
    final categorias = _places.map((p) => p.categoria).toSet().toList()..sort();
    return ['Todos', ...categorias];
  }

  List<MapPlace> get _filteredPlaces {
    final selectedCategory = _categories[_selectedCategoryIndex];
    final filtered = selectedCategory == 'Todos'
        ? _places
        : _places.where((p) => p.categoria == selectedCategory).toList();
    final sorted = [...filtered]
      ..sort((a, b) {
        final da = _distanceMeters(a) ?? double.infinity;
        final db = _distanceMeters(b) ?? double.infinity;
        return da.compareTo(db);
      });
    return sorted;
  }

  /// Real, no decorativo: solo dice "Abierto ahora" cuando el lugar
  /// tiene horario cargado y se puede calcular con certeza — si falta
  /// el dato, simplemente no muestra el tag (nada de inventarlo).
  bool? _isOpenNow(MapPlace place) {
    final open = _parseTime(place.horarioApertura);
    final close = _parseTime(place.horarioCierre);
    if (open == null || close == null) return null;
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final openMin = open.hour * 60 + open.minute;
    final closeMin = close.hour * 60 + close.minute;
    if (closeMin >= openMin) return nowMin >= openMin && nowMin < closeMin;
    return nowMin >= openMin || nowMin < closeMin; // horario que cruza medianoche.
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  void _openPlaceDetails(MapPlace place) {
    setState(() => _selectedPlace = place);
    PlaceDetailsSheet.show(
      context,
      place: place,
      repository: _repository,
      distanceLabel: _formatDistance(_distanceMeters(place)) ?? '',
    );
  }

  Future<void> _createTrip() async {
    await showCreateTripDialog(context);
  }

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        context.go('/');
        break;
      case AppSection.comercios:
        break; // ya estamos aquí.
      case AppSection.mapa:
        context.go('/mapa');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return _buildMobile(context);
        }
        return AppShell(
          section: AppSection.comercios,
          onNavigate: _handleSideNav,
          onCreateTrip: _createTrip,
          child: _buildDesktopContent(context),
        );
      },
    );
  }

  // ─── Escritorio / tablet ───

  Widget _buildDesktopContent(BuildContext context) {
    final places = _filteredPlaces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(places.length),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final grid = _buildPlacesGrid(places);
            final map = MapPanel(
              places: places,
              selected: _selectedPlace,
              height: 640,
              onSelectPlace: (place) => setState(() => _selectedPlace = place),
            );
            if (constraints.maxWidth >= 820) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 15, child: grid),
                  const SizedBox(width: 22),
                  Expanded(flex: 10, child: map),
                ],
              );
            }
            return Column(
              children: [
                SizedBox(height: 320, child: map),
                const SizedBox(height: 24),
                grid,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderRow(int count) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count == 1 ? '1 LUGAR' : '$count LUGARES',
                style: AppText.label(11, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Cerca ', style: AppText.display(40)),
                  Text('de ti', style: AppText.displayItalic(40)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Comercios y lugares verificados cerca de tu ubicación.',
                style: AppText.ui(14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: FilterChipsRow(
            items: _categories,
            selected: _selectedCategoryIndex,
            onSelect: (i) => setState(() => _selectedCategoryIndex = i),
            alignment: WrapAlignment.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesGrid(List<MapPlace> places) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    if (_loadError != null) return _buildErrorState();
    if (places.isEmpty) return _buildEmptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 280).floor().clamp(1, 3);
        final cardWidth = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final place in places)
              SizedBox(
                width: cardWidth,
                child: PlaceCard(
                  variant: PlaceCardVariant.featured,
                  name: place.nombre,
                  imageUrl: place.fotoUrl,
                  categoryLabel: place.categoria.toUpperCase(),
                  distanceLabel: _formatDistance(_distanceMeters(place)),
                  address: place.direccion,
                  tags: [
                    const PlaceCardTag('Verificado', emphasis: true),
                    if (_isOpenNow(place) == true) const PlaceCardTag('Abierto ahora'),
                  ],
                  onTap: () => _openPlaceDetails(place),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
    return HoverCard(
      onTap: _load,
      color: AppColors.wash,
      radius: AppRadius.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_loadError!, style: AppText.display(20)),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reintentar',
                style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.refresh, size: 16, color: AppColors.inkSoft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedCategory = _categories[_selectedCategoryIndex];
    return HoverCard(
      color: AppColors.wash,
      radius: AppRadius.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategory == 'Todos'
                ? 'Todavía no hay comercios ni lugares registrados'
                : 'No hay lugares en esta categoría',
            style: AppText.display(22),
          ),
          const SizedBox(height: 6),
          Text('Prueba con otra categoría o vuelve más tarde.', style: AppText.ui(13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ─── Móvil ───
  // No forma parte del alcance de esta pasada de escritorio; mantiene
  // la estructura anterior funcionando.

  Widget _buildMobile(BuildContext context) {
    final comercios = _filteredPlaces;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Comercios cercanos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.ink))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.ink,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _userPosition != null ? 'Cerca de tu ubicación actual' : 'Ubicación no disponible',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${comercios.length} lugar(es) encontrados', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final label = _categories[index];
                      final isSelected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.ink : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.ink : AppColors.hair, width: 1.5),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: comercios.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: comercios.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final place = comercios[index];
                            return PlaceCard(
                              variant: PlaceCardVariant.featured,
                              name: place.nombre,
                              imageUrl: place.fotoUrl,
                              categoryLabel: place.categoria.toUpperCase(),
                              distanceLabel: _formatDistance(_distanceMeters(place)),
                              address: place.direccion,
                              tags: [
                                const PlaceCardTag('Verificado', emphasis: true),
                                if (_isOpenNow(place) == true) const PlaceCardTag('Abierto ahora'),
                              ],
                              onTap: () => _openPlaceDetails(place),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
