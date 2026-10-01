import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/step_progress.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({Key? key}) : super(key: key);

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  static const _stepCount = 3;
  static const _stepTitles = [
    ('¿Cuál es', 'tu actividad?'),
    ('¿Cuándo y', 'cuánto?'),
    ('Resumen y', 'publicar'),
  ];
  static const _stepNames = ['Información', 'Fecha y precio', 'Detalles'];

  int _step = 0;
  bool _isLoading = false;

  // Controladores
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  // Valores
  String? _selectedCategory;
  String _selectedStatus = 'Activa';
  bool _isFree = false;
  bool _hasNoEndDate = false;

  final List<String> _categories = [
    'Fiesta',
    'Tour',
    'Promoción',
    'Clase',
    'Evento',
    'Otro',
  ];

  final List<String> _statuses = ['Activa', 'Pausada', 'Borrador'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String? _validateStep0() {
    if (_nameController.text.trim().isEmpty) {
      return 'Ingresa el nombre de la actividad';
    }
    if (_descriptionController.text.trim().isEmpty) {
      return 'Ingresa una descripción';
    }
    if (_descriptionController.text.trim().length < 10) {
      return 'La descripción debe ser más detallada';
    }
    if (_selectedCategory == null) {
      return 'Selecciona una categoría';
    }
    return null;
  }

  String? _validateStep1() {
    if (_startDateController.text.isEmpty) {
      return 'Selecciona la fecha de inicio';
    }
    if (!_hasNoEndDate && _endDateController.text.isEmpty) {
      return 'Selecciona fecha de fin o marca "Sin fecha de fin"';
    }
    if (!_isFree) {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price < 0) {
        return 'Ingresa un precio válido o marca "Gratis"';
      }
    }
    return null;
  }

  void _goNext() {
    if (_isLoading) return;

    if (_step == 0) {
      final error = _validateStep0();
      if (error != null) {
        _showSnack(error);
        return;
      }
    } else if (_step == 1) {
      final error = _validateStep1();
      if (error != null) {
        _showSnack(error);
        return;
      }
    }

    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _handleCreateActivity();
    }
  }

  void _goBack() {
    if (_step > 0) setState(() => _step--);
  }

  void _goToStep(int index) {
    if (index <= _step) setState(() => _step = index);
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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

  void _handleCreateActivity() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final activity = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory ?? 'Otro',
      'price': _isFree ? 0 : double.tryParse(_priceController.text.trim()) ?? 0,
      'isFree': _isFree,
      'startDate': _startDateController.text,
      'endDate': _hasNoEndDate ? null : _endDateController.text,
      'hasNoEndDate': _hasNoEndDate,
      'status': _selectedStatus,
    };

    setState(() => _isLoading = false);
    Navigator.pop(context, activity);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileScaffold();
        }
        return _buildDialogDesktop();
      },
    );
  }

  // ═══ DESKTOP ═══
  Widget _buildDialogDesktop() {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 680),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    boxShadow: AppShadow.raised,
                  ),
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
    );
  }

  Widget _buildLeftColumn() {
    final title = _stepTitles[_step];
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASO ${_step + 1} DE $_stepCount',
            style: AppText.label(
              10,
              weight: FontWeight.w600,
              color: AppColors.textOnInk,
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            key: ValueKey(_step),
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.step,
            curve: AppMotion.enter,
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
          for (var i = 0; i < _stepNames.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _goToStep(i),
                child: Text(
                  _stepNames[i],
                  style: AppText.ui(
                    14,
                    weight: i == _step ? FontWeight.w700 : FontWeight.w400,
                    color: i == _step ? AppColors.paper : AppColors.textOnInk,
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
              GestureDetector(
                onTap: _isLoading ? null : () => Navigator.pop(context),
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
            GestureDetector(
              onTap: _isLoading ? null : _goBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('Atrás', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
                ],
              ),
            )
          else
            const SizedBox(),
          Row(
            children: [
              if (_step < _stepCount - 1) ...[
                Text(
                  'SIGUIENTE · ${_stepNames[_step + 1]}',
                  style: AppText.label(
                    10,
                    weight: FontWeight.w600,
                  ),
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
                      : Text(_step < _stepCount - 1 ? 'Continuar →' : 'Crear actividad'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══ MÓVIL ═══
  Widget _buildMobileScaffold() {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : (_step > 0 ? _goBack : () => Navigator.pop(context)),
        ),
        title: Text(
          'PASO ${_step + 1} DE $_stepCount',
          style: AppText.label(
            11,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
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
                  Text(_stepTitles[_step].$1, style: AppText.display(30)),
                  Text(_stepTitles[_step].$2, style: AppText.displayItalic(30)),
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
                          _step < _stepCount - 1 ? 'SIGUIENTE' : 'LISTO',
                          style: AppText.label(
                            10,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _step < _stepCount - 1 ? _stepNames[_step + 1] : 'Crear actividad',
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
                        : Text(_step < _stepCount - 1 ? 'Continuar →' : 'Crear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ CONTENIDO POR PASO ═══
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
        Text('Nombre', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: 'Ej. Happy Hour'),
        ),
        const SizedBox(height: 24),
        Text('Descripción', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(hintText: 'Explica de qué trata la actividad'),
        ),
        const SizedBox(height: 24),
        Text(
          'CATEGORÍA',
          style: AppText.label(
            10,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: const Text('Selecciona una categoría'),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.paperDeep,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fecha de inicio', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _startDateController,
          readOnly: true,
          onTap: () => _selectDate(_startDateController),
          decoration: InputDecoration(
            hintText: 'Selecciona fecha',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 20),
        Text('Fecha de fin', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _endDateController,
          readOnly: true,
          enabled: !_hasNoEndDate,
          onTap: !_hasNoEndDate ? () => _selectDate(_endDateController) : null,
          decoration: InputDecoration(
            hintText: 'Selecciona fecha',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sin fecha de fin'),
          value: _hasNoEndDate,
          activeColor: AppColors.ink,
          onChanged: (v) => setState(() {
            _hasNoEndDate = v ?? false;
            if (_hasNoEndDate) _endDateController.clear();
          }),
        ),
        const SizedBox(height: 20),
        Text('Precio', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          enabled: !_isFree,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Ej. 25000'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Actividad gratuita'),
          value: _isFree,
          activeColor: AppColors.ink,
          onChanged: (v) => setState(() {
            _isFree = v ?? false;
            if (_isFree) _priceController.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final price = _isFree ? 0.0 : double.tryParse(_priceController.text.trim()) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen de la actividad', style: AppText.display(22)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card + 2),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Nombre', _nameController.text),
              const SizedBox(height: 12),
              _summaryRow('Categoría', _selectedCategory ?? '—'),
              const SizedBox(height: 12),
              _summaryRow('Inicio', _startDateController.text),
              const SizedBox(height: 12),
              _summaryRow('Fin', _hasNoEndDate ? 'Sin fecha' : _endDateController.text),
              const SizedBox(height: 12),
              _summaryRow(
                'Precio',
                _isFree ? 'Gratis' : '\$${price.toStringAsFixed(0)}',
                color: AppColors.inkSoft,
              ),
              const Divider(height: 24, color: AppColors.line),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  filled: true,
                  fillColor: AppColors.paperDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v ?? 'Activa'),
              ),
            ],
          ),
        ),
      ],
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
}