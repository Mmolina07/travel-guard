import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../data/location_service.dart';
import '../data/models/category_visuals.dart';
import '../data/models/map_place.dart';
import '../data/places_map_repository.dart';
import '../data/places_realtime.dart';
import 'widgets/category_label.dart';
import 'widgets/place_details_sheet.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/load_error_box.dart';
import '../../../widgets/map_style.dart';
import '../../../widgets/paper_top_bar.dart';
import '../../../widgets/user_location_marker.dart';
import '../../security_insights/data/models/comuna_geo.dart';
import '../../security_insights/presentation/comuna_polygons.dart';
import '../../security_insights/presentation/widgets/comuna_incidencia_sheet.dart';
import '../../security_insights/presentation/widgets/security_layer_controls.dart';
import '../../security_insights/providers/security_map_provider.dart';
import '../../trips/presentation/pages/create_trip_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String _userMarkerId = 'mi_ubicacion';

  // Medellín: centro de respaldo cuando todavía no se pudo obtener la
  // ubicación real del turista (GPS apagado, permiso denegado, o
  // simplemente mientras se resuelve el primer fix).
  static const LatLng _fallbackCenter = LatLng(6.2442, -75.5812);

  final PlacesMapRepository _placesRepository = PlacesMapRepository();
  final LocationService _locationService = LocationService();

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSub;

  bool _isLoadingPlaces = true;
  /// Falló la carga de lugares y no hay ninguno que mostrar: sin esto el
  /// mapa quedaba vacío como si no hubiera lugares.
  bool _placesError = false;
  bool _isLoadingLocation = true;
  List<MapPlace> _places = [];
  LatLng? _userLatLng;
  LocationFailureReason? _locationFailure;
  String _selectedCategory = 'Todos';
  BitmapDescriptor? _userIcon;
  Offset _userIconAnchor = const Offset(0.5, 0.5);

  // "Se centra siempre en mi ubicación": la cámara sigue al turista en
  // cada actualización de posición, salvo que él mismo la mueva con el
  // dedo (entonces se pausa hasta que toque "reanudar seguimiento").
  bool _isFollowingUser = true;
  bool _ignoreNextCameraMove = false;

  bool get _isLoading => _isLoadingPlaces || _isLoadingLocation;

  /// Comuna con la ficha de incidencia abierta: se resalta en el mapa.
  String? _comunaSeleccionada;

  // TG-289: los cambios de los comercios llegan en tiempo real.
  StreamSubscription<PlacesChange>? _realtimeSub;
  final _realtimeDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _realtimeSub = PlacesRealtime.instance.changes.listen(
      (_) => _realtimeDebouncer(_loadPlaces),
    );
    _loadLocationAndStartWatching();
  }

  String? _userIconLabel;

  /// El ícono lleva texto traducido: se arma aquí (en `initState` todavía
  /// no se puede leer `Localizations`) y se rehace si cambia el idioma.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final label = context.l10n.mapScreenUserHereLabel;
    if (label != _userIconLabel) {
      _userIconLabel = label;
      _buildUserIcon(label);
    }
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _realtimeDebouncer.dispose();
    _positionSub?.cancel();
    super.dispose();
  }

  void _retryPlaces() {
    setState(() {
      _placesError = false;
      _isLoadingPlaces = true;
    });
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _placesRepository.fetchNearbyPlaces();
      if (!mounted) return;
      setState(() {
        _places = places;
        _isLoadingPlaces = false;
        _placesError = false;
      });
    } catch (e, st) {
      debugPrint('MapScreen._loadPlaces error: $e\n$st');
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
          // Una recarga en segundo plano que falla no borra lo que ya se ve.
          _placesError = _places.isEmpty;
        });
      }
    }
  }

  /// TG-145/146/147/155: obtiene el primer fix, centra la cámara ahí
  /// inmediatamente, y luego se suscribe a la posición en tiempo real
  /// para mover solo el marcador del turista (sin volver a mover la
  /// cámara — así no le arrebatamos el mapa si el turista lo está
  /// explorando con el dedo).
  Future<void> _loadLocationAndStartWatching() async {
    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (result.isSuccess) {
      final position = result.position!;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLatLng = latLng;
        _locationFailure = null;
        _isLoadingLocation = false;
      });
      _followUserIfNeeded(latLng); // por si el mapa ya estaba listo.
      _watchPositionUpdates();
    } else {
      setState(() {
        _locationFailure = result.failure;
        _isLoadingLocation = false;
      });
      // Hay permiso pero no llegó posición a tiempo: se sigue escuchando
      // por si llega después, sin dejar el mapa bloqueado mientras tanto.
      if (result.failure == LocationFailureReason.unavailable) {
        _watchPositionUpdates();
      }
    }
  }

  void _watchPositionUpdates() {
    _positionSub?.cancel();
    _positionSub = _locationService.watchPosition().listen(
      (position) {
        if (!mounted) return;
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _userLatLng = latLng;
          // Llegó una posición después de un primer intento fallido.
          if (_locationFailure == LocationFailureReason.unavailable) {
            _locationFailure = null;
          }
        });
        _followUserIfNeeded(latLng);
      },
      // Un error del GPS en vivo no borra la última posición conocida.
      onError: (Object e) => debugPrint('MapScreen.watchPosition error: $e'),
    );
  }

  void _followUserIfNeeded(LatLng latLng) {
    if (!_isFollowingUser || _mapController == null) return;
    _ignoreNextCameraMove = true;
    _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void _resumeFollowingUser() {
    setState(() => _isFollowingUser = true);
    if (_userLatLng != null) _followUserIfNeeded(_userLatLng!);
  }

  /// Ícono propio del turista (TG-145/155): ver [UserLocationIcon].
  Future<void> _buildUserIcon(String label) async {
    final icon = await UserLocationIcon.build(label);
    if (icon == null || !mounted) return;
    setState(() {
      _userIcon = icon.icon;
      _userIconAnchor = icon.anchor;
    });
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
    if (_userLatLng == null) return filtered;
    // "Magia": los más cercanos primero.
    final sorted = [...filtered]
      ..sort((a, b) => _distanceMeters(a).compareTo(_distanceMeters(b)));
    return sorted;
  }

  /// Distancia en línea recta (fórmula de Haversine) del turista a
  /// [place], o `double.infinity` si aún no hay ubicación.
  double _distanceMeters(MapPlace place) {
    if (_userLatLng == null) return double.infinity;
    return Geolocator.distanceBetween(
      _userLatLng!.latitude,
      _userLatLng!.longitude,
      place.latitud,
      place.longitud,
    );
  }

  String _formatDistance(double meters) {
    if (meters.isInfinite) return '';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Set<Marker> get _markers {
    final markers = _filteredPlaces.map((place) {
      final distancia = _formatDistance(_distanceMeters(place));
      return Marker(
        markerId: MarkerId('${place.type.name}_${place.id}'),
        position: LatLng(place.latitud, place.longitud),
        icon: CategoryVisual.forCategory(place.categoria).toMarkerIcon(),
        infoWindow: InfoWindow(
          title: place.nombre,
          snippet: distancia.isEmpty
              ? localizedCategoryLabel(context, place.categoria)
              : '${localizedCategoryLabel(context, place.categoria)} · $distancia',
        ),
        onTap: () => _showPlaceDetails(place),
      );
    }).toSet();

    // Marcador distintivo del turista (TG-145/155): punto ámbar con halo
    // y etiqueta (ver [UserLocationIcon]), no un pin genérico, que
    // se mueve en tiempo real con cada actualización de posición.
    if (_userLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId(_userMarkerId),
          position: _userLatLng!,
          icon: _userIcon ?? UserLocationIcon.fallback,
          anchor: _userIcon == null ? const Offset(0.5, 0.5) : _userIconAnchor,
          zIndexInt: 1,
        ),
      );
    }

    return markers;
  }

  /// Reintenta obtener la ubicación. Para [permissionDenied] esto vuelve
  /// a mostrar el diálogo del sistema; para GPS apagado o permiso
  /// bloqueado para siempre, el sistema no deja re-preguntar, así que
  /// [_handleLocationBannerAction] abre los ajustes en su lugar.
  Future<void> _retryLocation() async {
    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (result.isSuccess) {
      final position = result.position!;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLatLng = latLng;
        _locationFailure = null;
        _isFollowingUser = true;
      });
      _watchPositionUpdates();
      _ignoreNextCameraMove = true;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
    } else {
      setState(() => _locationFailure = result.failure);
      if (!mounted) return;
      _showLocationErrorSnackBar(result.failure!);
    }
  }

  void _showLocationErrorSnackBar(LocationFailureReason reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_locationMessage(reason)),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: _locationActionLabel(reason),
          textColor: Colors.white,
          onPressed: () => _handleLocationBannerAction(reason),
        ),
      ),
    );
  }

  String _locationActionLabel(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return context.l10n.mapScreenActionEnableGps;
      case LocationFailureReason.permissionDenied:
        return context.l10n.mapScreenActionAllow;
      case LocationFailureReason.permissionDeniedForever:
        return context.l10n.mapScreenActionSettings;
      case LocationFailureReason.unavailable:
        return context.l10n.comercioRetry;
    }
  }

  Future<void> _handleLocationBannerAction(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return _locationService.openLocationSettings();
      case LocationFailureReason.permissionDeniedForever:
        return _locationService.openAppSettings();
      case LocationFailureReason.permissionDenied:
      case LocationFailureReason.unavailable:
        return _retryLocation();
    }
  }

  String _locationMessage(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return context.l10n.mapScreenLocationServiceDisabled;
      case LocationFailureReason.permissionDenied:
        return context.l10n.mapScreenLocationPermissionDenied;
      case LocationFailureReason.permissionDeniedForever:
        return context.l10n.mapScreenLocationPermissionDeniedForever;
      case LocationFailureReason.unavailable:
        return context.l10n.mapScreenLocationUnavailable;
    }
  }

  /// TG-152: dispara la vista de detalles del lugar tocado.
  void _showPlaceDetails(MapPlace place) {
    PlaceDetailsSheet.show(
      context,
      place: place,
      repository: _placesRepository,
      distanceLabel: _formatDistance(_distanceMeters(place)),
    );
  }

  Future<void> _showComuna(ComunaGeo comuna) async {
    final security = context.read<SecurityMapProvider>();
    final indice = security.indiceDe(comuna.codigo);
    final metadatos = security.metadatos;
    if (indice == null || metadatos == null) return;
    setState(() => _comunaSeleccionada = comuna.codigo);
    await ComunaIncidenciaSheet.show(
      context,
      indice: indice,
      metadatos: metadatos,
      repository: security.repository,
    );
    if (mounted) setState(() => _comunaSeleccionada = null);
  }

  final _polygonsCache = ComunaPolygonsCache();

  Set<Polygon> _polygons(SecurityMapProvider security) => _polygonsCache.get(
        security,
        onTap: _showComuna,
        seleccionada: _comunaSeleccionada,
      );

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        context.go('/');
        break;
      case AppSection.comercios:
        context.go('/comercios');
        break;
      case AppSection.mapa:
        break; // ya estamos aquí.
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

  Future<void> _createTrip() async {
    await showCreateTripDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return _buildMobile(context);
        }
        return AppShell(
          section: AppSection.mapa,
          onNavigate: _handleSideNav,
          onCreateTrip: _createTrip,
          child: _buildDesktopContent(context),
        );
      },
    );
  }

  // ─── Escritorio / tablet ───

  // Solo el mapa — sin encabezado ni chips de categoría duplicando lo
  // que ya está en Comercios; la altura crece con la ventana (más alto
  // que antes) porque acá el mapa es todo el contenido de la pantalla.
  Widget _buildDesktopContent(BuildContext context) {
    final mapHeight = (MediaQuery.sizeOf(context).height - 190).clamp(560.0, 920.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_locationFailure != null) ...[
          _buildDesktopLocationBanner(),
          const SizedBox(height: 16),
        ],
        _buildMapCard(mapHeight),
      ],
    );
  }

  Widget _buildDesktopLocationBanner() {
    final reason = _locationFailure!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_locationMessage(reason), style: AppText.ui(13, color: AppColors.ink)),
          ),
          const SizedBox(width: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _handleLocationBannerAction(reason),
              child: Text(
                _locationActionLabel(reason).toUpperCase(),
                style: AppText.label(
                  11,
                  weight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(double height) {
    final security = context.watch<SecurityMapProvider>();
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: AppShadow.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLatLng ?? _fallbackCenter,
                zoom: 14,
              ),
              style: mapInkStyle,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_userLatLng != null) _followUserIfNeeded(_userLatLng!);
              },
              onCameraMoveStarted: () {
                if (_ignoreNextCameraMove) {
                  _ignoreNextCameraMove = false;
                } else if (_isFollowingUser) {
                  setState(() => _isFollowingUser = false);
                }
              },
              markers: _markers,
              polygons: _polygons(security),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            if (_isLoading)
              Container(
                color: AppColors.ink.withValues(alpha: 0.15),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.mint),
                ),
              ),
            if (_placesError)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: LoadErrorBox(
                  message: context.l10n.valLoadMapError,
                  onRetry: _retryPlaces,
                ),
              ),
            const Positioned(
              left: 18,
              bottom: 18,
              child: SecurityLayerControls(),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: _RecenterButton(
                following: _isFollowingUser,
                onTap: _userLatLng == null
                    ? () => _handleLocationBannerAction(
                          _locationFailure ?? LocationFailureReason.permissionDenied,
                        )
                    : _resumeFollowingUser,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Móvil ───
  // Mapa a pantalla completa con el estilo petróleo de escritorio y un
  // panel de papel arriba (atrás, contador mono, título display y chips),
  // con una sola esquina grande como las cabeceras del handoff.

  Widget _buildMobile(BuildContext context) {
    final security = context.watch<SecurityMapProvider>();
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLatLng ?? _fallbackCenter,
                zoom: 14,
              ),
              style: mapInkStyle,
              onMapCreated: (controller) {
                _mapController = controller;
                // El mapa se creó después de tener ya la primera
                // posición: hay que centrar ahora (initialCameraPosition
                // solo aplica en la creación misma del widget).
                if (_userLatLng != null) _followUserIfNeeded(_userLatLng!);
              },
              onCameraMoveStarted: () {
                if (_ignoreNextCameraMove) {
                  _ignoreNextCameraMove = false;
                } else if (_isFollowingUser) {
                  setState(() => _isFollowingUser = false);
                }
              },
              markers: _markers,
              polygons: _polygons(security),
              // El indicador nativo de "mi ubicación" queda apagado a
              // propósito: usamos nuestro propio marcador y un botón de
              // "seguir" con la lógica de pausa/reanudar.
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          // TG-156: spinner SUPERPUESTO sobre el mapa, no en vez de él.
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: AppColors.ink.withValues(alpha: 0.15),
                child: const Center(child: CircularProgressIndicator(color: AppColors.mint)),
              ),
            ),
          Positioned(top: 0, left: 0, right: 0, child: _buildMobileTopPanel()),
          const Positioned(
            left: 18,
            bottom: 18,
            child: SafeArea(top: false, child: SecurityLayerControls()),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: _RecenterButton(
                following: _isFollowingUser,
                onTap: _userLatLng == null
                    ? () => _handleLocationBannerAction(
                          _locationFailure ?? LocationFailureReason.permissionDenied,
                        )
                    : _resumeFollowingUser,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: AppRadius.headerDetail,
        boxShadow: AppShadow.raised,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PaperBackButton(onTap: () => context.go('/')),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_isLoadingPlaces
                                  ? context.l10n.mapScreenSearchingNearbyPlaces
                                  : context.l10n.mapScreenPlacesFoundCount(_filteredPlaces.length))
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label(10, color: AppColors.inkSoft),
                        ),
                        const SizedBox(height: 2),
                        Text(context.l10n.mapScreenTitle, style: AppText.display(28)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilterChipsRow(
                items: [for (final c in _categories) localizedCategoryOrAll(context, c)],
                selected: _categories.indexOf(_selectedCategory).clamp(0, _categories.length - 1),
                onSelect: (i) => setState(() => _selectedCategory = _categories[i]),
                forceScrollable: true,
              ),
              if (_locationFailure != null) ...[
                const SizedBox(height: 14),
                _buildDesktopLocationBanner(),
              ],
              if (_placesError) ...[
                const SizedBox(height: 14),
                LoadErrorBox(message: context.l10n.valLoadMapError, onRetry: _retryPlaces),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón "seguir mi ubicación" restilado con los tokens de la app —
/// mismo criterio de estados que antes (blanco = siguiendo, ink =
/// pausado, toca para reanudar), solo que ahora combina con el resto
/// de botones circulares de la app (p.ej. el de tema del `TopBar`).
class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.following, required this.onTap});

  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: following ? AppColors.surface : AppColors.ink,
            border: following ? Border.all(color: AppColors.line) : null,
            boxShadow: AppShadow.raised,
          ),
          child: Icon(
            Icons.my_location,
            color: following ? AppColors.ink : AppColors.mint,
            size: 20,
          ),
        ),
      ),
    );
  }
}
