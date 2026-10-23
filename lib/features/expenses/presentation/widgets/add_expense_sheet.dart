import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/pressable.dart';
import '../../../trips/data/models/trip_collaborator.dart';
import '../../data/models/categoria_gasto_model.dart';
import '../../data/receipt_ocr_service.dart';
import '../../providers/notification_prefs_provider.dart';
import '../../utils/daily_budget_calculator.dart';
import '../../utils/receipt_parser.dart' show removeAccents;
import 'receipt_scanner.dart';

/// Resultado de [AddExpenseSheet]: datos ya validados, listos para
/// persistir en `gastos` (HU-13).
class NewExpenseData {
  final CategoriaGasto categoria;
  final double monto;
  final DateTime fecha; // incluye la hora elegida
  final String? descripcion;
  final String? establecimiento;
  final int? pagadoPorId;
  final bool pagadoConDineroViaje;

  const NewExpenseData({
    required this.categoria,
    required this.monto,
    required this.fecha,
    this.descripcion,
    this.establecimiento,
    this.pagadoPorId,
    this.pagadoConDineroViaje = true,
  });
}

/// Formulario para registrar un gasto manual (HU-13), con categorías
/// reales (traídas de `categorias_gasto`, no una lista fija) y fecha
/// seleccionable (por defecto hoy).
class AddExpenseSheet extends StatefulWidget {
  final List<CategoriaGasto> categorias;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  final List<TripCollaborator> miembros;
  final int? currentUserId;
  final double tripBalance; // saldo disponible del dinero del viaje
  final double? pocketBalance; // saldo de TU bolsillo (null = aún no lo creaste)

  /// HU-11 (TG-278): si viene, el formulario advierte en vivo cuando el
  /// monto haría pasar el presupuesto diario de la fecha elegida, y
  /// pide confirmación antes de registrarlo.
  final DailyBudgetCalculator? dailyBudget;

  const AddExpenseSheet({
    super.key,
    required this.categorias,
    required this.tripStartDate,
    required this.tripEndDate,
    this.dailyBudget,
    this.miembros = const [],
    this.currentUserId,
    this.tripBalance = 0,
    this.pocketBalance,
  });

