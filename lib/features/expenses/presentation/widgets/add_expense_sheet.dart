import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/categoria_gasto_model.dart';

/// Resultado de [AddExpenseSheet]: datos ya validados, listos para
/// persistir en `gastos` (HU-13).
class NewExpenseData {
  final CategoriaGasto categoria;
  final double monto;
  final DateTime fecha;
  final String? descripcion;

  const NewExpenseData({
    required this.categoria,
    required this.monto,
    required this.fecha,
    this.descripcion,
  });
}

/// Formulario para registrar un gasto manual (HU-13), con categorías
/// reales (traídas de `categorias_gasto`, no una lista fija) y fecha
/// seleccionable (por defecto hoy).
class AddExpenseSheet extends StatefulWidget {
  final List<CategoriaGasto> categorias;
  final DateTime tripStartDate;
  final DateTime tripEndDate;

  const AddExpenseSheet({
    super.key,
    required this.categorias,
    required this.tripStartDate,
    required this.tripEndDate,
  });

  static Future<NewExpenseData?> show(
    BuildContext context, {
    required List<CategoriaGasto> categorias,
    required DateTime tripStartDate,
    required DateTime tripEndDate,
  }) {
    return showModalBottomSheet<NewExpenseData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseSheet(
        categorias: categorias,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const Color _primary = Color(0xFF1A5F7A);

  late CategoriaGasto _selectedCategoria;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    _selectedCategoria = widget.categorias.first;
    final today = DateTime.now();
    // Si "hoy" cae fuera del rango del viaje (viaje pasado/futuro),
    // arranca en la fecha de inicio para que quede dentro del rango.
    _fecha = (today.isBefore(widget.tripStartDate) ||
            today.isAfter(widget.tripEndDate))
        ? widget.tripStartDate
        : today;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: widget.tripStartDate,
      lastDate: widget.tripEndDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  void _handleSubmit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      NewExpenseData(
        categoria: _selectedCategoria,
        monto: amount,
        fecha: _fecha,
        descripcion: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: const Color(0xFFF5FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7E8EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Agregar gasto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registra un nuevo gasto real de este viaje',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<CategoriaGasto>(
            initialValue: _selectedCategoria,
            decoration: _fieldDecoration(
              label: 'Categoría',
              icon: Icons.category_outlined,
            ),
            items: widget.categorias
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.nombre),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategoria = value);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _fieldDecoration(
              label: 'Monto',
              icon: Icons.attach_money,
              hint: 'Ej. 50000',
            ),
          ),
          const SizedBox(height: 16),

          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _fieldDecoration(
                label: 'Fecha del gasto',
                icon: Icons.calendar_today_outlined,
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _fieldDecoration(
              label: 'Descripción (opcional)',
              icon: Icons.description_outlined,
              hint: 'Ej. Cena en el centro',
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Agregar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
