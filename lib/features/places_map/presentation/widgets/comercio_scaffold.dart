import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../auth/data/comercio_repository.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../data/models/actividad_model.dart';
import '../../data/models/map_place.dart';
import '../../data/places_map_repository.dart';
import '../../providers/comercio_panel_provider.dart';
import '../business_settings_screen.dart';
import 'place_details_sheet.dart';

/// Rutas del panel del comercio.
abstract final class ComercioRoutes {
  static const inicio = '/comercio';
  static const actividades = '/comercio/actividades';
  static const nuevaActividad = '/comercio/actividades/nueva';
  static const promociones = '/comercio/promociones';
  static const nuevaPromocion = '/comercio/promociones/nueva';
  static String editarActividad(int id) => '/comercio/actividades/$id/editar';
  static String editarPromocion(int id) => '/comercio/promociones/$id/editar';
  static const menu = '/comercio/menu';
  static const nuevoMenu = '/comercio/menu/nuevo';

  static String of(ComercioSection section) => switch (section) {
    ComercioSection.inicio => inicio,
    ComercioSection.actividades => actividades,
    ComercioSection.promociones => promociones,
    ComercioSection.menu => menu,
  };
}

/// Abre el modal "Crear actividad" (ruta hija con `pageBuilder` de
/// diálogo). Al guardar, el propio modal navega a Actividades.
void openCreateActivity(BuildContext context) {
  context.push(ComercioRoutes.nuevaActividad);
}

/// Abre el modal "Crear promoción" (misma lógica que "Crear actividad",
/// siempre exclusiva Premium). Al guardar, navega a Promociones.
void openCreatePromotion(BuildContext context) {
  context.push(ComercioRoutes.nuevaPromocion);
}

/// Abre el mismo modal de crear, precargado con [actividad] para
/// editarla (incluido cambiarle el estado, p. ej. borrador → publicada).
void openEditActivity(BuildContext context, Actividad actividad) {
  context.push(
    actividad.esPromocion
        ? ComercioRoutes.editarPromocion(actividad.id)
        : ComercioRoutes.editarActividad(actividad.id),
  );
}

/// Abre el modal "Nuevo menú". Al guardar, navega a Menú.
void openCreateMenu(BuildContext context) {
  context.push(ComercioRoutes.nuevoMenu);
}

/// "Mi negocio": misma lógica que tenía `HomeScreenComercio` (sube la
/// foto primero; si falla no guarda nada; si falla el guardado borra la
/// foto recién subida).
Future<void> openBusinessSettings(BuildContext context) async {
  final panel = context.read<ComercioPanelProvider>();
  final auth = context.read<AppAuthProvider>();
  final usuarioId = auth.usuario?.id;
  if (usuarioId == null) return;
  final repository = ComercioRepository();
  final comercio = panel.comercio;
  final lat = comercio?.latitud;
  final lng = comercio?.longitud;
  final result = await Navigator.push<BusinessSettingsResult>(
    context,
    MaterialPageRoute(
      builder: (context) => BusinessSettingsScreen(
        initialName: comercio?.nombreComercio ?? auth.displayName,
        initialOpenTime: comercio?.horarioApertura,
        initialCloseTime: comercio?.horarioCierre,
        initialContact: comercio?.telefonoContacto ?? '',
        initialDescription: comercio?.descripcion ?? '',
        initialAddress: comercio?.direccion ?? '',
        initialLocation: lat != null && lng != null ? LatLng(lat, lng) : null,
        initialPhotoUrl: comercio?.fotoUrl,
      ),
    ),
  );

  if (result == null || !context.mounted) return;

  // HU-20: la foto de portada se sube primero; si falla, no se guarda
  // nada (para no dejar el perfil a medias).
  final previousPhoto = comercio?.fotoUrl;
  String? newPhotoUrl;
  final photo = result.newPhoto;
  if (photo != null) {
    try {
      newPhotoUrl = await repository.uploadFotoPortada(
        usuarioId: usuarioId,
        bytes: photo,
        contentType: result.newPhotoContentType ?? 'image/jpeg',
      );
    } catch (e, st) {
      debugPrint('openBusinessSettings upload photo error: $e\n$st');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.homeComercioPhotoUploadError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
  }

  try {
    final updated = await repository.update(
      usuarioId: usuarioId,
      fotoUrl: newPhotoUrl,
      quitarFoto: result.removePhoto,
      nombreComercio: result.name,
      telefonoContacto: result.contact,
      descripcion: result.description,
      direccion: result.address,
      latitud: result.location.latitude,
      longitud: result.location.longitude,
      horarioApertura: result.openTime,
      horarioCierre: result.closeTime,
    );
    if (newPhotoUrl != null || result.removePhoto) {
      repository.deleteFoto(previousPhoto);
    }
    panel.setComercio(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.homeComercioBusinessUpdatedSnackbar),
        backgroundColor: AppColors.ink,
      ),
    );
  } catch (_) {
    // La foto nueva ya se subió pero el perfil no se guardó: se borra.
    repository.deleteFoto(newPhotoUrl);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.homeComercioSaveErrorSnackbar),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

