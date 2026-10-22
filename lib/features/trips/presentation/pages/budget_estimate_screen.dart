import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../../widgets/stagger_in.dart';

// ─────────────────────────────────────────────────────────────
// Modelos de presentación
// ─────────────────────────────────────────────────────────────

enum TripStyle { economico, estandar, lujo }

extension TripStyleX on TripStyle {
  String title(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      TripStyle.economico => l.estimateStyleEconomyTitle,
      TripStyle.estandar => l.estimateStyleStandardTitle,
      TripStyle.lujo => l.estimateStyleLuxuryTitle,
    };
  }

  String caption(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      TripStyle.economico => l.estimateStyleEconomyCaption,
      TripStyle.estandar => l.estimateStyleStandardCaption,
      TripStyle.lujo => l.estimateStyleLuxuryCaption,
    };
  }

  IconData get icon => switch (this) {
        TripStyle.economico => Icons.savings_outlined,
        TripStyle.estandar => Icons.star_outline_rounded,
        TripStyle.lujo => Icons.diamond_outlined,
      };
}

/// Datos que necesita la pantalla de resultados.
class BudgetEstimate {
  final String destination;
  final int days;
  final int nights;
  final int travelers;
  final TripStyle style;
  final double lodging;
  final double food;
  final double flight;
  final double localTransport;
  final DateTime updatedAt;
  final List<String> sources;

  const BudgetEstimate({
    required this.destination,
    required this.days,
    required this.nights,
    required this.travelers,
    required this.style,
    required this.lodging,
    required this.food,
    required this.flight,
    required this.localTransport,
    required this.updatedAt,
    required this.sources,
  });

  double get transport => flight + localTransport;
  double get total => lodging + food + transport;
  double get low => total * 0.85;
  double get high => total * 1.15;
}

enum _Phase { form, loading, result }

enum _DestError { empty }

enum _DateError { empty, tooShort, tooLong }

/// Nombres de ciudades: son datos (cuando el back devuelva la búsqueda real,
/// vendrán ya en el idioma de la app).
const _cities = <String>[
  'Medellín, Colombia',
  'Bogotá, Colombia',
  'Cartagena, Colombia',
  'Cali, Colombia',
  'Santa Marta, Colombia',
  'Ciudad de México, México',
  'Cancún, México',
  'Lima, Perú',
  'Cusco, Perú',
  'Buenos Aires, Argentina',
  'Santiago, Chile',
  'Panamá, Panamá',
  'San José, Costa Rica',
  'Punta Cana, República Dominicana',
  'Miami, Estados Unidos',
  'Nueva York, Estados Unidos',
  'Madrid, España',
  'Barcelona, España',
  'París, Francia',
  'Roma, Italia',
];

// ─────────────────────────────────────────────────────────────
// Pantalla
// ─────────────────────────────────────────────────────────────

class BudgetEstimateScreen extends StatefulWidget {
  const BudgetEstimateScreen({super.key});

  @override
  State<BudgetEstimateScreen> createState() => _BudgetEstimateScreenState();
}

class _BudgetEstimateScreenState extends State<BudgetEstimateScreen> {
  _Phase _phase = _Phase.form;

  String _destination = '';
  DateTimeRange? _range;
  int _travelers = 1;
  TripStyle _style = TripStyle.estandar;

  _DestError? _destError;
  _DateError? _dateError;
  BudgetEstimate? _estimate;

  int get _days => _range == null ? 0 : _range!.end.difference(_range!.start).inDays + 1;
  int get _nights => _range == null ? 0 : _days - 1;

  String _destMessage(_DestError e) => context.l10n.estimateErrorDestinationEmpty;

  String _dateMessage(_DateError e) => switch (e) {
        _DateError.empty => context.l10n.estimateErrorDatesEmpty,
        _DateError.tooShort => context.l10n.estimateErrorDatesTooShort,
        _DateError.tooLong => context.l10n.estimateErrorDatesTooLong,
      };

