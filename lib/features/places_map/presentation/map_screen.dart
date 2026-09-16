import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/location_service.dart';
import '../data/models/category_visuals.dart';
import '../data/models/map_place.dart';
import '../data/places_map_repository.dart';
import 'widgets/place_details_sheet.dart';
import '../../../core/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color _primary = AppColors.ink;
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

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _loadLocationAndStartWatching();
    _buildUserIcon();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    final places = await _placesRepository.fetchNearbyPlaces();
    if (!mounted) return;
    setState(() {
      _places = places;
      _isLoadingPlaces = false;
    });
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
    }
  }

  void _watchPositionUpdates() {
    _positionSub?.cancel();
    _positionSub = _locationService.watchPosition().listen((position) {
      if (!mounted) return;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _userLatLng = latLng);
      _followUserIfNeeded(latLng);
    });
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

  /// Ícono propio para el turista (TG-145/155: "indicador distinto"):
  /// un círculo pequeño del color de la marca con halo blanco, y debajo
  /// una etiqueta fija "Tú estás aquí" (no hace falta tocar el marcador
  /// para saber cuál es el turista).
  Future<void> _buildUserIcon() async {
    const double dpr = 2.5; // nitidez en pantallas de alta densidad.
    const double circleDiameter = 26 * dpr;
    const double margin = 6 * dpr;
    const double gap = 4 * dpr;
    const label = 'Tú estás aquí';

    final textPainter = TextPainter(
      text: const TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10 * dpr,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const pillPaddingH = 9.0 * dpr;
    const pillPaddingV = 4.0 * dpr;
    final pillWidth = textPainter.width + pillPaddingH * 2;
    final pillHeight = textPainter.height + pillPaddingV * 2;

    final totalWidth = (circleDiameter > pillWidth ? circleDiameter : pillWidth) +
        margin * 2;
    final totalHeight = circleDiameter + gap + pillHeight + margin * 2;
    final circleCenter = Offset(totalWidth / 2, margin + circleDiameter / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, totalWidth, totalHeight),
    );

    // Halo + círculo del turista.
    canvas.drawCircle(
      circleCenter,
      circleDiameter / 2,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      circleCenter,
      circleDiameter / 2 - 3 * dpr,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      circleCenter,
      circleDiameter / 2 - 7 * dpr,
      Paint()..color = _primary,
    );

    // Etiqueta "Tú estás aquí" debajo del círculo.
    final pillRect = Rect.fromCenter(
      center: Offset(
        totalWidth / 2,
        margin + circleDiameter + gap + pillHeight / 2,
      ),
      width: pillWidth,
      height: pillHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(pillHeight / 2)),
      Paint()..color = _primary,
    );
    textPainter.paint(
      canvas,
      Offset(pillRect.left + pillPaddingH, pillRect.top + pillPaddingV),
    );

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null || !mounted) return;
    setState(() {
      _userIcon = BitmapDescriptor.bytes(bytes.buffer.asUint8List());
      // El ancla apunta al centro del círculo (la coordenada GPS real),
      // no al centro de todo el ícono (que incluye la etiqueta debajo).
      _userIconAnchor = Offset(0.5, circleCenter.dy / totalHeight);
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
              ? place.categoria
              : '${place.categoria} · $distancia',
        ),
        onTap: () => _showPlaceDetails(place),
      );
    }).toSet();

    // Marcador distintivo del turista (TG-145/155): ícono propio
    // dibujado a mano (círculo de marca + halo), no un pin genérico, que
    // se mueve en tiempo real con cada actualización de posición.
    if (_userLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId(_userMarkerId),
          position: _userLatLng!,
          icon: _userIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
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
        return 'Activar GPS';
      case LocationFailureReason.permissionDenied:
        return 'Permitir';
      case LocationFailureReason.permissionDeniedForever:
        return 'Ajustes';
    }
  }

  Future<void> _handleLocationBannerAction(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return _locationService.openLocationSettings();
      case LocationFailureReason.permissionDeniedForever:
        return _locationService.openAppSettings();
      case LocationFailureReason.permissionDenied:
        return _retryLocation();
    }
  }

  String _locationMessage(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return 'El GPS está desactivado. Actívalo para ver tu ubicación.';
      case LocationFailureReason.permissionDenied:
        return 'Necesitamos permiso de ubicación para centrar el mapa en ti.';
      case LocationFailureReason.permissionDeniedForever:
        return 'El permiso de ubicación está bloqueado. Actívalo desde '
            'los ajustes de la app.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        flexibleSpace: const DecoratedBox(decoration: BoxDecoration(color: AppColors.ink)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Mapa',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildCategoryFilters(),
          if (_locationFailure != null) _buildLocationBanner(),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLatLng ?? _fallbackCenter,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // El mapa se creó después de tener ya la primera
                    // posición: hay que centrar ahora (initialCameraPosition
                    // solo aplica en la creación misma del widget).
                    if (_userLatLng != null) {
                      _followUserIfNeeded(_userLatLng!);
                    }
                  },
                  onCameraMoveStarted: () {
                    if (_ignoreNextCameraMove) {
                      _ignoreNextCameraMove = false;
                    } else if (_isFollowingUser) {
                      setState(() => _isFollowingUser = false);
                    }
                  },
                  markers: _markers,
                  // El indicador nativo de "mi ubicación" queda apagado
                  // a propósito: usamos nuestro propio marcador (más
                  // arriba) para tener un ícono distinto y un botón de
                  // "seguir" con la lógica de pausa/reanudar.
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // TG-156: spinner SUPERPUESTO sobre el mapa, no en vez
                // de él — el mapa se ve de inmediato con el centro de
                // respaldo mientras se resuelven ubicación + lugares.
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'seguir_ubicacion',
                    backgroundColor:
                        _isFollowingUser ? Colors.white : _primary,
                    onPressed: _userLatLng == null
                        ? () => _handleLocationBannerAction(
                              _locationFailure ??
                                  LocationFailureReason.permissionDenied,
                            )
                        : _resumeFollowingUser,
                    child: Icon(
                      Icons.my_location,
                      color: _isFollowingUser ? _primary : Colors.white,
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

  Widget _buildCategoryFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isLoadingPlaces
                  ? 'Buscando lugares cercanos...'
                  : '${_filteredPlaces.length} lugar(es) encontrados',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = _categories[index];
                final selected = categoria == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = categoria),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? _primary : AppColors.hair,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      categoria,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : _primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner() {
    final reason = _locationFailure!;
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF9A825), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _locationMessage(reason),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => _handleLocationBannerAction(reason),
            child: Text(_locationActionLabel(reason)),
          ),
        ],
      ),
    );
  }
}