  static Future<NewExpenseData?> show(
    BuildContext context, {
    required List<CategoriaGasto> categorias,
    required DateTime tripStartDate,
    required DateTime tripEndDate,
    DailyBudgetCalculator? dailyBudget,
    List<TripCollaborator> miembros = const [],
    int? currentUserId,
    double tripBalance = 0,
    double? pocketBalance,
  }) {
    return showModalBottomSheet<NewExpenseData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseSheet(
        categorias: categorias,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
        dailyBudget: dailyBudget,
        miembros: miembros,
        currentUserId: currentUserId,
        tripBalance: tripBalance,
        pocketBalance: pocketBalance,
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late CategoriaGasto _selectedCategoria;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _fecha;
  final TextEditingController _placeController = TextEditingController();
  late TimeOfDay _hora;
  int? _pagadoPorId;
  bool _pagadoConDineroViaje = true;
  String? _descriptionError;
  String? _amountError;

  /// Aviso tras escanear un recibo: qué se llenó, o por qué no se pudo.
  String? _scanNotice;
  bool _scanNoticeIsError = false;

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
    _hora = TimeOfDay.fromDateTime(DateTime.now());
    final ids = widget.miembros.map((m) => m.usuarioId).toSet();
    _pagadoPorId = ids.contains(widget.currentUserId)
        ? widget.currentUserId
        : (widget.miembros.isNotEmpty ? widget.miembros.first.usuarioId : null);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: widget.tripStartDate,
      lastDate: widget.tripEndDate,
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  /// Escanea un recibo y llena solo los campos que se pudieron leer; el
  /// resto queda como estaba para que el usuario lo complete.
  Future<void> _scanReceipt() async {
    final result = await ReceiptScanner.scan(context);
    if (result == null || !mounted) return;
    final data = result.data;
    if (data == null) {
      setState(() {
        _scanNotice = result.error;
        _scanNoticeIsError = true;
      });
      return;
    }
    final l10n = context.l10n;
    final notes = <String>[l10n.receiptFilledNotice];
    setState(() {
      if (data.amount != null) {
        _amountController.text = groupThousands(data.amount!);
        _amountError = null;
      }
      final date = data.date;
      if (date != null) {
        final inTrip = !date.isBefore(_dayOnly(widget.tripStartDate)) &&
            !date.isAfter(_dayOnly(widget.tripEndDate));
        if (inTrip) {
          _fecha = date;
        } else {
          notes.add(l10n.receiptDateOutOfTrip(DateFormat('dd/MM/yyyy').format(date)));
        }
      }
      if (data.establishment != null) {
        final name = data.establishment!;
        _descriptionController.text = name.length > 200 ? name.substring(0, 200) : name;
        _descriptionError = null;
        // `gastos.establecimiento` es varchar(150) (lo usa "Top 3
        // establecimientos").
        _placeController.text = name.length > 150 ? name.substring(0, 150) : name;
      }
      final categoria = _categoriaNamed(data.categoryName) ?? _categoriaNamed('Otros');
      if (categoria != null) _selectedCategoria = categoria;
      _scanNotice = notes.join('\n');
      _scanNoticeIsError = false;
    });
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  CategoriaGasto? _categoriaNamed(String? name) {
    if (name == null) return null;
    final key = removeAccents(name.toLowerCase());
    for (final c in widget.categorias) {
      if (removeAccents(c.nombre.toLowerCase()) == key) return c;
    }
    return null;
  }

  Widget _buildScanNotice() {
    final notice = _scanNotice;
    if (notice == null) return const SizedBox.shrink();
    final accent = _scanNoticeIsError ? AppColors.error : AppColors.inkSoft;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _scanNoticeIsError ? AppColors.errorWash : AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _scanNoticeIsError ? Icons.error_outline_rounded : Icons.document_scanner_outlined,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(notice, style: AppText.ui(13, weight: FontWeight.w600, color: accent))),
        ],
      ),
    );
  }

  /// Cómo quedaría el día elegido con el monto escrito (TG-278); `null`
  /// si no hay calculadora, el monto todavía no es válido o el turista
  /// apagó "Mostrar alertas" (HU-11 CA4: se registra sin avisos).
  DailyBudgetStatus? get _projectedDay {
    // Lo pagado con el bolsillo no cuenta contra el presupuesto del viaje.
    if (!_pagadoConDineroViaje) return null;
    final calc = widget.dailyBudget;
    final amount = parseThousands(_amountController.text)?.toDouble();
    if (calc == null || amount == null || amount <= 0) return null;
    if (!context.read<NotificationPrefsProvider>().alertsEnabled) return null;
    return calc.statusFor(_fecha).withExtra(amount);
  }

  /// HU-11 CA3: se permite registrar, pero avisando cuánto se excede.
  Future<bool> _confirmOverBudget(DailyBudgetStatus projected) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
        title: Text(ctx.l10n.addExpenseOverBudgetDialogTitle, style: AppText.display(26)),
        content: Text(
          ctx.l10n.addExpenseOverBudgetDialogContent(
            ctx.formatMoney(projected.dailyBudget),
            ctx.formatMoney(projected.remaining.abs()),
          ),
          style: AppText.ui(14, color: AppColors.textMuted),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        actions: [
          InkButton(
            label: ctx.l10n.configCancelButton,
            variant: InkButtonVariant.secondary,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          InkButton(
            label: ctx.l10n.addExpenseOverBudgetConfirm,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _handleSubmit() async {
    // Monto con punto de miles: `15.000` son quince mil (antes se
    // guardaba como 15).
    final amount = parseThousands(_amountController.text)?.toDouble();
    if (amount == null || amount <= 0) {
      setState(() => _amountError = context.l10n.addExpenseInvalidAmount);
      return;
    }
    final descriptionError = Validators.freeText(
      context,
      _descriptionController.text,
      max: 200,
    );
    if (descriptionError != null) {
      setState(() => _descriptionError = descriptionError);
      return;
    }

    if (!_pagadoConDineroViaje) {
      final balance = widget.pocketBalance;
      if (balance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addExpensePocketMissing),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (amount > balance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addExpensePocketInsufficient(context.formatMoney(balance))),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final projected = _projectedDay;
    if (projected != null && projected.level == DailyBudgetLevel.exceeded) {
      if (!await _confirmOverBudget(projected) || !mounted) return;
    }
    if (!mounted) return;

    final fechaConHora = DateTime(
      _fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute,
    );
    final place = _placeController.text.trim();

    Navigator.pop(
      context,
      NewExpenseData(
        categoria: _selectedCategoria,
        monto: amount,
        fecha: fechaConHora,
        descripcion: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        establecimiento: place.isEmpty ? null : place,
        pagadoPorId: _pagadoConDineroViaje ? _pagadoPorId : widget.currentUserId,
        pagadoConDineroViaje: _pagadoConDineroViaje,
      ),
    );
  }

  /// Advertencia visual en vivo (TG-278): ámbar desde el 75% del
  /// presupuesto del día, roja si este gasto lo supera (CA3).
  Widget _buildDailyBudgetWarning() {
    final projected = _projectedDay;
    final level = projected?.level ?? DailyBudgetLevel.ok;
    final Widget content;
    if (projected == null || level == DailyBudgetLevel.ok) {
      content = const SizedBox(width: double.infinity);
    } else {
      final exceeded = level == DailyBudgetLevel.exceeded;
      final accent = exceeded ? AppColors.error : AppColors.warning;
      content = Container(
        key: ValueKey(level),
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: exceeded ? AppColors.errorWash : AppColors.warningWash,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: accent),
        ),
        child: Row(
          children: [
            Icon(
              exceeded ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exceeded
                    ? context.l10n.addExpenseExceedsDailyBudget(
                        context.formatMoney(projected.remaining.abs()),
                        context.formatMoney(projected.dailyBudget),
                      )
                    : context.l10n.addExpenseNearDailyBudget(
                        projected.percentage.round(),
                        context.formatMoney(projected.remaining),
                      ),
                style: AppText.ui(13, weight: FontWeight.w600, color: accent),
              ),
            ),
          ],
        ),
      );
    }
    return AnimatedSwitcher(duration: AppMotion.toggle, child: content);
  }

  Widget _sourceOption({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color subtitleColor = AppColors.textMuted,
  }) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        semanticLabel: title,
        child: AnimatedContainer(
          duration: AppMotion.toggle,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.wash : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.hair,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.ink),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.ui(13, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: AppText.ui(12, color: subtitleColor)),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector de fuente de pago: dinero del viaje o bolsillo personal.
  Widget _buildPaymentSourceSelector() {
    final amount = parseThousands(_amountController.text)?.toDouble() ?? 0;
    final pocket = widget.pocketBalance;
    final pocketSelected = !_pagadoConDineroViaje;
    final pocketShort = pocketSelected && pocket != null && amount > pocket;

    String? hint;
    if (pocketSelected && pocket == null) {
      hint = context.l10n.addExpensePocketMissing;
    } else if (pocketShort) {
      hint = context.l10n.addExpensePocketInsufficient(context.formatMoney(pocket));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(context.l10n.addExpensePaymentSourceLabel),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sourceOption(
              selected: _pagadoConDineroViaje,
              icon: Icons.luggage_outlined,
              title: context.l10n.addExpenseSourceTrip,
              subtitle: context.l10n.addExpenseSourceBalance(context.formatMoney(widget.tripBalance)),
              onTap: () => setState(() => _pagadoConDineroViaje = true),
            ),
            const SizedBox(width: 10),
            _sourceOption(
              selected: pocketSelected,
              icon: Icons.account_balance_wallet_outlined,
              title: context.l10n.addExpenseSourcePocket,
              subtitle: pocket == null
                  ? context.l10n.addExpenseSourceNoPocket
                  : context.l10n.addExpenseSourceBalance(context.formatMoney(pocket)),
              subtitleColor: pocketShort ? AppColors.error : AppColors.textMuted,
              onTap: () => setState(() {
                _pagadoConDineroViaje = false;
                _pagadoPorId = widget.currentUserId;
              }),
            ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(hint, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.error)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NotificationPrefsProvider>();
    final l10n = context.l10n;
    // El espacio del teclado va POR FUERA del scroll: así el área visible
    // se encoge y Flutter sube el campo enfocado. Con el padding adentro
    // (antes) el scroll creía que el campo se veía aunque el teclado lo
    // tapara. Abajo, además, el alto de la barra de navegación de Android.
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 14,
          bottom: 22 + (media.viewInsets.bottom > 0 ? 0 : media.viewPadding.bottom),
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
                color: AppColors.hair,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(l10n.addExpenseTitle, style: AppText.display(32)),
          const SizedBox(height: 4),
          Text(l10n.addExpenseSubtitle, style: AppText.ui(13, color: AppColors.textMuted)),
          // OCR en el dispositivo: solo Android (ML Kit no corre en web).
          if (ReceiptOcrService.isSupported) ...[
            const SizedBox(height: 16),
            InkButton(
              label: l10n.receiptScanButton,
              icon: Icons.photo_camera_outlined,
              variant: InkButtonVariant.secondary,
              expand: true,
              onPressed: _scanReceipt,
            ),
          ],
          _buildScanNotice(),
          const SizedBox(height: 22),

          FieldLabel(l10n.addExpenseCategoryLabel),
          DropdownButtonFormField<CategoriaGasto>(
            // Key: `initialValue` solo se lee al crearse; así el campo
            // refleja la categoría que sugiere el escaneo del recibo.
            key: ValueKey(_selectedCategoria.id),
            initialValue: _selectedCategoria,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
            items: widget.categorias
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.nombre, style: AppText.ui(15)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategoria = value);
            },
          ),
          const SizedBox(height: 18),

          FieldLabel(l10n.addExpenseAmountLabel),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
            onChanged: (_) => setState(() => _amountError = null),
            style: AppText.ui(18),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.attach_money),
              hintText: l10n.addExpenseAmountHint,
              errorText: _amountError,
            ),
          ),
          _buildDailyBudgetWarning(),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(l10n.addExpenseDateLabel),
                    Pressable(
                      onTap: _pickDate,
                      semanticLabel: l10n.addExpenseDateLabel,
                      child: InputDecorator(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today_outlined)),
                        child: Text(DateFormat('dd/MM/yyyy').format(_fecha), style: AppText.ui(15)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(l10n.addExpenseTimeLabel),
                    Pressable(
                      onTap: _pickTime,
                      semanticLabel: l10n.addExpenseTimeLabel,
                      child: InputDecorator(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time)),
                        child: Text(
                          _hora.format(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.ui(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          FieldLabel(l10n.addExpensePlaceLabel),
          TextField(
            controller: _placeController,
            maxLength: 150,
            inputFormatters: [AppInputFormatters.safeText],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.storefront_outlined),
              hintText: l10n.addExpensePlaceHint,
              counterText: '',
            ),
          ),
          const SizedBox(height: 18),

          _buildPaymentSourceSelector(),
          const SizedBox(height: 18),

          // "¿Quién pagó?" solo aplica al dinero del viaje; con el bolsillo
          // siempre eres tú.
          if (_pagadoConDineroViaje && widget.miembros.isNotEmpty) ...[
            FieldLabel(l10n.addExpensePaidByLabel),
            DropdownButtonFormField<int>(
              initialValue: _pagadoPorId,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
              items: widget.miembros
                  .map((m) => DropdownMenuItem(
                        value: m.usuarioId,
                        child: Text(m.nombreCompleto, style: AppText.ui(15)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _pagadoPorId = v),
            ),
            const SizedBox(height: 18),
          ],

          FieldLabel(l10n.addExpenseDescriptionLabel),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            maxLength: 200,
            inputFormatters: [AppInputFormatters.safeText],
            onChanged: (_) {
              if (_descriptionError != null) setState(() => _descriptionError = null);
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.description_outlined),
              hintText: l10n.addExpenseDescriptionHint,
              errorText: _descriptionError,
            ),
          ),
          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: InkButton(
                  label: l10n.configCancelButton,
                  variant: InkButtonVariant.secondary,
                  expand: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Mismo ancho: con 1:2 "Cancelar" se cortaba en pantallas
                // de 360 dp.
                flex: 1,
                child: InkButton(
                  label: l10n.addExpenseAddButton,
                  trailingArrow: true,
                  expand: true,
                  onPressed: _handleSubmit,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
