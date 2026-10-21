import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../data/models/actividad_model.dart';
import '../../data/models/category_visuals.dart';
import '../../data/models/map_place.dart';
import '../../data/menus_repository.dart';
import '../../data/places_map_repository.dart';
import '../../data/places_realtime.dart';
import '../menu_model.dart';
import 'product_form_dialog.dart' show productCategoryIcon, productCategoryLabel;
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../subscriptions/presentation/widgets/premium_gate.dart';
import '../../../../widgets/ink_button.dart';
import 'category_label.dart';

/// Vista de detalles de un comercio/lugar de interés (TG-152), usada
/// tanto desde el mapa como desde "Comercios cercanos": nombre,
/// categoría, distancia, contacto, actividades asociadas y menú del
/// comercio (cargados a demanda — HU-20 CA11: el turista ve siempre lo
/// último que el comercio guardó) y un botón "Cómo llegar".
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
  static const bool _directionsEnabled = true;

  late MapPlace _place = widget.place;
  late Future<List<Actividad>> _actividadesFuture;

  /// Solo los comercios tienen menú; `null` para lugares de interés.
  Future<List<Menu>>? _menusFuture;

  // TG-289: si el comercio cambia algo mientras la ficha está abierta,
  // se actualiza sola.
  StreamSubscription<PlacesChange>? _realtimeSub;
  final _realtimeDebouncer = Debouncer();

  bool get _isComercio => widget.place.type == MapPlaceType.comercio;

  @override
  void initState() {
    super.initState();
    _loadActividades();
    _loadMenus();
    _realtimeSub = PlacesRealtime.instance.changes.listen((change) {
      if (_isComercio && !change.affects(widget.place.id)) return;
      if (!_isComercio && change.table != 'actividades') return;
      _realtimeDebouncer(() => _onChange(change));
    });
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _realtimeDebouncer.dispose();
    super.dispose();
  }

  void _loadActividades() {
    _actividadesFuture = widget.repository.fetchActividadesDelLugar(widget.place);
  }

  void _loadMenus() {
    if (!_isComercio) return;
    _menusFuture = MenusRepository()
        .fetchMenus(widget.place.id, onlyAvailable: true)
        .then((menus) => menus.where((m) => m.products.isNotEmpty).toList());
  }

  Future<void> _onChange(PlacesChange change) async {
    if (!mounted) return;
    setState(() {
      if (change.table == 'actividades') _loadActividades();
      if (change.table == 'menus' || change.table == 'menu_productos') _loadMenus();
    });
    if (change.table != 'comercios') return;
    try {
      final updated = await widget.repository.fetchComercioPlace(widget.place.id);
      if (mounted && updated != null) setState(() => _place = updated);
    } catch (e, st) {
      debugPrint('PlaceDetailsSheet._onChange error: $e\n$st');
    }
  }

  Future<void> _openDirections() async {
    final place = _place;
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
    final place = _place;
    final visual = CategoryVisual.forCategory(place.categoria);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
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
                  color: AppColors.hair,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
              ),
            ),
            if (place.fotoUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
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
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    color: AppColors.ink,
                  ),
                  child: Icon(visual.icon, color: AppColors.mint, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(place.nombre, style: AppText.display(26)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              (widget.distanceLabel.isEmpty
                      ? localizedCategoryLabel(context, place.categoria)
                      : context.l10n.placeDetailsCategoryDistance(
                          localizedCategoryLabel(context, place.categoria), widget.distanceLabel))
                  .toUpperCase(),
              style: AppText.label(10, color: AppColors.inkSoft),
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
                style: AppText.ui(13, color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 16),
            // "Cómo llegar": abre Google Maps con la ruta al lugar (app en
            // el celular, pestaña nueva en web). Para apagarlo de nuevo,
            // `_directionsEnabled = false`.
            Tooltip(
              message: _directionsEnabled ? '' : context.l10n.placeDetailsDirectionsSoon,
              child: InkButton(
                label: context.l10n.placeDetailsDirectionsButton,
                icon: Icons.directions,
                trailingArrow: true,
                expand: true,
                onPressed: _directionsEnabled ? _openDirections : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.placeDetailsActivitiesTitle, style: AppText.display(22)),
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
                    style: AppText.ui(13, color: AppColors.textMuted),
                  );
                }
                // HU-24: las promociones de este comercio solo las ven
                // los Premium (TG-298); al resto se les invita a
                // suscribirse en su lugar.
                // Igual para las actividades marcadas "Solo Premium".
                final promos = actividades.where((a) => a.soloPremium).toList();
                final regulares = actividades.where((a) => !a.soloPremium).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...regulares.map(_buildActividadRow),
                    if (promos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      PremiumGate(
                        compact: true,
                        icon: Icons.local_offer_outlined,
                        title: context.l10n.placeDetailsPromosLockedTitle(promos.length),
                        description: context.l10n.placeDetailsPromosLockedDescription,
                        child: Column(
                          children: promos.map(_buildActividadRow).toList(),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            if (_menusFuture != null) _buildMenusSection(),
          ],
        ),
        ),
      ),
    );
  }

  /// HU-20 CA11: menú del comercio, organizado por tipo de producto.
  Widget _buildMenusSection() {
    return FutureBuilder<List<Menu>>(
      future: _menusFuture,
      builder: (context, snapshot) {
        final menus = snapshot.data ?? const <Menu>[];
        if (snapshot.connectionState == ConnectionState.waiting ||
            menus.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(context.l10n.placeDetailsMenuTitle, style: AppText.display(22)),
            for (final menu in menus) ...[
              const SizedBox(height: 10),
              Text(menu.name, style: AppText.ui(15, weight: FontWeight.w700)),
              for (final entry in menu.productsByCategory.entries) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(productCategoryIcon(entry.key),
                        size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 6),
                    Text(
                      productCategoryLabel(context, entry.key, plural: true).toUpperCase(),
                      style: AppText.label(10, color: AppColors.inkSoft, weight: FontWeight.w700),
                    ),
                  ],
                ),
                for (final product in entry.value) _buildProductRow(product),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildProductRow(MenuItem product) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppText.ui(14)),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.formatMoney(product.price),
            style: AppText.label(12, color: AppColors.inkSoft, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadRow(Actividad a) {
    final esPromo = a.categoria == Actividad.categoriaPromocion;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            esPromo ? Icons.local_offer_outlined : Icons.check_circle_outline,
            size: 16,
            color: esPromo ? AppColors.inkSoft : AppColors.ink,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(a.nombre, style: AppText.ui(14))),
          if (a.precio != null)
            Text(
              context.formatMoney(a.precio!),
              style: AppText.label(12, color: AppColors.inkSoft, weight: FontWeight.w700),
            ),
        ],
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
            style: AppText.ui(13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
