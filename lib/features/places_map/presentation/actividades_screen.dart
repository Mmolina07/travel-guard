import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/hover_card.dart';
import '../../../widgets/load_error_box.dart';
import '../../../widgets/stagger_in.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../trips/presentation/pages/create_trip_screen.dart';
import '../data/models/actividad_model.dart';
import '../data/places_map_repository.dart';
import 'widgets/comercio_ui.dart';
import 'widgets/place_details_sheet.dart';
import '../../../widgets/paper_top_bar.dart';

/// `/actividades` — lo que publican los comercios (eventos, tours,
/// clases...), visible para todos los turistas. Las promociones son
/// aparte y exclusivas de Premium (`/promociones`). Tocar una actividad
/// abre la ficha del comercio que la ofrece.
class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({super.key});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  final PlacesMapRepository _repository = PlacesMapRepository();
  late Future<List<ActividadConComercio>> _future = _repository.fetchActividadesPublicadas();
  int _categoryIndex = 0;

  void _reload() {
    setState(() => _future = _repository.fetchActividadesPublicadas());
  }

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
        context.go('/mapa');
        break;
      case AppSection.actividades:
        break; // ya estamos aquí.
      case AppSection.promociones:
        context.go('/promociones');
        break;
      case AppSection.suscripciones:
        context.go('/suscripciones');
        break;
    }
  }

  Future<void> _openBusiness(Actividad actividad) async {
    final comercioId = actividad.comercioId;
    final messenger = ScaffoldMessenger.of(context);
    final unavailable = context.l10n.activitiesBusinessUnavailable;
    final place = comercioId == null
        ? null
        : await _repository.fetchComercioPlace(comercioId).catchError((Object e) {
            debugPrint('ActividadesScreen._openBusiness error: $e');
            return null;
          });
    if (!mounted) return;
    if (place == null) {
      messenger.showSnackBar(SnackBar(content: Text(unavailable)));
      return;
    }
    await PlaceDetailsSheet.show(context, place: place, repository: _repository);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            appBar: PaperTopBar(onBack: () => context.go('/')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          );
        }
        return AppShell(
          section: AppSection.actividades,
          onNavigate: _handleSideNav,
          onCreateTrip: () => showCreateTripDialog(context),
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    return FutureBuilder<List<ActividadConComercio>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final all = snapshot.data ?? const <ActividadConComercio>[];
        final categories = <String>{
          for (final a in all)
            if ((a.actividad.categoria ?? '').trim().isNotEmpty) a.actividad.categoria!.trim(),
        }.toList()
          ..sort();
        final index = _categoryIndex.clamp(0, categories.length);
        final selected = index == 0 ? null : categories[index - 1];
        final visible = selected == null
            ? all
            : all.where((a) => a.actividad.categoria?.trim() == selected).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(all.length, categories, index),
            const SizedBox(height: 18),
            _PromoBanner(onTap: () => context.go('/promociones')),
            const SizedBox(height: 24),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
              )
            else if (snapshot.hasError)
              LoadErrorBox(message: context.l10n.activitiesLoadError, onRetry: _reload)
            else if (visible.isEmpty)
              DashedBox(
                child: Text(
                  all.isEmpty ? context.l10n.activitiesEmpty : context.l10n.activitiesEmptyFilter,
                  style: AppText.ui(14, color: AppColors.textMuted),
                ),
              )
            else
              _buildGrid(visible),
          ],
        );
      },
    );
  }

  Widget _buildHeader(int count, List<String> categories, int selectedIndex) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.032).clamp(32.0, 44.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.activitiesEyebrow(count), style: AppText.label(11, color: AppColors.inkSoft)),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l10n.activitiesTitle1),
              TextSpan(text: l10n.activitiesTitle2, style: AppText.displayItalic(titleSize)),
            ],
          ),
          style: AppText.display(titleSize).copyWith(height: 1.04),
        ),
        const SizedBox(height: 8),
        Text(l10n.activitiesSubtitle, style: AppText.ui(14, color: AppColors.textMuted)),
        if (categories.length > 1) ...[
          const SizedBox(height: 20),
          FilterChipsRow(
            items: [l10n.activitiesAllFilter, ...categories],
            selected: selectedIndex,
            onSelect: (i) => setState(() => _categoryIndex = i),
          ),
        ],
      ],
    );
  }

  /// Retícula `auto-fill minmax(280, 1fr)`.
  Widget _buildGrid(List<ActividadConComercio> items) {
    final isPremium = context.watch<SubscriptionProvider>().isPremium;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final columns = ((constraints.maxWidth + gap) / (280 + gap)).floor().clamp(1, 99);
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: itemWidth,
                child: StaggerIn(
                  index: i,
                  child: _ActivityCard(
                    item: items[i],
                    // Exclusiva Premium y el turista no lo es: se ve con
                    // candado y lleva a los planes.
                    locked: items[i].actividad.soloPremium && !isPremium,
                    onTap: items[i].actividad.soloPremium && !isPremium
                        ? () => context.go('/suscripciones')
                        : () => _openBusiness(items[i].actividad),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.inkSoft),
          Text(context.l10n.activitiesPromoBanner, style: AppText.ui(13, color: AppColors.textMuted)),
          TextLink(label: context.l10n.activitiesPromoLink, onTap: onTap),
        ],
      ),
    );
  }
}

/// Tarjeta de actividad: categoría y precio, nombre, descripción,
/// fechas y el comercio que la ofrece. Toda la tarjeta abre la ficha
/// del comercio.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onTap, this.locked = false});

  final ActividadConComercio item;
  final VoidCallback onTap;

  /// Exclusiva Premium vista por un turista sin suscripción: se oculta
  /// el detalle (precio, descripción, comercio) y se invita a suscribirse.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final a = item.actividad;
    final desc = (a.descripcion ?? '').trim();
    final category = (a.categoria ?? '').trim();
    return HoverCard(
      onTap: onTap,
      radius: AppRadius.card,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.wash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(activityCategoryIcon(a.categoria), size: 18, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label(10, color: AppColors.inkSoft),
                ),
              ),
              if (a.soloPremium) ...[
                const PremiumTag(),
                const SizedBox(width: 6),
              ],
              if (!locked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    formatActividadPrecio(context, a),
                    style: AppText.ui(12, weight: FontWeight.w700, color: AppColors.mint),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(a.nombre, style: AppText.display(22).copyWith(height: 1.12)),
          if (locked) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16, color: AppColors.inkSoft),
                const SizedBox(width: 6),
                Text(
                  context.l10n.activitiesPremiumLocked,
                  style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.inkSoft),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.activitiesPremiumLockedHint,
              style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.inkSoft),
            ),
          ] else ...[
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.ui(13, color: AppColors.textMuted, height: 1.45),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: AppColors.textLabel),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatActividadFechas(context, inicio: a.fechaInicio, fin: a.fechaFin).toUpperCase(),
                  style: AppText.label(11, color: AppColors.textMuted).copyWith(letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          Text(
            item.comercioNombre ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.ui(14, weight: FontWeight.w600),
          ),
          if ((item.comercioDireccion ?? '').isNotEmpty)
            Text(
              item.comercioDireccion!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.ui(12, color: AppColors.textMuted),
            ),
          const SizedBox(height: 8),
          Text(
            context.l10n.activitiesViewBusiness,
            style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.inkSoft),
          ),
          ],
        ],
      ),
    );
  }
}
