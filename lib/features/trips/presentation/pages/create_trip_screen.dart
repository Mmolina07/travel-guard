import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/trip_model.dart';

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
  late TextEditingController _toursController;
  late TextEditingController _restaurantsController;
  late TextEditingController _discothequeController;
  late TextEditingController _souvenirsController;
  late TextEditingController _paidActivitiesController;
  late TextEditingController _emergencyMoneyController;

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
    _toursController = TextEditingController();
    _restaurantsController = TextEditingController();
    _discothequeController = TextEditingController();
    _souvenirsController = TextEditingController();
    _paidActivitiesController = TextEditingController();
    _emergencyMoneyController = TextEditingController();
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
    _toursController.dispose();
    _restaurantsController.dispose();
    _discothequeController.dispose();
    _souvenirsController.dispose();
    _paidActivitiesController.dispose();
    _emergencyMoneyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A5F7A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _handleCreateTrip() {
  if (_validateForm()) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => _isLoading = false);

      final Trip trip = Trip(
        name: _nameController.text,
        destination: _destinationController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,

        persons: int.tryParse(_personsController.text) ?? 1,

        tripType: _tripType,

        maxBudget: double.tryParse(_maxBudgetController.text) ?? 0,

        advancePayment:
            double.tryParse(_advancePaymentController.text) ?? 0,

        lodgingType: _lodgingType,

        lodgingCost:
            double.tryParse(_lodgingCostController.text) ?? 0,

        includedServices: [
          if (_includeBreakfast) 'Desayuno',
          if (_includeLunch) 'Almuerzo',
          if (_includeDinner) 'Cena',
          if (_includeTransfer) 'Traslado',
        ],

        startTransport: _startTransport,

        duringTransport: _duringTransport,

        tours: double.tryParse(_toursController.text) ?? 0,

        restaurants:
            double.tryParse(_restaurantsController.text) ?? 0,

        discotheque:
            double.tryParse(_discothequeController.text) ?? 0,

        souvenirs:
            double.tryParse(_souvenirsController.text) ?? 0,

        paidActivities:
            double.tryParse(_paidActivitiesController.text) ?? 0,

        emergencyMoney:
            double.tryParse(_emergencyMoneyController.text) ?? 0,
      );

      Navigator.pop(context, trip);
    });
  }
}

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      _showError('Por favor ingresa el nombre del viaje');
      return false;
    }
    if (_destinationController.text.isEmpty) {
      _showError('Por favor ingresa el destino');
      return false;
    }
    if (_startDateController.text.isEmpty) {
      _showError('Por favor selecciona la fecha de inicio');
      return false;
    }
    if (_endDateController.text.isEmpty) {
      _showError('Por favor selecciona la fecha de fin');
      return false;
    }
    if (_personsController.text.isEmpty) {
      _showError('Por favor ingresa el número de personas');
      return false;
    }
    if (_maxBudgetController.text.isEmpty) {
      _showError('Por favor ingresa el presupuesto máximo');
      return false;
    }
    return true;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                      onTap: () => _selectDate(_startDateController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      controller: _endDateController,
                      label: 'Fecha fin',
                      onTap: () => _selectDate(_endDateController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _personsController,
                label: 'Número de personas',
                hint: 'Ej: 4',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _advancePaymentController,
                label: 'Pagos anticipados',
                hint: 'Ej: 1500000',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
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
                keyboardType: TextInputType.number,
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

              // SECCIÓN 6: Gastos Adicionales
              _buildSectionTitle('Gastos Adicionales'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _toursController,
                label: 'Tours con guía',
                hint: 'Ej: 500000',
                icon: Icons.tour,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _restaurantsController,
                label: 'Restaurantes',
                hint: 'Ej: 1500000',
                icon: Icons.restaurant_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _discothequeController,
                label: 'Discotecas',
                hint: 'Ej: 300000',
                icon: Icons.music_note_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _souvenirsController,
                label: 'Souvenirs',
                hint: 'Ej: 200000',
                icon: Icons.card_giftcard,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _paidActivitiesController,
                label: 'Actividades pagas',
                hint: 'Ej: 800000',
                icon: Icons.sports_basketball_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emergencyMoneyController,
                label: 'Dinero emergencias',
                hint: 'Ej: 500000',
                icon: Icons.health_and_safety_outlined,
                keyboardType: TextInputType.number,
              ),
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
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            prefixIconColor: const Color(0xFF1A5F7A),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90A4),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90A4),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A5F7A),
                width: 2,
              ),
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
          readOnly: false,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            prefixIconColor: const Color(0xFF1A5F7A),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90A4),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90A4),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A5F7A),
                width: 2,
              ),
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
            border: Border.all(
              color: const Color(0xFF4A90A4),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
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
            side: const BorderSide(
              color: Color(0xFF4A90A4),
              width: 2,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}