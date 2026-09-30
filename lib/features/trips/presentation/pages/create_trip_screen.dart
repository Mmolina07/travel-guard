import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../../widgets/filter_chips_row.dart';
import '../../../../widgets/step_progress.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../data/models/trip_budget_category.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../widgets/category_field_row.dart';
import 'trip_detail_screen.dart';
import 'trip_model.dart';

/// Abre el wizard de "Crear viaje" en la ruta `/crear` (Fase 5: URL real
/// para el modal, back del navegador funcional y atajo `N`/`Esc`). Sigue
/// devolviendo el `Trip` guardado, o `null` si se canceló — mismo
/// contrato que tenían el `showGeneralDialog`/`Navigator.push` previos,
/// así que ninguno de sus llamadores necesitó cambiar.
Future<Trip?> showCreateTripDialog(BuildContext context) {
  return context.push<Trip>('/crear');
}

/// `Page` de la ruta `/crear` — diálogo de dos columnas (260:resto)
/// centrado sobre la vista actual en escritorio/tablet, tal como
/// `WEB_LAYOUT.md`; en móvil el mismo wizard se abre a pantalla completa
/// con la CTA fija del README. Vive aquí (y no en `app_router.dart`)
/// porque necesita el widget privado `_CreateTripWizard`.
Page<Trip> buildCreateTripPage(BuildContext context, GoRouterState state) {
  if (context.isMobile) {
    return MaterialPage<Trip>(
      fullscreenDialog: true,
      child: const _CreateTripWizard(asDialog: false),
    );
  }
  return CustomTransitionPage<Trip>(
    opaque: false,
    barrierDismissible: true,
    barrierLabel: context.l10n.createTripBarrierLabel,
    // El scrim con blur lo dibuja el propio wizard (BackdropFilter) —
    // así podemos difuminar detrás del diálogo, algo que el
    // `barrierColor` plano no permite por sí solo.
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    child: const _CreateTripWizard(asDialog: true),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
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

class _CreateTripWizard extends StatefulWidget {
  const _CreateTripWizard({required this.asDialog});

  final bool asDialog;

  @override
  State<_CreateTripWizard> createState() => _CreateTripWizardState();
}

class _CreateTripWizardState extends State<_CreateTripWizard> {
  static const _stepCount = 3;

  /// Título (línea 1, línea 2) de cada paso del wizard, ya localizado.
  (String, String) _stepTitle(BuildContext context, int step) {
    return switch (step) {
      0 => (context.l10n.createTripStep0TitleLine1, context.l10n.createTripStep0TitleLine2),
      1 => (context.l10n.createTripStep1TitleLine1, context.l10n.createTripStep1TitleLine2),
      _ => (context.l10n.createTripStep2TitleLine1, context.l10n.createTripStep2TitleLine2),
    };
  }

  /// Nombres de los pasos (columna izquierda / footer), ya localizados.
  List<String> _stepNames(BuildContext context) => [
        context.l10n.createTripStepNameDestination,
        context.l10n.createTripStepNameLodging,
        context.l10n.createTripStepNameTransport,
      ];

  // ⚠️ Estos valores se guardan tal cual en la tabla `viajes` de Supabase
  // (ver `trip_repository.dart` `_mapTipoViaje`/`_unmapTipoViaje`) — NO
  // traducir, se comparan por igualdad de string contra la base de datos.
  static const _tripTypes = ['Vacaciones', 'Trabajo', 'Ocio', 'Otro'];

  // ⚠️ `tipo_hospedaje` es un varchar libre en Supabase (sin mapeo a
  // enum): se guarda y se vuelve a mostrar tal cual se eligió aquí. NO
  // traducir — si se tradujera, un viaje creado en un idioma mostraría
  // el hospedaje en ese idioma para siempre, sin importar el idioma
  // actual de la app (comportamiento inconsistente con el resto de la
  // UI, que sí cambia con el idioma).
  static const _lodgingTypes = ['Hotel', 'Hostel', 'Airbnb', 'Casa alquilada', 'Otro'];

  // ⚠️ Igual que `_tripTypes`: se comparan por igualdad de string contra
  // `_mapTransporte`/`_unmapTransporte` en `trip_repository.dart`. NO
  // traducir.
  static const _transportTypes = ['Carro', 'Transporte público', 'Uber', 'Vuelo'];

  int _step = 0;

  // Controladores de texto
  late TextEditingController _nameController;
  late TextEditingController _destinationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _personsController;
  late TextEditingController _maxBudgetController;
  late TextEditingController _advancePaymentController;
  late TextEditingController _lodgingCostController;
  late TextEditingController _emergencyMoneyController;

  // Categorías de presupuesto personalizables (mejora "gestor de
  // presupuesto"): se precargan con los nombres de siempre para no
  // sorprender a quien ya conocía el formulario, pero el usuario puede
  // renombrarlas, borrarlas o agregar las que quiera.
  final List<CategoryFieldRow> _categoryRows = [];

  // Valores seleccionados
  String _tripType = 'Vacaciones';
  String _lodgingType = 'Hotel';
  String _startTransport = 'Vuelo';
  String _duringTransport = 'Transporte público';

  // Servicios incluidos
  bool _includeBreakfast = false;
  bool _includeLunch = false;
  bool _includeDinner = false;
  bool _includeTransfer = false;

  bool _isLoading = false;

  // El wizard se dibuja sobre un `BackdropFilter` propio (ver
  // `_buildDialog`) — un `SnackBar` normal vía `ScaffoldMessenger`
  // termina detrás de ese blur (el `Scaffold` que lo resuelve es el de
  // la pantalla de atrás, no el del wizard) y se ve difuminado e
  // ilegible. Este banner se pinta como el ÚLTIMO hijo del `Stack` raíz
  // (ver `build`), después del blur, así que siempre queda nítido y
  // encima de todo.
  String? _banner;
  Timer? _bannerTimer;

  final TripRepository _tripRepository = TripRepository();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _destinationController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _personsController = TextEditingController();
    _maxBudgetController = TextEditingController();
    _advancePaymentController = TextEditingController();
    _lodgingCostController = TextEditingController();
    _emergencyMoneyController = TextEditingController();
    _categoryRows.addAll([
      CategoryFieldRow(nombre: 'Tours con guía'),
      CategoryFieldRow(nombre: 'Restaurantes'),
      CategoryFieldRow(nombre: 'Discotecas'),
      CategoryFieldRow(nombre: 'Souvenirs'),
      CategoryFieldRow(nombre: 'Actividades pagas'),
    ]);
  }

  void _addCategoryRow() {
    setState(() => _categoryRows.add(CategoryFieldRow()));
  }

  void _removeCategoryRow(CategoryFieldRow row) {
    setState(() {
      _categoryRows.remove(row);
      row.dispose();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _personsController.dispose();
    _maxBudgetController.dispose();
    _advancePaymentController.dispose();
    _lodgingCostController.dispose();
    _emergencyMoneyController.dispose();
    for (final row in _categoryRows) {
      row.dispose();
    }
    _bannerTimer?.cancel();
    super.dispose();
  }

  static final DateTime _today = DateTime.now();
  static final DateTime _maxSelectableDate = DateTime(
    _today.year + 2,
    _today.month,
    _today.day,
  );

  static final List<TextInputFormatter> _digitsOnlyFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];
  static final List<TextInputFormatter> _moneyFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime firstDate,
    DateTime? initialDate,
  }) async {
    // El propio rango puede quedar invertido si, p.ej., la fecha de
    // inicio elegida ya pasó `_maxSelectableDate` (caso extremo, pero
    // evita el "!lastDate.isBefore(firstDate)" del date picker).
    final lastDate = firstDate.isAfter(_maxSelectableDate) ? firstDate : _maxSelectableDate;
    var initial = initialDate ?? firstDate;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.ink),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => controller.text = DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  Future<void> _selectStartDate() async {
    await _pickDate(
      controller: _startDateController,
      firstDate: _today,
      initialDate: _parseDate(_startDateController.text),
    );

    // Si la fecha de fin ya elegida quedó antes/igual a la nueva fecha
    // de inicio, la limpiamos para no dejar el formulario en un estado
    // inválido sin que el usuario lo note.
    final start = _parseDate(_startDateController.text);
    final end = _parseDate(_endDateController.text);
    if (start != null && end != null && !end.isAfter(start)) {
      setState(() => _endDateController.clear());
    }
  }

  Future<void> _selectEndDate() async {
    final start = _parseDate(_startDateController.text);
    if (start == null) {
      _showError(context.l10n.createTripErrorSelectStartDateFirst);
      return;
    }
    await _pickDate(
      controller: _endDateController,
      firstDate: start.add(const Duration(days: 1)),
      initialDate: _parseDate(_endDateController.text),
    );
  }

  /// Duración del viaje en días, o `null` si las fechas aún no son válidas.
  int? get _tripDurationInDays {
    final start = _parseDate(_startDateController.text);
    final end = _parseDate(_endDateController.text);
    if (start == null || end == null || !end.isAfter(start)) return null;
    return end.difference(start).inDays;
  }

  String? _validateStep0() {
    if (_nameController.text.trim().isEmpty || _destinationController.text.trim().isEmpty) {
      return context.l10n.createTripErrorNameDestinationRequired;
    }
    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);
    if (startDate == null || endDate == null) return context.l10n.createTripErrorInvalidDates;
    if (!endDate.isAfter(startDate)) {
      return context.l10n.createTripErrorEndDateAfterStart;
    }
    final persons = int.tryParse(_personsController.text.trim());
    if (persons == null || persons <= 0) return context.l10n.createTripErrorMinOnePerson;
    return null;
  }

  void _goNext() {
    if (_isLoading) return;
    if (_step == 0) {
      final error = _validateStep0();
      if (error != null) {
        _showError(error);
        return;
      }
    }
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _handleCreateTrip();
    }
  }

  void _goBack() {
    if (_step > 0) setState(() => _step--);
  }

  void _goToStep(int index) {
    if (index <= _step) setState(() => _step = index);
  }

  void _handleCreateTrip() async {
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    // Escenario 8/9 de HU-05: datos opcionales incompletos.
    final datosCompletos = !_hasIncompleteOptionalFields();
    if (!datosCompletos) {
      final continuar = await _confirmPartialData();
      if (continuar != true) return;
    }

    await _saveTrip(datosCompletos: datosCompletos);
  }

  /// Escenarios 2-7 de HU-05, con los mensajes exactos de la historia.
  String? _validateForm() {
    final camposBasicosVacios =
        _nameController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty ||
        _startDateController.text.trim().isEmpty ||
        _endDateController.text.trim().isEmpty ||
        _personsController.text.trim().isEmpty ||
        _maxBudgetController.text.trim().isEmpty;
    if (camposBasicosVacios) {
      return context.l10n.createTripErrorRequiredFields;
    }

    final persons = int.tryParse(_personsController.text.trim());
    if (persons == null || persons <= 0) {
      return context.l10n.createTripErrorMinOnePerson;
    }

    if (_maxBudget <= 0) {
      return context.l10n.createTripErrorBudgetMustBePositive;
    }

    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);
    if (startDate == null || endDate == null) {
      return context.l10n.createTripErrorInvalidDatesEntered;
    }
    if (!endDate.isAfter(startDate)) {
      return context.l10n.createTripErrorEndDateAfterStartFull;
    }

    if (_lodgingCostController.text.trim().isNotEmpty) {
      final lodgingCost = double.tryParse(_lodgingCostController.text.trim());
      if (lodgingCost == null || lodgingCost <= 0) {
        return context.l10n.createTripErrorLodgingCostMustBePositive;
      }
    }

    if (_emergencyMoneyController.text.trim().isNotEmpty) {
      final emergencyMoney = double.tryParse(_emergencyMoneyController.text.trim());
      if (emergencyMoney == null || emergencyMoney <= 0) {
        return context.l10n.createTripErrorEmergencyAmountMustBePositive;
      }
    }

    return null;
  }

  DateTime? _parseDate(String value) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }

  /// Escenario 8 de HU-05: campos opcionales (no básicos) sin completar.
  /// "Dinero emergencias" queda fuera a propósito: no es obligatorio
  /// tener un fondo de emergencia definido para crear el viaje, así que
  /// dejarlo vacío no debe disparar el aviso de "datos incompletos".
  bool _hasIncompleteOptionalFields() {
    final sinServiciosIncluidos =
        !_includeBreakfast && !_includeLunch && !_includeDinner && !_includeTransfer;
    return _advancePaymentController.text.trim().isEmpty ||
        _lodgingCostController.text.trim().isEmpty ||
        sinServiciosIncluidos ||
        _categoryRows.any((row) => row.montoController.text.trim().isEmpty);
  }

  Future<bool?> _confirmPartialData() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.createTripIncompleteDataDialogTitle),
        content: Text(context.l10n.createTripIncompleteDataDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.createTripCancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.createTripConfirmCreateButton),
          ),
        ],
      ),
    );
  }

  /// TG-141: guarda el viaje en la tabla `viajes` de Supabase.
  Future<void> _saveTrip({required bool datosCompletos}) async {
    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final turistaId = auth.usuario?.id;
    if (turistaId == null) {
      setState(() => _isLoading = false);
      _showError(context.l10n.createTripErrorMustBeLoggedIn);
      return;
    }

    final trip = Trip(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      persons: int.parse(_personsController.text.trim()),
      tripType: _tripType,
      maxBudget: _maxBudget,
      advancePayment: double.tryParse(_advancePaymentController.text) ?? 0,
      lodgingType: _lodgingType,
      lodgingCost: double.tryParse(_lodgingCostController.text) ?? 0,
      includedServices: [
        if (_includeBreakfast) 'Desayuno',
        if (_includeLunch) 'Almuerzo',
        if (_includeDinner) 'Cena',
        if (_includeTransfer) 'Traslado',
      ],
      startTransport: _startTransport,
      duringTransport: _duringTransport,
      categories: [
        for (final row in _categoryRows)
          if (row.nombreController.text.trim().isNotEmpty)
            TripBudgetCategory(nombre: row.nombreController.text.trim(), monto: row.monto),
      ],
      emergencyMoney: double.tryParse(_emergencyMoneyController.text) ?? 0,
      datosCompletos: datosCompletos,
    );

    try {
      final saved = await _tripRepository.createTrip(turistaId: turistaId, trip: trip);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Escenario 1 de HU-05: feedback de éxito con presupuesto total.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.createTripCreatedSnackbar(context.formatMoney(saved.maxBudget))),
          backgroundColor: AppColors.inkSoft,
        ),
      );

      // Muestra el resumen con presupuesto total (Escenario 1).
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripDetailScreen(trip: saved)),
      );

      if (!mounted) return;
      Navigator.pop(context, saved);
    } on PostgrestException catch (e, st) {
      debugPrint(
        'CreateTripScreen._saveTrip PostgrestException: '
        '${e.message} (code: ${e.code})\n$st',
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(_mapSaveTripError(e));
    } catch (e, st) {
      debugPrint('CreateTripScreen._saveTrip error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(context.l10n.createTripErrorSaveGeneric);
    }
  }

  /// Traduce errores comunes de Postgres/Supabase a un mensaje claro,
  /// y deja el detalle real en consola (`debugPrint`) para depurar.
  String _mapSaveTripError(PostgrestException e) {
    final detalle = '${e.message} ${e.details ?? ''}'.toLowerCase();
    if (e.code == '42P01' || detalle.contains('does not exist')) {
      return context.l10n.createTripErrorDbOutdated;
    }
    if (e.code == '42501') {
      return context.l10n.createTripErrorNoPermission;
    }
    if (e.code == '23503') {
      return context.l10n.createTripErrorNotRegisteredAsTourist;
    }
    return context.l10n.createTripErrorSaveGeneric;
  }

  /// Escenario 10 de HU-05: confirmar antes de descartar el formulario.
  Future<void> _handleCancel() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.createTripCancelDialogTitle),
        content: Text(context.l10n.createTripCancelDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.createTripCancelDialogNoButton)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.createTripCancelDialogConfirmButton),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    _bannerTimer?.cancel();
    setState(() => _banner = message);
    _bannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _banner = null);
    });
  }

  double _parsedOrZero(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  /// `_maxBudgetController` muestra el monto con puntos de miles (p.ej.
  /// "5.000.000") para que se vea como plata — a diferencia de los
  /// demás campos de dinero del wizard, que sí admiten decimales y por
  /// tanto usan el punto como separador decimal. Este getter es el
  /// único lugar donde se debe leer su valor numérico real.
  double get _maxBudget =>
      double.tryParse(_maxBudgetController.text.replaceAll('.', '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    // `Enter`/`NumpadEnter` actúan como el botón "Continuar →"/"Crear
    // viaje" de la esquina, sin importar qué campo del wizard tenga el
    // foco — comportamiento normal de un formulario al darle Enter.
    // `_goNext` ya ignora la llamada mientras `_isLoading`.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _goNext,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _goNext,
      },
      child: Stack(
        children: [
          widget.asDialog ? _buildDialog(context) : _buildMobileScaffold(context),
          if (_banner != null)
            Positioned(
              top: 24,
              left: 24,
              right: 24,
              child: SafeArea(
                bottom: false,
                child: Center(child: _ErrorBanner(message: _banner!)),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Escritorio / tablet: diálogo de dos columnas ───

  Widget _buildDialog(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _isLoading ? null : _handleCancel,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: ColoredBox(color: AppColors.ink.withValues(alpha: 0.55)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880, maxHeight: 680),
              child: GestureDetector(
                onTap: () {}, // Absorbe el tap para no cerrar al tocar dentro.
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.paper, boxShadow: AppShadow.raised),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 260, child: _buildLeftColumn()),
                          Expanded(child: _buildRightColumn()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftColumn() {
    final title = _stepTitle(context, _step);
    final stepNames = _stepNames(context);
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.createTripStepIndicator(_step + 1, _stepCount),
            style: AppText.label(10, color: AppColors.textOnInk),
          ),
          const SizedBox(height: 20),
          // Tabla de movimiento del README: título de paso con fade + y
          // 12→0 cada vez que cambia — la `key` distinta por paso hace
          // que `TweenAnimationBuilder` se remonte y reinicie el tween.
          TweenAnimationBuilder<double>(
            key: ValueKey(_step),
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.step,
            curve: AppMotion.enter,
            // `easeOutBack` se pasa de 1.0 antes de asentar — bien para
            // el desplazamiento, pero `Opacity` exige 0..1 y revienta
            // con el overshoot. Se recorta solo para la opacidad.
            builder: (context, t, child) => Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - t)),
                child: child,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.$1, style: AppText.display(34, color: Colors.white)),
                Text(title.$2, style: AppText.displayItalic(34)),
              ],
            ),
          ),
          const SizedBox(height: 26),
          StepProgress(step: _step, total: _stepCount),
          const Spacer(),
          for (var i = 0; i < stepNames.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MouseRegion(
                cursor: i <= _step ? SystemMouseCursors.click : MouseCursor.defer,
                child: GestureDetector(
                  onTap: () => _goToStep(i),
                  child: Text(
                    stepNames[i],
                    style: AppText.ui(
                      14,
                      weight: i == _step ? FontWeight.w700 : FontWeight.w400,
                      color: i == _step ? AppColors.paper : AppColors.textOnInk,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleCancel,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paperDeep,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            child: _buildStepContent(),
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_step > 0)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _isLoading ? null : _goBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(context.l10n.createTripBackButton, style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            const SizedBox(),
          Row(
            children: [
              if (_step < _stepCount - 1) ...[
                Text(
                  context.l10n.createTripNextStepLabel(_stepNames(context)[_step + 1]),
                  style: AppText.label(10),
                ),
                const SizedBox(width: 16),
              ],
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _goNext,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_step < _stepCount - 1 ? context.l10n.createTripContinueButton : context.l10n.createTripCreateButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Móvil: pantalla completa con CTA fija ───

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : (_step > 0 ? _goBack : _handleCancel),
        ),
        title: Text(
          context.l10n.createTripStepIndicator(_step + 1, _stepCount),
          style: AppText.label(11, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_stepTitle(context, _step).$1, style: AppText.display(30)),
                  Text(_stepTitle(context, _step).$2, style: AppText.displayItalic(30)),
                  const SizedBox(height: 16),
                  StepProgress(step: _step, total: _stepCount),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepContent(),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.nav),
                boxShadow: AppShadow.raised,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _step < _stepCount - 1 ? context.l10n.createTripNextLabel : context.l10n.createTripDoneLabel,
                          style: AppText.label(10),
                        ),
                        Text(
                          _step < _stepCount - 1 ? _stepNames(context)[_step + 1] : context.l10n.createTripCreateButton,
                          style: AppText.ui(15, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _goNext,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_step < _stepCount - 1 ? context.l10n.createTripContinueButton : context.l10n.createTripCreateButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contenido de cada paso (compartido entre diálogo y móvil) ───

  Widget _buildStepContent() {
    return switch (_step) {
      0 => _buildStep0(),
      1 => _buildStep1(),
      _ => _buildStep2(),
    };
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: context.l10n.createTripNameLabel,
                controller: _nameController,
                hint: context.l10n.createTripNameHint,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledField(
                label: context.l10n.createTripDestinationLabel,
                controller: _destinationController,
                hint: context.l10n.createTripDestinationHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _dateBox(label: context.l10n.createTripStartDateLabel, controller: _startDateController, onTap: _selectStartDate)),
            const SizedBox(width: 10),
            Expanded(child: _dateBox(label: context.l10n.createTripEndDateLabel, controller: _endDateController, onTap: _selectEndDate)),
            const SizedBox(width: 10),
            Expanded(child: _personsBox()),
          ],
        ),
        if (_tripDurationInDays != null) ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.createTripDurationLabel(_tripDurationInDays!),
            style: AppText.ui(12, color: AppColors.inkSoft),
          ),
        ],
        const SizedBox(height: 26),
        Text(context.l10n.createTripTypeLabel, style: AppText.label(10)),
        const SizedBox(height: 10),
        FilterChipsRow(
          items: _tripTypes,
          selected: _tripTypes.indexOf(_tripType),
          onSelect: (i) => setState(() => _tripType = _tripTypes[i]),
        ),
        const SizedBox(height: 26),
        _buildBudgetSlider(),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.createTripLodgingTypeLabel, style: AppText.label(10)),
        const SizedBox(height: 10),
        FilterChipsRow(
          items: _lodgingTypes,
          selected: _lodgingTypes.indexOf(_lodgingType),
          onSelect: (i) => setState(() => _lodgingType = _lodgingTypes[i]),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: context.l10n.createTripLodgingCostLabel,
                controller: _lodgingCostController,
                hint: context.l10n.createTripLodgingCostHint,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledField(
                label: context.l10n.createTripAdvancePaymentLabel,
                controller: _advancePaymentController,
                hint: context.l10n.createTripAdvancePaymentHint,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(context.l10n.createTripIncludedServicesLabel, style: AppText.label(10)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Los labels se traducen libremente — el valor guardado en
            // `includedServices` (ver `_saveTrip`) sigue siendo el
            // string fijo en español que compara `trip_repository.dart`.
            _toggleChip(context.l10n.createTripServiceBreakfast, _includeBreakfast, (v) => setState(() => _includeBreakfast = v)),
            _toggleChip(context.l10n.createTripServiceLunch, _includeLunch, (v) => setState(() => _includeLunch = v)),
            _toggleChip(context.l10n.createTripServiceDinner, _includeDinner, (v) => setState(() => _includeDinner = v)),
            _toggleChip(context.l10n.createTripServiceTransfer, _includeTransfer, (v) => setState(() => _includeTransfer = v)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.createTripStartTransportLabel, style: AppText.label(10)),
        const SizedBox(height: 10),
        FilterChipsRow(
          items: _transportTypes,
          selected: _transportTypes.indexOf(_startTransport),
          onSelect: (i) => setState(() => _startTransport = _transportTypes[i]),
        ),
        const SizedBox(height: 20),
        Text(context.l10n.createTripDuringTransportLabel, style: AppText.label(10)),
        const SizedBox(height: 10),
        FilterChipsRow(
          items: _transportTypes,
          selected: _transportTypes.indexOf(_duringTransport),
          onSelect: (i) => setState(() => _duringTransport = _transportTypes[i]),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.createTripAdditionalExpensesLabel, style: AppText.label(10)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _addCategoryRow,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 4),
                    Text(context.l10n.createTripAddButton, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final row in _categoryRows) ...[
          _buildCategoryRow(row),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        _labeledField(
          label: context.l10n.createTripEmergencyMoneyLabel,
          controller: _emergencyMoneyController,
          hint: context.l10n.createTripEmergencyMoneyHint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _moneyFormatters,
          triggerRebuild: true,
        ),
        const SizedBox(height: 26),
        _buildBudgetSummaryCard(),
      ],
    );
  }

  // ─── Campos compartidos ───

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool triggerRebuild = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: triggerRebuild ? (_) => setState(() {}) : null,
          style: AppText.ui(15, weight: FontWeight.w600),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _dateBox({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.paperDeep,
            borderRadius: BorderRadius.circular(AppRadius.dateField),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label(10)),
              const SizedBox(height: 4),
              Text(
                controller.text.isEmpty ? '—' : controller.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _personsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: AppColors.paperDeep, borderRadius: BorderRadius.circular(AppRadius.dateField)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.createTripPersonsLabel, style: AppText.label(10)),
          const SizedBox(height: 4),
          TextField(
            controller: _personsController,
            keyboardType: TextInputType.number,
            inputFormatters: _digitsOnlyFormatters,
            onChanged: (_) => setState(() {}),
            style: AppText.display(18),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
              hintText: '1',
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool active, ValueChanged<bool> onChanged) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!active),
        child: AnimatedContainer(
          duration: AppMotion.chip,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : Colors.transparent,
            border: Border.all(color: active ? AppColors.ink : AppColors.hair),
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          child: Text(
            label,
            style: AppText.ui(
              13,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? AppColors.mint : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSlider() {
    final raw = _maxBudget;
    // El thumb siempre queda dentro del rango del slider aunque lo
    // tecleado se salga de él (p.ej. 15.000.000: la barra se ve llena,
    // pero el monto guardado sigue siendo el que escribiste).
    final sliderValue = (raw <= 0 ? 500000.0 : raw).clamp(500000.0, 10000000.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.createTripMaxBudgetLabel, style: AppText.label(10)),
        const SizedBox(height: 6),
        // Editable: escribir un monto aquí mueve la barra de abajo sin
        // necesidad de arrastrarla — y arrastrarla sigue actualizando
        // este número, comparten el mismo controller. Se formatea con
        // puntos de miles al vuelo (`_ThousandsInputFormatter`) para
        // que se lea como plata ("5.000.000"), no como un id.
        TextField(
          controller: _maxBudgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [_ThousandsInputFormatter()],
          style: AppText.display(32, color: AppColors.inkSoft),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixText: '\$ ',
            prefixStyle: AppText.display(32, color: AppColors.inkSoft),
            hintText: '0',
            hintStyle: AppText.display(32, color: AppColors.hair),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.hair,
            trackHeight: 6,
            thumbColor: AppColors.mint,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: AppColors.mint.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: sliderValue,
            min: 500000,
            max: 10000000,
            divisions: 19,
            onChanged: (v) => setState(
              () => _maxBudgetController.text = _groupThousands(v.round().toString()),
            ),
          ),
        ),
      ],
    );
  }

  /// Una fila de categoría de presupuesto personalizable: nombre libre
  /// + monto + botón para quitarla. Reemplaza los campos fijos de
  /// "Tours"/"Restaurantes"/etc. que no se podían editar ni borrar.
  Widget _buildCategoryRow(CategoryFieldRow row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 5, child: _labeledField(label: context.l10n.createTripCategoryLabel, controller: row.nombreController, hint: context.l10n.createTripCategoryHint)),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _labeledField(
            label: context.l10n.createTripAmountLabel,
            controller: row.montoController,
            hint: context.l10n.createTripCategoryAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _moneyFormatters,
            triggerRebuild: true,
          ),
        ),
        IconButton(
          onPressed: _categoryRows.length > 1 ? () => _removeCategoryRow(row) : null,
          icon: const Icon(Icons.delete_outline, size: 20),
          color: AppColors.error,
          tooltip: context.l10n.createTripRemoveCategoryTooltip,
        ),
      ],
    );
  }

  /// Resumen de presupuesto en vivo: se recalcula con cada cambio en los
  /// campos de dinero gracias a `triggerRebuild: true` en `_labeledField`.
  Widget _buildBudgetSummaryCard() {
    final maxBudget = _maxBudget;
    final categoriesTotal = _categoryRows.fold(0.0, (sum, row) => sum + row.monto);
    final estimatedSpent = _parsedOrZero(_advancePaymentController) +
        _parsedOrZero(_lodgingCostController) +
        categoriesTotal +
        _parsedOrZero(_emergencyMoneyController);

    if (maxBudget <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Text(
          context.l10n.createTripBudgetSummaryPlaceholder,
          style: AppText.ui(12, color: AppColors.textMuted),
        ),
      );
    }

    final remaining = maxBudget - estimatedSpent;
    final percentage = (estimatedSpent / maxBudget).clamp(0.0, 999.0);
    final overBudget = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.createTripBudgetSummaryTitle, style: AppText.ui(14, weight: FontWeight.w700)),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: AppText.ui(14, weight: FontWeight.w700, color: overBudget ? AppColors.error : AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BudgetBar(progress: percentage, fill: overBudget ? AppColors.error : AppColors.inkSoft),
          const SizedBox(height: 12),
          _summaryRow(context.l10n.createTripEstimatedLabel, context.formatMoney(estimatedSpent)),
          const SizedBox(height: 4),
          _summaryRow(
            overBudget ? context.l10n.createTripOverBudgetLabel : context.l10n.createTripAvailableLabel,
            context.formatMoney(remaining.abs()),
            color: overBudget ? AppColors.error : AppColors.inkSoft,
          ),
          if (overBudget) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.createTripOverBudgetWarning,
                    style: AppText.ui(11, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
          if (!overBudget && remaining > 0) ...[
            const Divider(height: 24, color: AppColors.line),
            _buildDailyBudgetSection(remaining),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.ui(12, color: AppColors.textMuted)),
        Text(value, style: AppText.ui(13, weight: FontWeight.w700, color: color ?? AppColors.ink)),
      ],
    );
  }

  /// Presupuesto disponible por día y por persona (mejora "gestor de
  /// presupuesto"): antes solo se veía el total estimado vs. máximo, sin
  /// ayudar a decidir cuánto gastar día a día durante el viaje.
  Widget _buildDailyBudgetSection(double availableBudget) {
    final start = parseDdMmYyyy(_startDateController.text);
    final end = parseDdMmYyyy(_endDateController.text);
    final persons = int.tryParse(_personsController.text.trim()) ?? 1;
    if (start == null || end == null) {
      return Text(
        context.l10n.createTripEnterDatesForDailyBudget,
        style: AppText.ui(11, color: AppColors.textMuted),
      );
    }

    final breakdown = calculateBudgetBreakdown(maxBudget: availableBudget, start: start, end: end, persons: persons);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.createTripRemainingBudgetSplitLabel, style: AppText.ui(12, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _dailyChip(
                label: context.l10n.createTripPerDayLabel(breakdown.days),
                value: context.formatMoney(breakdown.perDay),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dailyChip(
                label: context.l10n.createTripPerPersonLabel(persons),
                value: context.formatMoney(breakdown.perPerson),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _dailyChip(
          label: context.l10n.createTripPerPersonPerDayLabel,
          value: context.formatMoney(breakdown.perPersonPerDay),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _dailyChip({required String label, required String value, bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.paperDeep, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.label(9)),
          Text(value, style: AppText.ui(13, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Inserta el punto de miles cada 3 dígitos — mismo criterio que
/// `formatCOP`, sin el signo `$` (ese lo pone el `prefixText` del
/// campo).
String _groupThousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formatea el campo de presupuesto máximo con puntos de miles mientras
/// se escribe. El cursor siempre queda al final del texto — es lo
/// esperado para un monto (se escribe de corrido, no se edita en medio)
/// y evita el cálculo de offset cuando insertar un punto desplaza los
/// dígitos que ya estaban.
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = _groupThousands(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Banner de error del wizard — pintado fuera del `BackdropFilter` (ver
/// `_CreateTripWizardState.build`), así que siempre se ve nítido encima
/// de todo, a diferencia de un `SnackBar` normal.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.raised,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: AppText.ui(13, weight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
