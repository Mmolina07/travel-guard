import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({Key? key}) : super(key: key);

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Valores seleccionados
  String? _selectedCategory;
  String _selectedStatus = 'Borrador';

  // Banderas
  bool _isFree = false;
  bool _hasNoEndDate = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Fiesta',
    'Tour',
    'Promoción',
    'Clase',
    'Evento',
    'Otro',
  ];

  final List<String> _statuses = [
    'Activa',
    'Pausada',
    'Borrador',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // ─── Selector de fecha ───
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
      helpText: 'Selecciona una fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // ─── Validación extra (además del Form) ───
  bool _validateActivity() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_startDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha de inicio de la actividad.'),
        ),
      );
      return false;
    }

    if (!_hasNoEndDate && _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona la fecha de finalización o marca "Sin fecha de fin".',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  // ─── Crear actividad ───
  void _handleCreateActivity() {
    if (!_validateActivity()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simula el envío al backend
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final Map<String, dynamic> activity = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory ?? 'Otro',
        'price': _isFree
            ? 0
            : double.tryParse(_priceController.text.trim()) ?? 0,
        'isFree': _isFree,
        'startDate': _startDateController.text,
        'endDate': _hasNoEndDate ? null : _endDateController.text,
        'hasNoEndDate': _hasNoEndDate,
        'status': _selectedStatus,
      };

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, activity);
    });
  }

  // ─── Campo de texto reutilizable ───
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.ink),
        filled: true,
        fillColor: AppColors.paperDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.hair),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.ink,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Crear actividad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(decoration: BoxDecoration(color: AppColors.ink)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva actividad',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa la información para publicar una actividad para los turistas.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Nombre
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre de la actividad',
                  hint: 'Ej. Happy Hour',
                  icon: Icons.local_activity_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre de la actividad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Descripción
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Explica de qué trata la actividad',
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    if (value.trim().length < 10) {
                      return 'La descripción debe ser más detallada';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Tipo o categoría',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: AppColors.ink,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.hair),
                    ),
                  ),
                  hint: const Text('Selecciona una categoría'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Precio
                _buildTextField(
                  controller: _priceController,
                  label: 'Precio',
                  hint: 'Ej. 25000',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  enabled: !_isFree,
                  validator: (value) {
                    if (_isFree) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el precio o marca "Gratis"';
                    }
                    final double? price = double.tryParse(value.trim());
                    if (price == null || price < 0) {
                      return 'Ingresa un precio válido';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Actividad gratuita'),
                  value: _isFree,
                  activeColor: AppColors.ink,
                  onChanged: (value) {
                    setState(() {
                      _isFree = value ?? false;
                      if (_isFree) _priceController.clear();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Fecha inicio
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: () => _selectDate(_startDateController),
                  decoration: InputDecoration(
                    labelText: 'Fecha de inicio',
                    hintText: 'Selecciona la fecha de inicio',
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.ink,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.ink,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.hair),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona la fecha de inicio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Fecha fin
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  enabled: !_hasNoEndDate,
                  onTap: () {
                    if (!_hasNoEndDate) {
                      _selectDate(_endDateController);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de finalización',
                    hintText: 'Selecciona la fecha de finalización',
                    prefixIcon: const Icon(
                      Icons.event_outlined,
                      color: AppColors.ink,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.ink,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.hair),
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sin fecha de fin'),
                  value: _hasNoEndDate,
                  activeColor: AppColors.ink,
                  onChanged: (value) {
                    setState(() {
                      _hasNoEndDate = value ?? false;
                      if (_hasNoEndDate) _endDateController.clear();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Estado
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado de la actividad',
                    prefixIcon: const Icon(
                      Icons.toggle_on_outlined,
                      color: AppColors.ink,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.hair),
                    ),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'Borrador';
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.ink),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Crear',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}