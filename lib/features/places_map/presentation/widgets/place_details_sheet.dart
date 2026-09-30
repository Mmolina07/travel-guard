import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../data/models/actividad_model.dart';
import '../../data/models/category_visuals.dart';
import '../../data/models/map_place.dart';
import '../../data/places_map_repository.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'category_label.dart';

/// Vista de detalles de un comercio/lugar de interés (TG-152), usada
/// tanto desde el mapa como desde "Comercios cercanos": nombre,
/// categoría, distancia, contacto, actividades asociadas (cargadas a
/// demanda) y un botón "Cómo llegar" con direcciones reales.
class PlaceDetailsSheet extends StatefulWidget {
  final MapPlace place;
  final PlacesMapRepository repository;
  final String distanceLabel;

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    required this.repository,
    required this.distanceLabel,
  });

  /// Abre esta vista como un bottom sheet modal.
  static Future<void> show(
    BuildContext context, {
    required MapPlace place,
    required PlacesMapRepository repository,
    String distanceLabel = '',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PlaceDetailsSheet(
        place: place,
        repository: repository,
        distanceLabel: distanceLabel,
      ),
    );
  }

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  late Future<List<Actividad>> _actividadesFuture;

  @override
  void initState() {
    super.initState();
    _actividadesFuture =
        widget.repository.fetchActividadesDelLugar(widget.place);
  }

  Future<void> _openDirections() async {
    final place = widget.place;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${place.latitud},${place.longitud}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.placeDetailsErrorOpenMap)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final place = widget.place;
    final visual = CategoryVisual.forCategory(place.categoria);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (place.fotoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  place.fotoUrl!,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 140,
                      child: Center(
                        child: CircularProgressIndicator(color: visual.color),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [visual.color, visual.color.withOpacity(0.7)],
                    ),
                  ),
                  child: Icon(visual.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.distanceLabel.isEmpty
                  ? localizedCategoryLabel(context, place.categoria)
                  : context.l10n.placeDetailsCategoryDistance(
                      localizedCategoryLabel(context, place.categoria), widget.distanceLabel),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            if (place.direccion != null) ...[
              _buildInfoRow(Icons.location_on_outlined, place.direccion!),
              const SizedBox(height: 6),
            ],
            if (place.telefono != null) ...[
              _buildInfoRow(Icons.phone_outlined, place.telefono!),
              const SizedBox(height: 6),
            ],
            if (place.horarioApertura != null && place.horarioCierre != null)
              _buildInfoRow(
                Icons.access_time,
                '${place.horarioApertura} - ${place.horarioCierre}',
              ),
            if (place.descripcion != null &&
                place.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                place.descripcion!,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions),
                label: Text(context.l10n.placeDetailsDirectionsButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.placeDetailsActivitiesTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Actividad>>(
              future: _actividadesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.ink,
                      ),
                    ),
                  );
                }
                final actividades = snapshot.data ?? [];
                if (actividades.isEmpty) {
                  return Text(
                    context.l10n.placeDetailsNoActivities,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  );
                }
                return Column(
                  children: actividades
                      .map((a) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 16, color: AppColors.ink),
                                const SizedBox(width: 8),
                                Expanded(child: Text(a.nombre)),
                                if (a.precio != null)
                                  Text(
                                    context.formatMoney(a.precio!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
