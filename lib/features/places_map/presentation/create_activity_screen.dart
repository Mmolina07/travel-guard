import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/app_auth_provider.dart';
import '../data/models/actividad_model.dart';
import '../data/places_map_repository.dart';
import '../providers/comercio_panel_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/ink_button.dart';
import '../../../widgets/segmented_pill.dart';
import 'widgets/comercio_scaffold.dart';
import 'widgets/comercio_ui.dart';

/// `Page` de `/comercio/actividades/nueva` (y, con [promocion], de
/// `/comercio/promociones/nueva`): diálogo (overlay `ink` 55 % + blur 3,
/// fade + scale 0.96 → 1) sobre la vista actual en escritorio y tablet;
/// pantalla completa en móvil.
Page<void> buildCreateActivityPage(
  BuildContext context,
  GoRouterState state, {
  bool promocion = false,
}) {
  // `/comercio/actividades/:id/editar`: mismo modal, en modo edición.
  final editId = int.tryParse(state.pathParameters['id'] ?? '');
  if (context.isMobile) {
    return MaterialPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: CreateActivityScreen(promocion: promocion, editId: editId),
    );
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierDismissible: false,
    // El scrim con blur lo dibuja `ComercioModalFrame`.
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    child: CreateActivityScreen(
      asDialog: true,
      promocion: promocion,
      editId: editId,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// "Crear actividad": vista previa en vivo (columna `ink`) + los mismos
/// campos, validaciones y guardado de siempre. Al guardar cierra, navega
/// a Actividades con el filtro "Todas" y la nueva queda primera.
///
/// Con [promocion] es "Crear promoción": la misma lógica, pero la
/// categoría es siempre "Promoción", es exclusiva para turistas Premium
/// y al guardar navega a Promociones.
///
/// Con [editId] edita esa actividad/promoción: el formulario arranca con
/// sus datos y al guardar la actualiza (en vez de crear otra).
class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({
    Key? key,
    this.asDialog = false,
    this.promocion = false,
    this.editId,
  }) : super(key: key);

  final bool asDialog;
  final bool promocion;
  final int? editId;

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _placesMapRepository = PlacesMapRepository();

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Valores seleccionados
  late String? _selectedCategory = widget.promocion ? Actividad.categoriaPromocion : null;

  /// "¿Quién la puede ver?": todo el público o solo turistas Premium.
  /// Las promociones siempre son solo Premium.
  bool _soloPremium = false;
  String _selectedStatus = EstadoActividad.borrador;
  DateTime? _startDate;
  DateTime? _endDate;

  // Banderas
  bool _isFree = false;
  bool _hasNoEndDate = false;
  bool _isLoading = false;

  /// Errores por campo (se muestran bajo cada uno, sin mover el layout).
  Map<String, String> _errors = const {};

  // ⚠️ Se guardan tal cual en `actividades.categoria` — NO traducir.
  // "Promoción" ya no está aquí: las promociones se crean desde su
  // propia sección ("Crear promoción"), que la fija sola.
  final List<String> _categories = [
    'Fiesta',
    'Tour',
    'Clase',
    'Evento',
    'Otro',
  ];

  bool get _isPremiumOnly => widget.promocion || _soloPremium;

  bool get _isEdit => widget.editId != null;

  /// La actividad que se está editando (null mientras carga o al crear).
  Actividad? _editing;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadForEdit());
    }
    // La vista previa se actualiza en cada pulsación de tecla.
    for (final c in [
      _nameController,
      _descriptionController,
      _priceController,
    ]) {
      c.addListener(_onTyping);
    }
  }

  void _onTyping() => setState(() {});

  /// Busca la actividad en el panel (cargándolo si se abrió el enlace
  /// directo) y llena el formulario con sus datos.
  Future<void> _loadForEdit() async {
    final panel = context.read<ComercioPanelProvider>();
    await panel.ensureLoaded();
    if (!mounted) return;
    Actividad? actividad;
    for (final a in panel.actividades) {
      if (a.id == widget.editId) actividad = a;
    }
    if (actividad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.comercioEditNotFound)),
      );
      context.go(_listRoute);
      return;
    }
    final a = actividad;
    setState(() {
      _editing = a;
      _nameController.text = a.nombre;
      _descriptionController.text = a.descripcion ?? '';
      final precio = a.precio;
      _isFree = precio == null || precio <= 0;
      _priceController.text = _isFree ? '' : formatCOP(precio!.round());
      _selectedCategory = widget.promocion
          ? Actividad.categoriaPromocion
          : a.categoria;
      // Una categoría que ya no está en la lista se conserva igual.
      final cat = a.categoria;
      if (!widget.promocion && cat != null && !_categories.contains(cat)) {
        _categories.add(cat);
      }
      _soloPremium = a.soloPremium;
      _selectedStatus = EstadoActividad.normalizar(a.estado);
      _startDate = a.fechaInicio;
      _endDate = a.fechaFin;
      _hasNoEndDate = a.fechaFin == null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ─── Selector de fecha ───
  Future<void> _selectDate({required bool isStart}) async {
    final DateTime today = DateTime.now();
    final current = isStart ? _startDate : _endDate;
    final first = !isStart && _startDate != null
        ? _startDate!
        : DateUtils.dateOnly(today);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(first) ? current : first,
      // La fecha de fin no puede quedar antes del inicio.
      firstDate: first,
      lastDate: DateTime(2100),
      helpText: context.l10n.createActivityDatePickerHelpText,
      cancelText: context.l10n.createActivityDatePickerCancel,
      confirmText: context.l10n.createActivityDatePickerConfirm,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          // Un fin que quedó antes del nuevo inicio se descarta.
          final end = _endDate;
          if (end != null && end.isBefore(pickedDate)) _endDate = null;
        } else {
          _endDate = pickedDate;
        }
        _errors = Map.of(_errors)..remove(isStart ? 'start' : 'end');
      });
    }
  }

  double? get _price {
    final digits = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : double.tryParse(digits);
  }

  // ─── Validación (mismas reglas que el formulario anterior) ───
  bool _validateActivity() {
    final l10n = context.l10n;
    final errors = <String, String>{};
    if (_nameController.text.trim().isEmpty) {
      errors['name'] = l10n.createActivityNameRequired;
    } else {
      final nameError = Validators.title(context, _nameController.text, max: 150);
      if (nameError != null) errors['name'] = nameError;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      errors['description'] = l10n.createActivityDescriptionRequired;
    } else if (description.length < 10) {
      errors['description'] = l10n.createActivityDescriptionTooShort;
    } else {
      final descError = Validators.freeText(context, description, max: 1000);
      if (descError != null) errors['description'] = descError;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      errors['category'] = l10n.createActivityCategoryRequired;
    }
    if (!_isFree) {
      final price = _price;
      if (_priceController.text.trim().isEmpty) {
        errors['price'] = l10n.createActivityPriceRequired;
      } else if (price == null || price <= 0) {
        // $0 sin marcar "Gratis" se trata como olvido: se pide uno de los dos.
        errors['price'] = l10n.createActivityPriceRequired;
      }
    }
    if (_startDate == null) {
      errors['start'] = l10n.createActivityStartDateSnackbar;
    }
    if (!_hasNoEndDate && _endDate == null) {
      errors['end'] = l10n.createActivityEndDateSnackbar;
    }
    final start = _startDate;
    final end = _endDate;
    if (!_hasNoEndDate && start != null && end != null && end.isBefore(start)) {
      errors['end'] = l10n.valEndBeforeStart;
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  // ─── Crear actividad ───
  Future<void> _handleCreateActivity() async {
    if (_isLoading || !_validateActivity()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final editing = _editing;
    if (editing != null) {
      await _saveEdit(editing);
      return;
    }

    try {
      final comercioId = context.read<AppAuthProvider>().usuario!.id;
      final Actividad actividad = await _placesMapRepository.createActividad(
        comercioId: comercioId,
        nombre: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        categoria: _selectedCategory ?? 'Otro',
        precio: _isFree ? null : _price,
        estado: _selectedStatus,
        fechaInicio: _startDate,
        fechaFin: _hasNoEndDate ? null : _endDate,
        soloPremium: _isPremiumOnly,
      );

      if (!mounted) return;
      context.read<ComercioPanelProvider>().insertActividad(actividad);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.promocion
                ? context.l10n.comercioPromoCreatedSnackbar(actividad.nombre)
                : context.l10n.homeComercioActivityCreatedSnackbar(actividad.nombre),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
      // Cierra el modal y deja la lista con el filtro "Todas".
      context.go(_listRoute);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createActivitySaveErrorSnackbar)),
      );
    }
  }

  // ─── Guardar cambios (modo edición) ───
  Future<void> _saveEdit(Actividad original) async {
    final updated = Actividad(
      id: original.id,
      comercioId: original.comercioId,
      nombre: _nameController.text.trim(),
      descripcion: _descriptionController.text.trim(),
      categoria: _selectedCategory ?? 'Otro',
      estado: _selectedStatus,
      precio: _isFree ? null : _price,
      duracionMin: original.duracionMin,
      activo: _selectedStatus == EstadoActividad.activa,
      fechaInicio: _startDate,
      fechaFin: _hasNoEndDate ? null : _endDate,
      soloPremium: _isPremiumOnly,
    );
    try {
      await _placesMapRepository.updateActividad(updated);
      if (!mounted) return;
      context.read<ComercioPanelProvider>().replaceActividad(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.comercioActivityUpdatedSnackbar(updated.nombre),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
      context.go(_listRoute);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.comercioEditSaveError)),
      );
    }
  }

  // ─── Eliminar (modo edición) ───
  Future<void> _confirmDelete(Actividad actividad) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.comercioDeleteConfirmTitle(actividad.nombre),
          style: AppText.display(20),
        ),
        content: Text(
          l10n.comercioDeleteConfirmBody,
          style: AppText.ui(14, color: AppColors.textMuted),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        actions: [
          InkButton(
            label: l10n.createActivityCancelButton,
            variant: InkButtonVariant.secondary,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          InkButton(
            label: l10n.comercioDeleteButton,
            icon: Icons.delete_outline,
            variant: InkButtonVariant.danger,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _placesMapRepository.deleteActividad(actividad.id);
      if (!mounted) return;
      context.read<ComercioPanelProvider>().removeActividad(actividad.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.comercioDeletedSnackbar(actividad.nombre)),
          backgroundColor: AppColors.ink,
        ),
      );
      context.go(_listRoute);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.comercioDeleteError)),
      );
    }
  }

  void _close() {
    if (_isLoading) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_listRoute);
    }
  }

  String get _listRoute =>
      widget.promocion ? ComercioRoutes.promociones : ComercioRoutes.actividades;

  String _statusLabel(String estado) => estadoActividadLabel(context, estado);

  String _nameLabel(AppLocalizations l10n) =>
      widget.promocion ? l10n.comercioPromoNameLabel : l10n.createActivityNameLabel;

  String get _submitLabel {
    final l10n = context.l10n;
    return switch (_selectedStatus) {
      EstadoActividad.activa =>
        widget.promocion ? l10n.comercioSubmitPublishPromo : l10n.comercioSubmitPublish,
      EstadoActividad.pausada => l10n.comercioSubmitPaused,
      _ => l10n.comercioSubmitDraft,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ComercioModalFrame(
      asDialog: widget.asDialog,
      onDismiss: _isLoading ? null : _close,
      preview: _buildPreview(context),
      form: _isEdit && _editing == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.ink),
              ),
            )
          : _buildForm(context),
    );
  }

  // ─── Columna izquierda: vista previa en vivo ───

  String _previewDates() {
    final start = _startDate;
    if (start == null) return context.l10n.comercioDatesNone;
    final a = formatDiaMes(context, start);
    if (_hasNoEndDate) return context.l10n.comercioDatesFrom(a);
    final end = _endDate;
    return end == null ? a : '$a — ${formatDiaMes(context, end)}';
  }

  Widget _buildPreview(BuildContext context) {
    final l10n = context.l10n;
    final panel = context.watch<ComercioPanelProvider>();
    final auth = context.watch<AppAuthProvider>();
    final comercio = panel.comercio;
    final businessName = comercio?.nombreComercio ?? auth.displayName;
    final sede = comercio?.sede?.trim() ?? '';
    final zone = sede.isNotEmpty ? sede : (comercio?.direccion.trim() ?? '');

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _price;
    final priceLabel = _isFree
        ? l10n.comercioFree.toUpperCase()
        : (price != null ? formatCOP(price) : r'$ —');

    final (dot, note) = switch (_selectedStatus) {
      EstadoActividad.activa => (
        AppColors.mint,
        l10n.comercioStatusNotePublished,
      ),
      EstadoActividad.pausada => (
        AppColors.statusPausedDot,
        l10n.comercioStatusNotePaused,
      ),
      _ => (AppColors.textOnInk, l10n.comercioStatusNoteDraft),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PreviewHeading(
          eyebrow: _isEdit
              ? l10n.comercioEditEyebrow
              : widget.promocion
              ? l10n.comercioNewPromoEyebrow
              : l10n.comercioNewActivityEyebrow,
          line1: l10n.comercioPreviewTitle1,
          line2: _isPremiumOnly ? l10n.comercioPromoPreviewTitle2 : l10n.comercioPreviewTitle2,
        ),
        const SizedBox(height: 22),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 120,
                color: AppColors.wash,
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        activityCategoryIcon(_selectedCategory),
                        size: 34,
                        color: AppColors.inkSoft.withValues(alpha: 0.35),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: _PreviewBadge(
                        label: (_selectedCategory ?? l10n.comercioColCategory)
                            .toUpperCase(),
                        background: AppColors.ink,
                        foreground: AppColors.mint,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: _PreviewBadge(
                        label: priceLabel,
                        background: AppColors.paper.withValues(alpha: 0.94),
                        foreground: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isPremiumOnly) ...[
                      const PremiumTag(),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      name.isEmpty ? _nameLabel(l10n) : name,
                      style: AppText.display(
                        22,
                        color: name.isEmpty
                            ? AppColors.textLabel
                            : AppColors.ink,
                      ).copyWith(height: 1.12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isEmpty
                          ? l10n.comercioPreviewDescPlaceholder
                          : description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.ui(
                        12,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _previewDates().toUpperCase(),
                      style: AppText.label(
                        11,
                        color: AppColors.textMuted,
                      ).copyWith(letterSpacing: 0),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      zone.isEmpty ? businessName : '$businessName · $zone',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.ui(
                        12,
                        weight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PreviewStatusNote(color: dot, note: note),
      ],
    );
  }

  // ─── Columna derecha: formulario ───

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    final categoryIndex = _selectedCategory == null
        ? -1
        : _categories.indexOf(_selectedCategory!);
    final statusIndex = EstadoActividad.ordenados.indexOf(_selectedStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit
                        ? (widget.promocion
                              ? l10n.comercioEditPromoHeading
                              : l10n.comercioEditActivityHeading)
                        : widget.promocion
                        ? l10n.comercioNewPromoHeading
                        : l10n.createActivityHeading,
                    style: AppText.display(30),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEdit
                        ? l10n.comercioEditSubtitle
                        : widget.promocion
                        ? l10n.comercioNewPromoSubtitle
                        : l10n.createActivitySubtitle,
                    style: AppText.ui(14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ModalCloseButton(
              onTap: _isLoading ? null : _close,
              tooltip: l10n.createActivityCancelButton,
            ),
          ],
        ),
        const SizedBox(height: 22),
        AnimatedOpacity(
          opacity: _isLoading ? 0.5 : 1,
          duration: AppMotion.pressIn,
          child: IgnorePointer(
            ignoring: _isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre
                FieldCaption(_nameLabel(l10n)),
                TextField(
                  controller: _nameController,
                  autofocus: widget.asDialog,
                  style: AppText.ui(19, weight: FontWeight.w400),
                  cursorColor: AppColors.inkSoft,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    AppInputFormatters.safeText,
                    AppInputFormatters.maxLength(150),
                  ],
                  decoration: InputDecoration(
                    hintText: widget.promocion ? l10n.comercioPromoNameHint : l10n.createActivityNameHint,
                    hintStyle: AppText.ui(
                      19,
                      weight: FontWeight.w400,
                      color: AppColors.textLabel,
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                  ),
                ),
                FieldError(_errors['name']),
                const SizedBox(height: 22),

                // Descripción
                FieldCaption(l10n.createActivityDescriptionLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 8,
                  inputFormatters: [
                    AppInputFormatters.safeText,
                    AppInputFormatters.maxLength(1000),
                  ],
                  style: AppText.ui(15, weight: FontWeight.w400, height: 1.5),
                  cursorColor: AppColors.inkSoft,
                  decoration: InputDecoration(
                    hintText: l10n.createActivityDescriptionHint,
                    hintStyle: AppText.ui(
                      15,
                      weight: FontWeight.w400,
                      color: AppColors.textLabel,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                ),
                FieldError(_errors['description']),
                const SizedBox(height: 22),

                // Categoría (una promoción ya la tiene fija)
                if (!widget.promocion) ...[
                  FieldCaption(l10n.createActivityCategoryLabel),
                  const SizedBox(height: 10),
                  FilterChipsRow(
                    items: _categories,
                    selected: categoryIndex,
                    fontSize: 14,
                    duration: const Duration(milliseconds: 300),
                    curve: AppMotion.enter,
                    onSelect: (i) => setState(() {
                      _selectedCategory = _categories[i];
                      _errors = Map.of(_errors)..remove('category');
                    }),
                  ),
                  FieldError(_errors['category']),
                  const SizedBox(height: 22),
                ],

                // ¿Quién la puede ver?
                FieldCaption(l10n.comercioAudienceLabel),
                const SizedBox(height: 10),
                if (widget.promocion)
                  _AudienceNote(text: l10n.comercioPromoAudienceNote)
                else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SegmentedPill(
                        labels: [l10n.comercioAudiencePublic, l10n.comercioAudiencePremium],
                        index: _soloPremium ? 1 : 0,
                        onChanged: (i) => setState(() => _soloPremium = i == 1),
                      ),
                    ),
                  ),
                  if (_soloPremium) ...[
                    const SizedBox(height: 10),
                    _AudienceNote(text: l10n.comercioAudiencePremiumNote),
                  ],
                ],
                const SizedBox(height: 22),

                // Precio / Fecha de inicio / Fin
                LayoutBuilder(
                  builder: (context, constraints) {
                    final boxes = [
                      _buildPriceBox(context),
                      _buildStartBox(context),
                      _buildEndBox(context),
                    ];
                    if (constraints.maxWidth < 480) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < boxes.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            boxes[i],
                          ],
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < boxes.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: boxes[i]),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),

                // Estado
                FieldCaption(l10n.createActivityStatusLabel),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SegmentedPill(
                      labels: [
                        for (final e in EstadoActividad.ordenados)
                          _statusLabel(e),
                      ],
                      index: statusIndex,
                      onChanged: (i) => setState(
                        () => _selectedStatus = EstadoActividad.ordenados[i],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        if (_editing case final editing?) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _isLoading ? null : () => _confirmDelete(editing),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(l10n.comercioDeleteButton),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ModalFooter(
          cancelLabel: l10n.createActivityCancelButton,
          submitLabel: _submitLabel,
          loading: _isLoading,
          onCancel: _isLoading ? null : _close,
          onSubmit: _nameController.text.trim().isEmpty
              ? null
              : _handleCreateActivity,
        ),
      ],
    );
  }

  Widget _box({
    required Widget header,
    required Widget value,
    required bool dimmed,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paperDeep,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20, child: header),
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: AppMotion.pressIn,
                opacity: dimmed ? 0.35 : 1,
                child: SizedBox(height: 32, child: value),
              ),
            ],
          ),
        ),
        FieldError(error),
      ],
    );
  }

  Widget _buildPriceBox(BuildContext context) {
    final l10n = context.l10n;
    return _box(
      dimmed: _isFree,
      error: _errors['price'],
      header: Row(
        children: [
          Expanded(child: FieldCaption(l10n.createActivityPriceLabel)),
          MiniSwitch(
            value: _isFree,
            label: l10n.comercioFree,
            onChanged: (v) => setState(() {
              _isFree = v;
              if (_isFree) _priceController.clear();
              _errors = Map.of(_errors)..remove('price');
            }),
          ),
        ],
      ),
      value: TextField(
        controller: _priceController,
        enabled: !_isFree,
        keyboardType: TextInputType.number,
        inputFormatters: [_CopPriceFormatter()],
        style: AppText.display(26),
        cursorColor: AppColors.inkSoft,
        decoration: InputDecoration(
          hintText: r'$ 0',
          hintStyle: AppText.display(26, color: AppColors.textLabel),
          filled: false,
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dateValue({
    required DateTime? date,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final text = date == null
        ? context.l10n.comercioPickDate
        : DateFormat('dd/MM/yyyy').format(date);
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.ui(
              16,
              weight: FontWeight.w400,
              color: date == null ? AppColors.textLabel : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartBox(BuildContext context) {
    return _box(
      dimmed: false,
      error: _errors['start'],
      header: Align(
        alignment: Alignment.centerLeft,
        child: FieldCaption(context.l10n.createActivityStartDateLabel),
      ),
      value: _dateValue(
        date: _startDate,
        enabled: true,
        onTap: () => _selectDate(isStart: true),
      ),
    );
  }

  Widget _buildEndBox(BuildContext context) {
    final l10n = context.l10n;
    return _box(
      dimmed: _hasNoEndDate,
      error: _errors['end'],
      header: Row(
        children: [
          Expanded(child: FieldCaption(l10n.comercioEndShort)),
          MiniSwitch(
            value: _hasNoEndDate,
            label: l10n.comercioNoEndToggle,
            onChanged: (v) => setState(() {
              _hasNoEndDate = v;
              if (_hasNoEndDate) _endDate = null;
              _errors = Map.of(_errors)..remove('end');
            }),
          ),
        ],
      ),
      value: _dateValue(
        date: _endDate,
        enabled: !_hasNoEndDate,
        onTap: () => _selectDate(isStart: false),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppText.label(
          10,
          color: foreground,
        ).copyWith(letterSpacing: 10 * 0.12),
      ),
    );
  }
}

/// Precio con formato `$32.000` mientras se escribe (solo dígitos).
class _CopPriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final formatted = formatCOP(
      // `numeric(12,2)` admite 10 dígitos enteros.
      int.parse(
        digits.length > Validators.maxMoneyDigits
            ? digits.substring(0, Validators.maxMoneyDigits)
            : digits,
      ),
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Nota con icono Premium bajo "¿Quién la puede ver?".
class _AudienceNote extends StatelessWidget {
  const _AudienceNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.workspace_premium_outlined, size: 16, color: AppColors.inkSoft),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppText.ui(13, color: AppColors.textMuted))),
      ],
    );
  }
}
