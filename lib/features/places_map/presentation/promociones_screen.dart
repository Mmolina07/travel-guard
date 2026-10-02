import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../subscriptions/presentation/widgets/premium_gate.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../../trips/presentation/pages/create_trip_screen.dart';
import '../data/models/actividad_model.dart';
import '../data/places_map_repository.dart';

/// `/promociones` — HU-24. La vista entera pasa por [PremiumGate]
/// (TG-298): un turista sin suscripción vigente ve la invitación a
/// suscribirse en vez del listado. El listado es la base sobre la que
/// TG-297 arma el catálogo gráfico.
class PromocionesScreen extends StatefulWidget {
  const PromocionesScreen({super.key});

  @override
  State<PromocionesScreen> createState() => _PromocionesScreenState();
}

class _PromocionesScreenState extends State<PromocionesScreen> {
  final PlacesMapRepository _repository = PlacesMapRepository();
  Future<List<Promocion>>? _future;

  /// Solo se consultan las promociones si es Premium — no tiene sentido
  /// traerlas para esconderlas detrás de la invitación.
  void _loadIfPremium() {
    if (_future == null && context.read<SubscriptionProvider>().isPremium) {
      _future = _repository.fetchPromociones();
    }
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
      case AppSection.promociones:
        break; // ya estamos aquí.
      case AppSection.suscripciones:
        context.go('/suscripciones');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    context.watch<SubscriptionProvider>();
    _loadIfPremium();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            appBar: AppBar(
              title: Text(context.l10n.promosTitle),
              backgroundColor: AppColors.paper,
              foregroundColor: AppColors.ink,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
            ),
            body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildContent()),
          );
        }
        return AppShell(
          section: AppSection.promociones,
          onNavigate: _handleSideNav,
          onCreateTrip: () => showCreateTripDialog(context),
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.promosEyebrow, style: AppText.label(11, color: AppColors.inkSoft)),
        const SizedBox(height: 8),
        Text(l10n.promosTitle, style: AppText.display(40)),
        const SizedBox(height: 8),
        Text(l10n.promosSubtitle, style: AppText.ui(14, color: AppColors.textMuted)),
        const SizedBox(height: 28),
        PremiumGate(
          icon: Icons.local_offer_outlined,
          title: l10n.promosLockedTitle,
          description: l10n.promosLockedDescription,
          child: FutureBuilder<List<Promocion>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
                );
              }
              if (snapshot.hasError) {
                debugPrint('PromocionesScreen error: ${snapshot.error}');
                return _buildMessage(Icons.cloud_off_outlined, l10n.promosLoadError);
              }
              final promos = snapshot.data ?? const [];
              if (promos.isEmpty) return _buildMessage(Icons.local_offer_outlined, l10n.promosEmpty);
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [for (final p in promos) _PromoCard(promo: p)],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.textLabel),
            const SizedBox(height: 10),
            Text(text, style: AppText.ui(14, color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});

  final Promocion promo;

  @override
  Widget build(BuildContext context) {
    final a = promo.actividad;
    final fin = a.fechaFin;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  (promo.comercioNombre ?? '').toUpperCase(),
                  style: AppText.label(10, color: AppColors.inkSoft),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(a.nombre, style: AppText.display(22)),
          if (a.descripcion != null && a.descripcion!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(a.descripcion!, style: AppText.ui(13, color: AppColors.textMuted), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (a.precio != null)
                Text(context.formatMoney(a.precio!), style: AppText.ui(15, weight: FontWeight.w700)),
              const Spacer(),
              if (fin != null)
                Text(
                  context.l10n.promosValidUntil(
                    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(fin),
                  ),
                  style: AppText.label(10),
                ),
            ],
          ),
          if (promo.comercioDireccion != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: AppColors.textLabel),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    promo.comercioDireccion!,
                    style: AppText.ui(12, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
