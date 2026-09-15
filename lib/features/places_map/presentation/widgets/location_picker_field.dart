import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/location_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Mapa interactivo para elegir la ubicación de un comercio al
/// registrarse (HU-02 + HU-07): sin esto, el comercio no tiene
/// lat/lng y nunca aparece en el mapa de "Comercios cercanos".
///
/// Se centra automáticamente en la ubicación actual del dispositivo si
/// está disponible; el usuario puede tocar el mapa para ajustar el
/// punto exacto de su negocio.
class LocationPickerField extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const LocationPickerField({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  static const Color _primary = Color(0xFF1A5F7A);
  static const LatLng _fallbackCenter = LatLng(6.2442, -75.5812); // Medellín

  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  LatLng? _selected;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    if (_selected != null) {
      _isLocating = false;
    } else {
      _useCurrentLocation(animate: false);
    }
  }

  /// Reacciona cuando el formulario que contiene este picker encuentra
  /// una ubicación nueva desde afuera (p.ej. al geocodificar el texto
  /// de "Dirección") y anima el mapa hasta ahí — sin esto, el mapa se
  /// quedaría quieto aunque el comercio ya haya escrito su dirección.
  @override
  void didUpdateWidget(covariant LocationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialLocation;
    if (next != null &&
        next != oldWidget.initialLocation &&
        next != _selected) {
      setState(() => _selected = next);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(next, 17));
    }
  }

  Future<void> _useCurrentLocation({bool animate = true}) async {
    setState(() => _isLocating = true);
    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    setState(() => _isLocating = false);

    if (!result.isSuccess) {
      if (_selected == null) {
        setState(() => _selected = _fallbackCenter);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo obtener tu ubicación. Toca el mapa para ubicar tu negocio manualmente.',
          ),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final latLng = LatLng(result.position!.latitude, result.position!.longitude);
    setState(() => _selected = latLng);
    widget.onLocationSelected(latLng);
    if (animate) {
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  void _onTapMap(LatLng position) {
    setState(() => _selected = position);
    widget.onLocationSelected(position);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selected ?? _fallbackCenter,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onTapMap,
                  markers: _selected == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('ubicacion_comercio'),
                            position: _selected!,
                            draggable: true,
                            onDragEnd: _onTapMap,
                          ),
                        },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                if (_isLocating)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'usar_ubicacion_actual',
                    backgroundColor: Colors.white,
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    child: const Icon(Icons.my_location, color: _primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _selected == null
              ? 'Toca el mapa o usa el botón para ubicar tu negocio.'
              : 'Ubicación seleccionada: '
                  '${_selected!.latitude.toStringAsFixed(5)}, '
                  '${_selected!.longitude.toStringAsFixed(5)} '
                  '(puedes arrastrar el marcador para ajustar)',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
