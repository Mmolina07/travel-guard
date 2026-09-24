import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/app_theme.dart';
import '../features/places_map/data/models/map_place.dart';
import 'map_style.dart';

/// Panel de mapa restilado en tono ink — el panel sticky de Comercios
/// en `WEB_LAYOUT.md`. Es un `GoogleMap` **real**, no decorativo:
/// conserva los marcadores/datos reales de HU-07, solo con una piel
/// oscura (`_darkStyle`) para que combine con la paleta en vez de un
/// mapa de Google Maps genérico.
class MapPanel extends StatefulWidget {
  const MapPanel({
    super.key,
    required this.places,
    this.center,
    this.selected,
    this.onSelectPlace,
    this.height = 520,
    this.title = 'MAPA · MEDELLÍN',
  });

  final List<MapPlace> places;
  final LatLng? center;
  final MapPlace? selected;
  final ValueChanged<MapPlace>? onSelectPlace;
  final double height;
  final String title;

  static const LatLng fallbackCenter = LatLng(6.2442, -75.5812); // Medellín

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  GoogleMapController? _controller;
  MapType _mapType = MapType.normal;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.center ?? MapPanel.fallbackCenter,
                zoom: 14,
              ),
              mapType: _mapType,
              style: mapInkStyle,
              onMapCreated: (controller) => _controller = controller,
              markers: {
                for (final place in widget.places)
                  Marker(
                    markerId: MarkerId('${place.type}-${place.id}'),
                    position: LatLng(place.latitud, place.longitud),
                    infoWindow: InfoWindow(title: place.nombre),
                    onTap: () => widget.onSelectPlace?.call(place),
                  ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.ink.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: AppText.label(11, color: AppColors.mint),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _mapType = _mapType == MapType.normal
                              ? MapType.satellite
                              : MapType.normal;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _mapType == MapType.normal ? 'Satélite' : 'Mapa',
                            style: AppText.ui(
                              12,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.selected != null)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: _SelectedPlaceCard(place: widget.selected!),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({required this.place});

  final MapPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadow.raised,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(14, weight: FontWeight.w600),
                ),
                Text(place.categoria, style: AppText.label(10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

