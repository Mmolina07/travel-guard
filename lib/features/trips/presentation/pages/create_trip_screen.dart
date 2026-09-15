import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../../../core/utils/money_formatter.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../data/models/trip_budget_category.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../widgets/category_field_row.dart';
import '../pages/trip_model.dart';
import '../pages/trip_detail_screen.dart';
import '../../../../core/theme/app_theme.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
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
    final lastDate = firstDate.isAfter(_maxSelectableDate)
        ? firstDate
        : _maxSelectableDate;
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1A5F7A)),
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
      _showError('Primero selecciona la fecha de inicio');
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
      return 'Debe completar todos los campos obligatorios';
    }

    final persons = int.tryParse(_personsController.text.trim());
    if (persons == null || persons <= 0) {
      return 'Debe haber mínimo 1 persona';
    }

    final maxBudget = double.tryParse(_maxBudgetController.text.trim());
    if (maxBudget == null || maxBudget <= 0) {
      return 'El presupuesto debe ser mayor a 0';
    }

    final startDate = _parseDate(_startDateController.text);
    final endDate = _parseDate(_endDateController.text);
    if (startDate == null || endDate == null) {
      return 'Las fechas ingresadas no son válidas';
    }
    if (!endDate.isAfter(startDate)) {
      return 'La fecha de fin debe ser posterior a la fecha de inicio';
    }

    if (_lodgingCostController.text.trim().isNotEmpty) {
      final lodgingCost = double.tryParse(_lodgingCostController.text.trim());
      if (lodgingCost == null || lodgingCost <= 0) {
        return 'El costo debe ser mayor a 0';
      }
    }

    if (_emergencyMoneyController.text.trim().isNotEmpty) {
      final emergencyMoney = double.tryParse(
        _emergencyMoneyController.text.trim(),
      );
      if (emergencyMoney == null || emergencyMoney <= 0) {
        return 'El monto debe ser mayor a 0';
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
  bool _hasIncompleteOptionalFields() {
    final sinServiciosIncluidos =
        !_includeBreakfast &&
        !_includeLunch &&
        !_includeDinner &&
        !_includeTransfer;
    return _advancePaymentController.text.trim().isEmpty ||
        _lodgingCostController.text.trim().isEmpty ||
        sinServiciosIncluidos ||
        _categoryRows.any((row) => row.montoController.text.trim().isEmpty) ||
        _emergencyMoneyController.text.trim().isEmpty;
  }

  Future<bool?> _confirmPartialData() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datos incompletos'),
        content: const Text(
          'La estimación será menos precisa. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F7A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, crear viaje'),
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
      _showError('Debes iniciar sesión como turista para crear un viaje.');
      return;
    }

    final trip = Trip(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      persons: int.parse(_personsController.text.trim()),
      tripType: _tripType,
      maxBudget: double.parse(_maxBudgetController.text.trim()),
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
            TripBudgetCategory(
              nombre: row.nombreController.text.trim(),
              monto: row.monto,
            ),
      ],
      emergencyMoney: double.tryParse(_emergencyMoneyController.text) ?? 0,
      datosCompletos: datosCompletos,
    );

    try {
      final saved = await _tripRepository.createTrip(
        turistaId: turistaId,
        trip: trip,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Escenario 1 de HU-05: feedback de éxito con presupuesto total.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Viaje creado! Presupuesto total: ${formatCOP(saved.maxBudget)}',
          ),
          backgroundColor: AppColors.accentLight,
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
      _showError('No se pudo guardar el viaje. Intenta nuevamente.');
    }
  }

  /// Traduce errores comunes de Postgres/Supabase a un mensaje claro,
  /// y deja el detalle real en consola (`debugPrint`) para depurar.
  String _mapSaveTripError(PostgrestException e) {
    final detalle = '${e.message} ${e.details ?? ''}'.toLowerCase();
    if (e.code == '42P01' || detalle.contains('does not exist')) {
      return 'La base de datos no está actualizada para guardar el viaje '
          '(falta una columna o tabla). Revisa docs/db/hu05_viajes_costos.sql.';
    }
    if (e.code == '42501') {
      return 'No tienes permiso para guardar el viaje (revisa las '
          'políticas de seguridad de la tabla viajes en Supabase).';
    }
    if (e.code == '23503') {
      return 'Tu usuario no está registrado como turista todavía.';
    }
    return 'No se pudo guardar el viaje. Intenta nuevamente.';
  }

  /// Escenario 10 de HU-05: confirmar antes de descartar el formulario.
  Future<void> _handleCancel() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Se descartarán los datos ingresados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, descartar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5F7A),
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A5F7A), Color(0xFF0F4C5F)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isLoading ? null : _handleCancel,
        ),
        title: const Text(
          'Crear Viaje',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN 1: Información Básica
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Nombre del viaje',
                hint: 'Ej: Viaje a Cartagena',
                icon: Icons.trip_origin,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _destinationController,
                label: 'Destino',
                hint: 'Ej: Cartagena, Colombia',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _startDateController,
                      label: 'Fecha inicio',
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      controller: _endDateController,
                      label: 'Fecha fin',
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),
              if (_tripDurationInDays != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.event_available,
                      size: 16,
                      color: Color(0xFF4A90A4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Duración: $_tripDurationInDays '
                      '${_tripDurationInDays == 1 ? 'día' : 'días'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90A4),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              _buildTextField(
                controller: _personsController,
                label: 'Número de personas',
                hint: 'Ej: 4',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                inputFormatters: _digitsOnlyFormatters,
                triggerRebuild: true,
              ),
              const SizedBox(height: 32),

              // SECCIÓN 2: Tipo de Viaje
              _buildSectionTitle('Tipo de Viaje'),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Tipo de viaje',
                value: _tripType,
                items: ['Vacaciones', 'Trabajo', 'Ocio', 'Otro'],
                onChanged: (value) {
                  setState(() => _tripType = value);
                },
              ),
              const SizedBox(height: 32),

              // SECCIÓN 3: Presupuesto
              _buildSectionTitle('Presupuesto'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _maxBudgetController,
                label: 'Presupuesto máximo',
                hint: 'Ej: 5000000',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _advancePaymentController,
                label: 'Pagos anticipados',
                hint: 'Ej: 1500000',
                icon: Icons.credit_card,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
              const SizedBox(height: 32),

              // SECCIÓN 4: Hospedaje
              _buildSectionTitle('Hospedaje'),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Tipo de hospedaje',
                value: _lodgingType,
                items: ['Hotel', 'Hostel', 'Airbnb', 'Casa alquilada', 'Otro'],
                onChanged: (value) {
                  setState(() => _lodgingType = value);
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _lodgingCostController,
                label: 'Costo hospedaje',
                hint: 'Ej: 2000000',
                icon: Icons.hotel_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
              const SizedBox(height: 20),

              _buildSectionSubtitle('Servicios incluidos'),
              const SizedBox(height: 12),

              _buildCheckbox(
                value: _includeBreakfast,
                label: 'Desayuno',
                onChanged: (value) {
                  setState(() => _includeBreakfast = value ?? false);
                },
              ),
              _buildCheckbox(
                value: _includeLunch,
                label: 'Almuerzo',
                onChanged: (value) {
                  setState(() => _includeLunch = value ?? false);
                },
              ),
              _buildCheckbox(
                value: _includeDinner,
                label: 'Cena',
                onChanged: (value) {
                  setState(() => _includeDinner = value ?? false);
                },
              ),
              _buildCheckbox(
                value: _includeTransfer,
                label: 'Traslado',
                onChanged: (value) {
                  setState(() => _includeTransfer = value ?? false);
                },
              ),
              const SizedBox(height: 32),

              // SECCIÓN 5: Transporte
              _buildSectionTitle('Transporte'),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Transporte inicio',
                value: _startTransport,
                items: ['Carro', 'Transporte público', 'Uber', 'Vuelo'],
                onChanged: (value) {
                  setState(() => _startTransport = value);
                },
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Transporte durante viaje',
                value: _duringTransport,
                items: ['Carro', 'Transporte público', 'Uber', 'Vuelo'],
                onChanged: (value) {
                  setState(() => _duringTransport = value);
                },
              ),
              const SizedBox(height: 32),

              // SECCIÓN 6: Gastos Adicionales (categorías personalizables)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Gastos Adicionales'),
                  TextButton.icon(
                    onPressed: _addCategoryRow,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar categoría'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1A5F7A),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              for (final row in _categoryRows) ...[
                _buildCategoryRow(row),
                const SizedBox(height: 16),
              ],

              _buildTextField(
                controller: _emergencyMoneyController,
                label: 'Dinero emergencias',
                hint: 'Ej: 500000',
                icon: Icons.health_and_safety_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _moneyFormatters,
                triggerRebuild: true,
              ),
              const SizedBox(height: 24),

              _buildBudgetSummaryCard(),
              const SizedBox(height: 40),

              // Botón Crear Viaje
              // Botones: Cancelar + Crear Viaje
              Row(
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1A5F7A),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A5F7A),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Botón Crear Viaje
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5F7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Crear Viaje',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A5F7A),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A5F7A),
      ),
    );
  }

  double _parsedOrZero(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  /// Resumen de presupuesto en vivo: se recalcula con cada cambio en los
  /// campos de dinero gracias a `triggerRebuild: true` en `_buildTextField`.
  Widget _buildBudgetSummaryCard() {
    final maxBudget = _parsedOrZero(_maxBudgetController);
    final categoriesTotal = _categoryRows.fold(
      0.0,
      (sum, row) => sum + row.monto,
    );
    final estimatedSpent =
        _parsedOrZero(_advancePaymentController) +
        _parsedOrZero(_lodgingCostController) +
        categoriesTotal +
        _parsedOrZero(_emergencyMoneyController);

    if (maxBudget <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0EEF7)),
        ),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF4A90A4), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ingresa el presupuesto máximo para ver aquí el resumen.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final remaining = maxBudget - estimatedSpent;
    final percentage = (estimatedSpent / maxBudget * 100).clamp(0, 999);
    final overBudget = remaining < 0;
    final barColor = overBudget
        ? const Color(0xFFD32F2F)
        : percentage >= 90
        ? const Color(0xFFF9A825)
        : const Color(0xFF1A5F7A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0EEF7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen de presupuesto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A5F7A),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: const Color(0xFFE0EEF7),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 12),
          _buildBudgetRow(
            'Estimado (con lo ingresado)',
            formatCOP(estimatedSpent),
          ),
          const SizedBox(height: 4),
          _buildBudgetRow(
            overBudget ? 'Te excedes por' : 'Disponible',
            formatCOP(remaining.abs()),
            valueColor: overBudget
                ? const Color(0xFFD32F2F)
                : AppColors.accentLight,
          ),
          if (overBudget) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFD32F2F),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Lo estimado supera tu presupuesto máximo.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD32F2F)),
                  ),
                ),
              ],
            ),
          ],
          if (!overBudget && remaining > 0) ...[
            const Divider(height: 24),
            _buildDailyBudgetSection(remaining),
          ],
        ],
      ),
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
      return const Text(
        'Ingresa las fechas del viaje para ver el presupuesto por día.',
        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
      );
    }

    final breakdown = calculateBudgetBreakdown(
      maxBudget: availableBudget,
      start: start,
      end: end,
      persons: persons,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Presupuesto restante, repartido en:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A5F7A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDailyBudgetChip(
                icon: Icons.calendar_today,
                label: 'Por día (${breakdown.days} días)',
                value: formatCOP(breakdown.perDay),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDailyBudgetChip(
                icon: Icons.person_outline,
                label: 'Por persona ($persons)',
                value: formatCOP(breakdown.perPerson),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDailyBudgetChip(
          icon: Icons.groups_outlined,
          label: 'Por persona, por día',
          value: formatCOP(breakdown.perPersonPerDay),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDailyBudgetChip({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4A90A4)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1A5F7A),
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
        Expanded(
          flex: 5,
          child: _buildTextField(
            controller: row.nombreController,
            label: 'Categoría',
            hint: 'Ej: Transporte interno',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _buildTextField(
            controller: row.montoController,
            label: 'Monto',
            hint: 'Ej: 500000',
            icon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _moneyFormatters,
            triggerRebuild: true,
          ),
        ),
        IconButton(
          onPressed: _categoryRows.length > 1
              ? () => _removeCategoryRow(row)
              : null,
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFFD32F2F),
          tooltip: 'Quitar categoría',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool triggerRebuild = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A5F7A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: triggerRebuild ? (_) => setState(() {}) : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            prefixIconColor: const Color(0xFF1A5F7A),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A5F7A), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A5F7A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            prefixIconColor: const Color(0xFF1A5F7A),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A5F7A), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A5F7A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A90A4), width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A5F7A),
            side: const BorderSide(color: Color(0xFF4A90A4), width: 2),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