/// "Ver como turista →": abre la misma ficha que ve el turista desde el
/// mapa o "Comercios cercanos" (actividades activas, menús disponibles).
Future<void> viewAsTourist(BuildContext context) async {
  final panel = context.read<ComercioPanelProvider>();
  final auth = context.read<AppAuthProvider>();
  final usuarioId = auth.usuario?.id;
  if (usuarioId == null) return;
  final repository = PlacesMapRepository();
  MapPlace? place;
  try {
    place = await repository.fetchComercioPlace(usuarioId);
  } catch (e, st) {
    debugPrint('viewAsTourist fetchComercioPlace error: $e\n$st');
  }
  // Sin ubicación todavía no aparece en el mapa; igual se muestra la
  // ficha con lo que hay en el perfil.
  final comercio = panel.comercio;
  place ??= MapPlace(
    type: MapPlaceType.comercio,
    id: usuarioId,
    nombre: comercio?.nombreComercio ?? auth.displayName,
    categoria: 'Comercio',
    latitud: comercio?.latitud ?? 0,
    longitud: comercio?.longitud ?? 0,
    direccion: comercio?.direccion,
    telefono: comercio?.telefonoContacto,
    descripcion: comercio?.descripcion,
    horarioApertura: comercio?.horarioApertura,
    horarioCierre: comercio?.horarioCierre,
    fotoUrl: comercio?.fotoUrl,
  );
  if (!context.mounted) return;
  await PlaceDetailsSheet.show(context, place: place, repository: repository);
}

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.homeComercioSignOut),
      content: Text(context.l10n.homeComercioSignOutDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.homeComercioCancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.homeComercioSignOut),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<AppAuthProvider>().signOut();
    // El redirect de `AppRouter` ya manda a `/login`; este `go` solo
    // evita el parpadeo de un frame con esta pantalla de fondo.
    if (context.mounted) context.go('/login');
  }
}

/// Esqueleto de las 3 vistas del comercio: `AppShell.comercio` (sidebar
/// 248 / 72 + topbar) desde 720 px; por debajo, columna única con la
/// nav flotante. [child] es solo el contenido de la vista.
class ComercioScaffold extends StatelessWidget {
  const ComercioScaffold({
    super.key,
    required this.section,
    required this.child,
  });

  final ComercioSection section;
  final Widget child;

  void _navigate(BuildContext context, ComercioSection target) {
    if (target == section) return;
    context.go(ComercioRoutes.of(target));
  }

  @override
  Widget build(BuildContext context) {
    final panel = context.watch<ComercioPanelProvider>();
    final auth = context.watch<AppAuthProvider>();
    final comercio = panel.comercio;
    final businessName = comercio?.nombreComercio ?? auth.displayName;
    final sede = comercio?.sede?.trim() ?? '';
    final zone = sede.isNotEmpty ? sede : (comercio?.direccion.trim() ?? '');

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (panel.loadFailed) ...[
          _LoadErrorBanner(onRetry: panel.load),
          const SizedBox(height: 22),
        ],
        child,
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.mobile) {
          return AppShell.comercio(
            comercio: ComercioShellData(
              section: section,
              onNavigate: (s) => _navigate(context, s),
              activityCount: panel.soloActividades.length,
              promoCount: panel.promociones.length,
              productCount: panel.productos.length,
              businessName: businessName,
              zone: zone,
              onViewAsTourist: () => viewAsTourist(context),
              onBusinessSettings: () => openBusinessSettings(context),
              searchQuery: panel.busqueda,
              onSearchChanged: panel.setBusqueda,
            ),
            onCreateActivity: () => openCreateActivity(context),
            child: content,
          );
        }
        return Scaffold(
          backgroundColor: AppColors.paper,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MobileTopRow(
                    businessName: businessName,
                    onViewAsTourist: () => viewAsTourist(context),
                    onBusinessSettings: () => openBusinessSettings(context),
                    onSignOut: () => _confirmSignOut(context),
                  ),
                  const SizedBox(height: 14),
                  _MobileSearchField(
                    initialQuery: panel.busqueda,
                    onChanged: panel.setBusqueda,
                  ),
                  const SizedBox(height: 20),
                  content,
                ],
              ),
            ),
          ),
          bottomNavigationBar: _ComercioBottomNav(
            section: section,
            onSelect: (s) => _navigate(context, s),
          ),
        );
      },
    );
  }
}

