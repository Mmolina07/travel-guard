import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/hover_card.dart';
import '../../../widgets/ink_header.dart';
import '../../../widgets/map_panel.dart';
import '../../../widgets/place_card.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/stagger_in.dart';
import '../../trips/presentation/pages/create_trip_screen.dart';
import '../data/location_service.dart';
import '../data/models/map_place.dart';
import '../data/places_map_repository.dart';
import '../data/places_realtime.dart';
import 'widgets/category_label.dart';
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

  // TG-289: si un comercio cambia sus datos, la lista y el mapa se
  // actualizan solos, sin volver a mostrar "cargando".
  StreamSubscription<PlacesChange>? _realtimeSub;
  final _realtimeDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _load();
    _realtimeSub = PlacesRealtime.instance.changes.listen(
      (_) => _realtimeDebouncer(_reloadSilently),
    );
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _realtimeDebouncer.dispose();
    super.dispose();
  }

  Future<void> _reloadSilently() async {
    try {
      final places = await _repository.fetchNearbyPlaces();
      if (!mounted) return;
      final selected = _selectedPlace;
      setState(() {
        _places = places;
        _selectedPlace = selected == null
            ? (places.isNotEmpty ? places.first : null)
            : places.cast<MapPlace?>().firstWhere(
                  (p) => p!.type == selected.type && p.id == selected.id,
                  orElse: () => places.isNotEmpty ? places.first : null,
                );
      });
    } catch (e, st) {
      debugPrint('ComerciosCercanosScreen._reloadSilently error: $e\n$st');
    }
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
        _loadError = context.l10n.comerciosCercanosLoadError;
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
      case AppSection.actividades:
        context.go('/actividades');
        break;
      case AppSection.promociones:
        context.go('/promociones');
        break;
      case AppSection.suscripciones:
        context.go('/suscripciones');
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
            final user = _userPosition;
            final map = MapPanel(
              places: places,
              userLocation: user == null ? null : LatLng(user.latitude, user.longitude),
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
    final categories = _categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.comerciosCercanosPlacesCountLabel(count),
                style: AppText.label(11, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(context.l10n.comerciosCercanosHeaderTitle1, style: AppText.display(40)),
                  Text(context.l10n.comerciosCercanosHeaderTitle2, style: AppText.displayItalic(40)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.comerciosCercanosHeaderSubtitle,
                style: AppText.ui(14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Fila propia a ancho completo con scroll horizontal: con Wrap
        // quedaba descuadrada (número de chips + textos en inglés no
        // caben parejo en dos líneas junto al título).
        FilterChipsRow(
          items: [for (final c in categories) localizedCategoryOrAll(context, c)],
          selected: _selectedCategoryIndex,
          onSelect: (i) => setState(() => _selectedCategoryIndex = i),
          forceScrollable: true,
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
                  categoryLabel: localizedCategoryLabel(context, place.categoria).toUpperCase(),
                  distanceLabel: _formatDistance(_distanceMeters(place)),
                  address: place.direccion,
                  tags: [
                    PlaceCardTag(context.l10n.comerciosCercanosTagVerified, emphasis: true),
                    if (_isOpenNow(place) == true) PlaceCardTag(context.l10n.comerciosCercanosTagOpenNow),
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
                context.l10n.comerciosCercanosRetryLabel,
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
                ? context.l10n.comerciosCercanosEmptyAll
                : context.l10n.comerciosCercanosEmptyCategory,
            style: AppText.display(22),
          ),
          const SizedBox(height: 6),
          Text(context.l10n.comerciosCercanosEmptyHint, style: AppText.ui(13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ─── Móvil ───
  // Anatomía móvil del handoff (› Comercios cercanos): cabecera `ink`
  // con `bottomRight: 44`, chips con scroll horizontal, tarjetas
  // destacadas y la píldora flotante "Ver en el mapa".

  Widget _buildMobile(BuildContext context) {
    final places = _filteredPlaces;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              InkHeader(
                eyebrow: context.l10n.comerciosCercanosPlacesCountLabel(places.length),
                title: context.l10n.comerciosCercanosHeaderTitle1.trim(),
                titleAccent: context.l10n.comerciosCercanosHeaderTitle2,
                subtitle: _userPosition != null
                    ? context.l10n.comerciosCercanosHeaderSubtitle
                    : context.l10n.comerciosCercanosLocationUnavailable,
                onBack: () => context.go('/'),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilterChipsRow(
                  items: [for (final c in _categories) localizedCategoryOrAll(context, c)],
                  selected: _selectedCategoryIndex,
                  onSelect: (i) => setState(() => _selectedCategoryIndex = i),
                  forceScrollable: true,
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading || _loadError != null || places.isEmpty
                    ? _buildPlacesGrid(places)
                    : Column(
                        children: [
                          for (var i = 0; i < places.length; i++) ...[
                            StaggerIn(
                              index: i,
                              child: PlaceCard(
                                variant: PlaceCardVariant.featured,
                                name: places[i].nombre,
                                imageUrl: places[i].fotoUrl,
                                categoryLabel:
                                    localizedCategoryLabel(context, places[i].categoria).toUpperCase(),
                                distanceLabel: _formatDistance(_distanceMeters(places[i])),
                                address: places[i].direccion,
                                tags: [
                                  PlaceCardTag(context.l10n.comerciosCercanosTagVerified, emphasis: true),
                                  if (_isOpenNow(places[i]) == true)
                                    PlaceCardTag(context.l10n.comerciosCercanosTagOpenNow),
                                ],
                                onTap: () => _openPlaceDetails(places[i]),
                              ),
                            ),
                            if (i != places.length - 1) const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: SafeArea(
              top: false,
              child: Center(child: _MapPill(onTap: () => context.go('/mapa'))),
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora flotante del handoff: `ink` radio 22, punto `mint` 8 px.
class _MapPill extends StatelessWidget {
  const _MapPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadow.inkButton,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.homeClientViewMapButton,
              style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.paper),
            ),
          ],
        ),
      ),
    );
  }
}
