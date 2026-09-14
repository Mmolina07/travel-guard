import 'package:flutter/material.dart';
import '../../presentation/pages/trip_model.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip trip;
  final List<Expense> _extraExpenses = [];

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
  }

  double get _extraExpensesTotal {
  return _extraExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final double totalSpent = trip.getTotalSpent() + _extraExpensesTotal;
    final double remaining = trip.maxBudget - totalSpent;
    final double percentage = trip.maxBudget > 0
      ? (totalSpent / trip.maxBudget) * 100
      : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A5F7A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header azul
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A5F7A),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trip.destination,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${trip.startDate} - ${trip.endDate}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECCIÓN 1: INFORMACIÓN BÁSICA
                  _buildSectionTitle('Información del Viaje'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Destino', trip.destination),
                  _buildInfoRow('Tipo de Viaje', trip.tripType),
                  _buildInfoRow('Número de Personas', '${trip.persons}'),
                  _buildInfoRow('Fechas', '${trip.startDate} - ${trip.endDate}'),
                  const SizedBox(height: 24),

                  // SECCIÓN 2: HOSPEDAJE
                  _buildSectionTitle('Hospedaje'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tipo de Hospedaje', trip.lodgingType),
                  _buildInfoRow(
                    'Costo Hospedaje',
                    '\$${trip.lodgingCost.toStringAsFixed(0)}',
                    isAmount: true,
                  ),
                  if (trip.includedServices.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSectionSubtitle('Servicios Incluidos'),
                    const SizedBox(height: 8),
                    ...trip.includedServices.map(
                      (service) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outlined,
                              color: Color(0xFF2D8659),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              service,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // SECCIÓN 3: TRANSPORTE
                  _buildSectionTitle('Transporte'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Transporte Inicio', trip.startTransport),
                  _buildInfoRow('Transporte Durante', trip.duringTransport),
                  const SizedBox(height: 24),

                  // SECCIÓN 4: GASTOS ADICIONALES
                  _buildSectionTitle('Gastos Adicionales'),
                  const SizedBox(height: 12),
                  if (trip.tours > 0)
                    _buildInfoRow(
                      'Tours con Guía',
                      '\$${trip.tours.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                  if (trip.restaurants > 0)
                    _buildInfoRow(
                      'Restaurantes',
                      '\$${trip.restaurants.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                  if (trip.discotheque > 0)
                    _buildInfoRow(
                      'Discotecas',
                      '\$${trip.discotheque.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                  if (trip.souvenirs > 0)
                    _buildInfoRow(
                      'Souvenirs',
                      '\$${trip.souvenirs.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                  if (trip.paidActivities > 0)
                    _buildInfoRow(
                      'Actividades Pagas',
                      '\$${trip.paidActivities.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                  if (trip.emergencyMoney > 0)
                    _buildInfoRow(
                      'Dinero Emergencias',
                      '\$${trip.emergencyMoney.toStringAsFixed(0)}',
                      isAmount: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleAddExpense,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar gasto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A5F7A),
                          side: const BorderSide(color: Color(0xFF1A5F7A)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    if (_extraExpenses.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionSubtitle('Gastos Agregados'),
                      const SizedBox(height: 8),
                      ..._extraExpenses.map((expense) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Color(0xFF1A5F7A),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      expense.category,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    if (expense.description.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '- ${expense.description}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '\$${expense.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A5F7A),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  const SizedBox(height: 24),

                  // SECCIÓN 5: RESUMEN PRESUPUESTARIO
                  _buildSectionTitle('Resumen Presupuestario'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD7E8EF),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildBudgetRow(
                          'Presupuesto Máximo',
                          '\$${trip.maxBudget.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 12),
                        _buildBudgetRow(
                          'Total Gastado',
                          '\$${totalSpent.toStringAsFixed(0)}',   // ← variable
                          isSpent: true,
                        ),
                        const SizedBox(height: 12),
                        _buildBudgetRow(
                          'Presupuesto Disponible',
                          '\$${remaining.toStringAsFixed(0)}',    // ← variable
                          isAvailable: true,
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0.0, 1.0),   // ← variable
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE0EEF7),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              remaining > 0                                // ← variable
                                  ? const Color(0xFF2D8659)
                                  : const Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${percentage.toStringAsFixed(1)}% del presupuesto utilizado',   // ← variable
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECCIÓN 6: DESGLOSE DETALLADO
                  _buildSectionTitle('Desglose de Gastos'),
                  const SizedBox(height: 16),
                  _buildExpenseBreakdown(),
                  const SizedBox(height: 24),

                  // BOTONES DE ACCIÓN
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Función en desarrollo'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A5F7A),
                            side: const BorderSide(
                              color: Color(0xFF1A5F7A),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showDeleteDialog();
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
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

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAmount ? const Color(0xFF1A5F7A) : const Color(0xFF1A5F7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(
    String label,
    String value, {
    bool isSpent = false,
    bool isAvailable = false,
  }) {
    Color textColor = const Color(0xFF757575);
    if (isSpent) textColor = const Color(0xFFD32F2F);
    if (isAvailable) textColor = const Color(0xFF2D8659);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown() {
  // Agrupamos los gastos extra por categoría
  final Map<String, double> extrasByCategory = {};
  for (final expense in _extraExpenses) {
    extrasByCategory[expense.category] =
        (extrasByCategory[expense.category] ?? 0) + expense.amount;
  }

  // Base fija del viaje + extras agrupados
  final expenses = <(String, double)>[
    ('Pagos Anticipados', trip.advancePayment),
    ('Hospedaje', trip.lodgingCost),
    ('Tours', trip.tours),
    ('Restaurantes', trip.restaurants),
    ('Discotecas', trip.discotheque),
    ('Souvenirs', trip.souvenirs),
    ('Actividades', trip.paidActivities),
    ('Emergencias', trip.emergencyMoney),
    ...extrasByCategory.entries.map((e) => (e.key, e.value)),
  ];

  // Filtramos los que son 0 para no mostrar filas vacías
  final filtered = expenses.where((e) => e.$2 > 0).toList();

  if (filtered.isEmpty) {
    return const Text(
      'No hay gastos registrados aún.',
      style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
    );
  }

  return Column(
    children: filtered.map((expense) {
      final percentage = trip.maxBudget > 0
          ? (expense.$2 / trip.maxBudget) * 100
          : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expense.$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
                Text(
                  '\$${expense.$2.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFE0EEF7),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1A5F7A),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar viaje',
            style: TextStyle(
              color: Color(0xFF1A5F7A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar el viaje "${trip.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF1A5F7A),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Viaje eliminado'),
                    backgroundColor: Color(0xFFF44336),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showAddExpenseSheet() async {
  // Controladores y estado local del sheet
  String selectedCategory = 'Comida';
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Lista de categorías alineadas con las que ya usas en el viaje
  const categories = [
    'Comida',
    'Transporte',
    'Hospedaje',
    'Tours',
    'Entretenimiento',
    'Compras',
    'Emergencias',
    'Otro',
  ];

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setStateSheet) {
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
                // Handle superior
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

                // Título
                const Text(
                  'Agregar gasto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra un nuevo gasto para este viaje',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Categoría
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF1A5F7A),
                    ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F7A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateSheet(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Monto
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    hintText: 'Ej. 50000',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF1A5F7A),
                    ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F7A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción (opcional)
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Ej. Cena en el centro',
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF1A5F7A),
                    ),
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
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F7A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A5F7A),
                          side: const BorderSide(color: Color(0xFF1A5F7A)),
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
                        onPressed: () {
                          final amount =
                              double.tryParse(amountController.text.trim());

                          // Validación
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un monto válido'),
                                backgroundColor: Color(0xFFD32F2F),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(sheetContext, {
                            'category': selectedCategory,
                            'amount': amount,
                            'description':
                                descriptionController.text.trim(),
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5F7A),
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
        },
      );
    },
  );
}
  Future<void> _handleAddExpense() async {
  final expense = await _showAddExpenseSheet();

  if (!mounted) return;

  if (expense != null) {
    setState(() {
      _extraExpenses.add(
        Expense(
          category: expense['category'] as String,
          amount: expense['amount'] as double,
          description: expense['description'] as String? ?? '',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gasto de \$${(expense['amount'] as double).toStringAsFixed(0)} '
          'en ${expense['category']} agregado',
        ),
        backgroundColor: const Color(0xFF1A5F7A),
      ),
    );
  }
}
}