  // ── Acciones ──

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(const Duration(days: 730)),
      initialDateRange: _range,
      helpText: context.l10n.estimateDatePickerHelp,
      saveText: context.l10n.estimateDatePickerSave,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.ink),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _dateError = null;
      });
    }
  }

  bool _validate() {
    _DestError? dest;
    _DateError? date;
    if (_destination.trim().isEmpty) {
      dest = _DestError.empty;
    }
    if (_range == null) {
      date = _DateError.empty;
    } else if (_nights < 1) {
      date = _DateError.tooShort;
    } else if (_days > 30) {
      date = _DateError.tooLong;
    }
    setState(() {
      _destError = dest;
      _dateError = date;
    });
    return dest == null && date == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _phase = _Phase.loading);
    try {
      final result = await _fetchEstimate();
      if (!mounted) return;
      setState(() {
        _estimate = result;
        _phase = _Phase.result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.form);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.estimateErrorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _reset() => setState(() => _phase = _Phase.form);

  /// TODO(back): reemplazar por la consulta real. Hoy devuelve datos de ejemplo
  /// para poder ver el diseño; la pantalla solo necesita un [BudgetEstimate].
  Future<BudgetEstimate> _fetchEstimate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    final f = switch (_style) {
      TripStyle.economico => 0.6,
      TripStyle.estandar => 1.0,
      TripStyle.lujo => 2.4,
    };
    final rooms = (_travelers / 2).ceil();
    return BudgetEstimate(
      destination: _destination.trim(),
      days: _days,
      nights: _nights,
      travelers: _travelers,
      style: _style,
      lodging: 180000 * f * _nights * rooms,
      food: 90000 * f * _days * _travelers,
      flight: 420000 * f * _travelers,
      localTransport: 35000 * f * _days * _travelers,
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      sources: const ['Google Hotels', 'Booking', 'Skyscanner'],
    );
  }

  // ── UI ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(context.l10n.estimateScreenTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: switch (_phase) {
              _Phase.form => KeyedSubtree(key: const ValueKey('form'), child: _buildForm()),
              _Phase.loading => const KeyedSubtree(key: ValueKey('loading'), child: _LoadingView()),
              _Phase.result => KeyedSubtree(
                  key: const ValueKey('result'),
                  child: _ResultView(estimate: _estimate!),
                ),
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: switch (_phase) {
                _Phase.form => _primaryButton(
                    label: context.l10n.estimateButton,
                    icon: Icons.calculate_outlined,
                    onPressed: _submit,
                  ),
                _Phase.loading => _primaryButton(
                    label: context.l10n.estimateButtonLoading,
                    loading: true,
                    onPressed: null,
                  ),
                _Phase.result => _primaryButton(
                    label: context.l10n.estimateButtonNew,
                    icon: Icons.refresh_rounded,
                    onPressed: _reset,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else if (icon != null)
              Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(label, style: AppText.ui(15, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ── Formulario ──

  Widget _buildForm() {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(l.estimateEyebrow, style: AppText.label(10, color: AppColors.textLabel)),
        const SizedBox(height: 8),
        Text(l.estimateTitleLine1, style: AppText.display(34)),
        Text(l.estimateTitleLine2, style: AppText.displayItalic(34)),
        const SizedBox(height: 8),
        Text(l.estimateIntro, style: AppText.ui(13, color: AppColors.textMuted)),
        const SizedBox(height: 28),

        // Destino
        _FieldLabel(l.estimateDestinationLabel),
        LayoutBuilder(
          builder: (context, c) => Autocomplete<String>(
            optionsBuilder: (value) {
              final q = value.text.trim().toLowerCase();
              if (q.isEmpty) return const Iterable<String>.empty();
              return _cities.where((city) => city.toLowerCase().contains(q)).take(5);
            },
            onSelected: (value) => setState(() {
              _destination = value;
              _destError = null;
            }),
            fieldViewBuilder: (context, controller, focusNode, onSubmit) => Container(
              decoration: _shell(error: _destError != null),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: AppText.ui(15),
                textCapitalization: TextCapitalization.words,
                onChanged: (v) {
                  _destination = v;
                  if (_destError != null) setState(() => _destError = null);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l.estimateDestinationHint,
                  hintStyle: AppText.ui(15, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.inkSoft),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: AppColors.surface,
                elevation: 6,
                borderRadius: BorderRadius.circular(AppRadius.control),
                child: SizedBox(
                  width: c.maxWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final option = options.elementAt(i);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.inkSoft),
                                const SizedBox(width: 10),
                                Expanded(child: Text(option, style: AppText.ui(14))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_destError != null) _ErrorText(_destMessage(_destError!)),
        const SizedBox(height: 22),

        // Fechas
        _FieldLabel(l.estimateDatesLabel),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.control),
          onTap: _pickRange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: _shell(error: _dateError != null),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, color: AppColors.inkSoft),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _range == null
                        ? l.estimateDatesPlaceholder
                        : '${DateFormat('dd/MM/yy').format(_range!.start)}  →  ${DateFormat('dd/MM/yy').format(_range!.end)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(15, color: _range == null ? AppColors.textMuted : AppColors.ink),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (_dateError != null)
          _ErrorText(_dateMessage(_dateError!))
        else if (_range != null && _nights >= 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.inkSoft),
                const SizedBox(width: 6),
                Text(
                  l.estimateDurationSummary(_days, _nights),
                  style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),

        // Viajeros
        _FieldLabel(l.estimateTravelersLabel),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _shell(),
          child: Row(
            children: [
              const Icon(Icons.groups_outlined, color: AppColors.inkSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.estimateTravelersCount(_travelers),
                  style: AppText.ui(15, weight: FontWeight.w600),
                ),
              ),
              _RoundButton(
                icon: Icons.remove,
                onTap: _travelers > 1 ? () => setState(() => _travelers--) : null,
              ),
              const SizedBox(width: 8),
              _RoundButton(
                icon: Icons.add,
                onTap: _travelers < 10 ? () => setState(() => _travelers++) : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Tipo de viaje
        _FieldLabel(l.estimateTripTypeLabel),
        Row(
          children: [
            for (final s in TripStyle.values) ...[
              Expanded(
                child: _StyleOption(
                  style: s,
                  selected: _style == s,
                  onTap: () => setState(() => _style = s),
                ),
              ),
              if (s != TripStyle.values.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

BoxDecoration _shell({bool error = false}) => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      border: Border.all(color: error ? AppColors.error : AppColors.line, width: error ? 1.5 : 1),
    );

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.label(10, color: AppColors.textLabel)),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 15, color: AppColors.error),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.error)),
            ),
          ],
        ),
      );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.wash : AppColors.wash.withValues(alpha: 0.5),
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.ink : AppColors.textMuted),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({required this.style, required this.selected, required this.onTap});
  final TripStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: selected ? AppColors.ink : AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(style.icon, size: 22, color: selected ? AppColors.mint : AppColors.inkSoft),
            const SizedBox(height: 10),
            Text(
              style.title(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.ui(13, weight: FontWeight.w700, color: selected ? AppColors.paper : AppColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              style.caption(context),
              style: AppText.ui(11, color: selected ? AppColors.textOnInk : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Estado de carga: pasos + esqueleto de los resultados
// ─────────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> with SingleTickerProviderStateMixin {
  static const _stepCount = 3;

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  Timer? _timer;
  int _step = 0;

  List<String> get _steps => [
        context.l10n.estimateLoadingStepLodging,
        context.l10n.estimateLoadingStepFlights,
        context.l10n.estimateLoadingStepLocal,
      ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_step < _stepCount - 1 && mounted) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  Widget _box(double height, {double? width, double radius = 12}) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(radius)),
      );

  Widget _stepRow(int i, String label) {
    final done = i < _step;
    final current = i == _step;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: done
                ? const Icon(Icons.check_circle, size: 20, color: AppColors.inkSoft)
                : current
                    ? const Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                      )
                    : const Icon(Icons.circle_outlined, size: 20, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppText.ui(
                13,
                weight: current ? FontWeight.w700 : FontWeight.w500,
                color: done || current ? AppColors.ink : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card + 2),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.estimateLoadingEyebrow, style: AppText.label(10, color: AppColors.textLabel)),
              const SizedBox(height: 6),
              Text(context.l10n.estimateLoadingTitle, style: AppText.display(24)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  color: AppColors.mint,
                  backgroundColor: AppColors.wash,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < steps.length; i++) _stepRow(i, steps[i]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Esqueleto de la pantalla de resultados
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => Opacity(
            opacity: 0.45 + 0.55 * _pulse.value,
            child: Column(
              children: [
                _box(210, radius: 30),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card + 2),
                  ),
                  child: Column(
                    children: [
                      Align(alignment: Alignment.centerLeft, child: _box(20, width: 120)),
                      const SizedBox(height: 18),
                      for (var i = 0; i < 3; i++) ...[
                        Row(
                          children: [
                            _box(34, width: 34, radius: 10),
                            const SizedBox(width: 12),
                            Expanded(child: _box(14)),
                            const SizedBox(width: 16),
                            _box(14, width: 70),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _box(6, radius: 3),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Resultados
// ─────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.estimate});
  final BudgetEstimate estimate;

  String _updated(BuildContext context, DateTime t) {
    final h = DateTime.now().difference(t).inHours;
    return h < 1
        ? context.l10n.estimateUpdatedLessThanHour
        : context.l10n.estimateUpdatedHoursAgo(h);
  }

  @override
  Widget build(BuildContext context) {
    final e = estimate;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        StaggerIn(index: 0, child: _hero(context, e)),
        const SizedBox(height: 16),
        StaggerIn(index: 1, child: _breakdown(context, e)),
        const SizedBox(height: 16),
        StaggerIn(index: 2, child: _sources(context, e)),
        const SizedBox(height: 16),
        StaggerIn(index: 3, child: _warning(context)),
      ],
    );
  }

  Widget _hero(BuildContext context, BudgetEstimate e) {
    final l = context.l10n;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Stack(
        children: [
          const RoutePatternBackground(opacity: 0.10),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.estimateResultEyebrow, style: AppText.label(10, color: AppColors.textOnInk)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(context.formatMoney(e.total), style: AppText.display(46, color: AppColors.paper)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(l.estimateRangeBadge, style: AppText.label(10, color: AppColors.ink)),
                    ),
                    Text(
                      '${context.formatMoney(e.low)} – ${context.formatMoney(e.high)}',
                      style: AppText.ui(15, weight: FontWeight.w700, color: AppColors.paper),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.18)),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l.tripDetailHeaderTripToPrefix, style: AppText.display(24, color: Colors.white)),
                    Text(
                      e.destination,
                      style: AppText.displayItalic(24).copyWith(color: AppColors.mint),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l.estimateHeroSubtitle(e.nights, e.travelers, e.style.title(context).toUpperCase()),
                  style: AppText.label(11, color: AppColors.textOnInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdown(BuildContext context, BudgetEstimate e) {
    final l = context.l10n;
    final total = e.total <= 0 ? 1.0 : e.total;
    return _Card(
      title: l.estimateBreakdownTitle,
      trailing: context.formatMoney(e.total),
      child: Column(
        children: [
          _categoryRow(
            context,
            icon: Icons.hotel_outlined,
            title: l.estimateLodgingTitle,
            caption: l.estimateLodgingCaption(e.nights),
            amount: e.lodging,
            share: e.lodging / total,
          ),
          _categoryRow(
            context,
            icon: Icons.restaurant_outlined,
            title: l.estimateFoodTitle,
            caption: l.estimateFoodCaption(e.days),
            amount: e.food,
            share: e.food / total,
          ),
          _categoryRow(
            context,
            icon: Icons.flight_outlined,
            title: l.estimateTransportTitle,
            caption: l.estimateTransportCaption,
            amount: e.transport,
            share: e.transport / total,
            isLast: true,
            details: [
              (l.estimateFlightLabel, e.flight),
              (l.estimateLocalTransportLabel, e.localTransport),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String caption,
    required double amount,
    required double share,
    bool isLast = false,
    List<(String, double)> details = const [],
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.ui(14, weight: FontWeight.w600)),
                    Text(caption, style: AppText.ui(12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.formatMoney(amount),
                    style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
                  ),
                  Text('${(share * 100).round()}%', style: AppText.label(10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          BudgetBar(progress: share.clamp(0.0, 1.0), height: 6),
          for (final d in details)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d.$1, style: AppText.ui(12, color: AppColors.textMuted)),
                  Text(context.formatMoney(d.$2), style: AppText.ui(12, weight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sources(BuildContext context, BudgetEstimate e) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.estimateSourcesIntro,
                  style: AppText.ui(13, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in e.sources)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(s, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.ink.withValues(alpha: 0.10)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 15, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _updated(context, e.updatedAt),
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _warning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warningWash,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.estimateDisclaimer,
              style: AppText.ui(12.5, weight: FontWeight.w600, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, this.trailing, required this.child});
  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
              Text(title, style: AppText.display(22)),
              if (trailing != null) Text(trailing!, style: AppText.label(12, color: AppColors.inkSoft)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}