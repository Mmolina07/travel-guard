import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';

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
      helpText: context.l10n.createActivityDatePickerHelpText,
      cancelText: context.l10n.createActivityDatePickerCancel,
      confirmText: context.l10n.createActivityDatePickerConfirm,
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
        SnackBar(
          content: Text(context.l10n.createActivityStartDateSnackbar),
        ),
      );
      return false;
    }

    if (!_hasNoEndDate && _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.createActivityEndDateSnackbar,
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
      style: AppText.ui(15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.ink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          context.l10n.createActivityAppBarTitle,
          style: AppText.ui(18, weight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.createActivityHeading,
                  style: AppText.display(26),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.createActivitySubtitle,
                  style: AppText.ui(14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Nombre
                _buildTextField(
                  controller: _nameController,
                  label: context.l10n.createActivityNameLabel,
                  hint: context.l10n.createActivityNameHint,
                  icon: Icons.local_activity_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.createActivityNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Descripción
                _buildTextField(
                  controller: _descriptionController,
                  label: context.l10n.createActivityDescriptionLabel,
                  hint: context.l10n.createActivityDescriptionHint,
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.createActivityDescriptionRequired;
                    }
                    if (value.trim().length < 10) {
                      return context.l10n.createActivityDescriptionTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createActivityCategoryLabel,
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: AppColors.ink,
                    ),
                  ),
                  hint: Text(context.l10n.createActivityCategoryHint),
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
                      return context.l10n.createActivityCategoryRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Precio
                _buildTextField(
                  controller: _priceController,
                  label: context.l10n.createActivityPriceLabel,
                  hint: context.l10n.createActivityPriceHint,
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  enabled: !_isFree,
                  validator: (value) {
                    if (_isFree) return null;
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.createActivityPriceRequired;
                    }
                    final double? price = double.tryParse(value.trim());
                    if (price == null || price < 0) {
                      return context.l10n.createActivityPriceInvalid;
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.createActivityFreeCheckbox),
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
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createActivityStartDateLabel,
                    hintText: context.l10n.createActivityStartDateHint,
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.ink,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.ink,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.createActivityStartDateRequired;
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
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createActivityEndDateLabel,
                    hintText: context.l10n.createActivityEndDateHint,
                    prefixIcon: const Icon(
                      Icons.event_outlined,
                      color: AppColors.ink,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.createActivityNoEndDateCheckbox),
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
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createActivityStatusLabel,
                    prefixIcon: const Icon(
                      Icons.toggle_on_outlined,
                      color: AppColors.ink,
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        child: Text(
                          context.l10n.createActivityCancelButton,
                          style: AppText.ui(15, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateActivity,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.mint,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.l10n.createActivityCreateButton,
                                style: AppText.ui(
                                  15,
                                  weight: FontWeight.w700,
                                  color: AppColors.paper,
                                ),
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