class _LoadErrorBanner extends StatelessWidget {
  const _LoadErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.errorWash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.homeComercioLoadErrorSnackbar,
              style: AppText.ui(13, color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.comercioRetry),
          ),
        ],
      ),
    );
  }
}

/// Cabecera mínima en móvil: marca + avatar `ink` con el menú de
/// cuenta ("Ver como turista", ajustes del negocio y "Cerrar sesión";
/// en escritorio viven en el sidebar). Antes eran dos íconos sin texto
/// y un "Salir" suelto, que no se entendían.
class _MobileTopRow extends StatelessWidget {
  const _MobileTopRow({
    required this.businessName,
    required this.onViewAsTourist,
    required this.onBusinessSettings,
    required this.onSignOut,
  });

  final String businessName;
  final VoidCallback onViewAsTourist;
  final VoidCallback onBusinessSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initial = businessName.trim().isEmpty ? '·' : businessName.trim()[0].toUpperCase();
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAVELGUARD',
                style: AppText.label(
                  11,
                  color: AppColors.ink,
                ).copyWith(letterSpacing: 11 * 0.18),
              ),
              Text(
                l10n.appShellRoleCommerce.toUpperCase(),
                style: AppText.label(
                  9,
                  color: AppColors.inkSoft,
                ).copyWith(letterSpacing: 9 * 0.18),
              ),
            ],
          ),
        ),
        PopupMenuButton<VoidCallback>(
          tooltip: l10n.homeComercioBusinessSettingsTooltip,
          position: PopupMenuPosition.under,
          onSelected: (action) => action(),
          itemBuilder: (context) => [
            _menuItem(Icons.visibility_outlined, l10n.comercioViewAsTourist.replaceAll('→', '').trim(), onViewAsTourist),
            _menuItem(Icons.storefront_outlined, l10n.homeComercioBusinessSettingsTooltip, onBusinessSettings),
            _menuItem(Icons.logout, l10n.homeComercioSignOut, onSignOut),
          ],
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initial,
              style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.mint),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<VoidCallback> _menuItem(IconData icon, String label, VoidCallback action) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkSoft),
          const SizedBox(width: 12),
          Text(label, style: AppText.ui(14, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Nav flotante tipo píldora (solo móvil) — los mismos 3 destinos del
/// sidebar: Inicio / Actividades / Menú.
class _ComercioBottomNav extends StatelessWidget {
  const _ComercioBottomNav({required this.section, required this.onSelect});

  final ComercioSection section;
  final ValueChanged<ComercioSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        ComercioSection.inicio,
        Icons.home_outlined,
        Icons.home,
        l10n.homeComercioNavHome,
      ),
      (
        ComercioSection.actividades,
        Icons.event_note_outlined,
        Icons.event_note,
        l10n.homeComercioNavActivities,
      ),
      (
        ComercioSection.promociones,
        Icons.local_offer_outlined,
        Icons.local_offer,
        l10n.comercioNavPromos,
      ),
      (
        ComercioSection.menu,
        Icons.restaurant_menu_outlined,
        Icons.restaurant_menu,
        l10n.homeComercioNavMenu,
      ),
    ];
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadius.nav),
          boxShadow: AppShadow.raised,
        ),
        child: Row(
          children: [
            for (final (target, icon, activeIcon, label) in items)
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(target),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: AppMotion.enter,
                      decoration: BoxDecoration(
                        color: target == section
                            ? AppColors.wash
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            target == section ? activeIcon : icon,
                            size: 20,
                            color: target == section
                                ? AppColors.ink
                                : AppColors.textMuted,
                          ),
                          Text(
                            label,
                            style: AppText.ui(
                              11,
                              weight: target == section
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: target == section
                                  ? AppColors.ink
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Buscador en móvil (en escritorio vive en el `TopBar` del shell).
class _MobileSearchField extends StatefulWidget {
  const _MobileSearchField({
    required this.initialQuery,
    required this.onChanged,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<_MobileSearchField> createState() => _MobileSearchFieldState();
}

class _MobileSearchFieldState extends State<_MobileSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      style: AppText.ui(14),
      decoration: InputDecoration(
        isDense: true,
        hintText: context.l10n.comercioSearchHint,
        hintStyle: AppText.ui(14, color: AppColors.textMuted),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textMuted,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
