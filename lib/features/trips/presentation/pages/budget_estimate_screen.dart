import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../../widgets/stagger_in.dart';
import '../../../subscriptions/presentation/widgets/premium_gate.dart';
import '../../data/estimate_repository.dart';
import '../../data/models/estimate_models.dart';
import '../../utils/trip_estimator.dart';
import '../../../../shell/app_shell.dart';
import '../../../../shell/shell_page.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../../../widgets/load_error_box.dart';
import '../../../../widgets/pressable.dart';
import 'create_trip_screen.dart';

// ─────────────────────────────────────────────────────────────
// Textos e íconos de los modelos
// ─────────────────────────────────────────────────────────────

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

extension TravelModeX on TravelMode {
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      TravelMode.avion => l.estimateModePlane,
      TravelMode.bus => l.estimateModeBus,
      TravelMode.carro => l.estimateModeCar,
    };
  }

  IconData get icon => switch (this) {
        TravelMode.avion => Icons.flight_outlined,
        TravelMode.bus => Icons.directions_bus_outlined,
        TravelMode.carro => Icons.directions_car_outlined,
      };
}

enum _Phase { form, loading, result }

enum _OriginError { empty, same }

enum _DateError { empty, tooShort, tooLong }

/// Quita tildes para buscar "medellin" o "bogota" sin escribirlas.
String _normalize(String s) {
  const from = 'áéíóúüÁÉÍÓÚÜ';
  const to = 'aeiouuAEIOUU';
  final buffer = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buffer.write(i < 0 ? ch : to[i]);
  }
  return buffer.toString().trim();
}

// ─────────────────────────────────────────────────────────────
// Pantalla
// ─────────────────────────────────────────────────────────────

class BudgetEstimateScreen extends StatefulWidget {
  const BudgetEstimateScreen({super.key});

  @override
  State<BudgetEstimateScreen> createState() => _BudgetEstimateScreenState();
}

class _BudgetEstimateScreenState extends State<BudgetEstimateScreen> {
  final _repository = EstimateRepository();

  _Phase _phase = _Phase.form;

  EstimateReferenceData? _data;
  bool _dataError = false;

  String? _destinationId;
  String? _originId;
  DateTimeRange? _range;
  int _travelers = 1;
  TravelMode? _mode;
  TripStyle _style = TripStyle.estandar;
  bool _tours = false;
  bool _nightlife = false;
  bool _souvenirs = false;
  final Set<CoveredCost> _covered = {};

  bool _destError = false;
  _OriginError? _originError;
  _DateError? _dateError;
  bool _modeError = false;
  bool _allCoveredError = false;
  BudgetEstimate? _estimate;
  Map<TripStyle, BudgetEstimate>? _comparison;

  int get _days => _range == null ? 0 : _range!.end.difference(_range!.start).inDays + 1;
  int get _nights => _range == null ? 0 : _days - 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    setState(() => _dataError = false);
    try {
      final data = await _repository.fetchReferenceData(refresh: refresh);
      if (!mounted) return;
      setState(() => _data = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dataError = true);
    }
  }

  String _originMessage(_OriginError e) => switch (e) {
        _OriginError.empty => context.l10n.estimateErrorOriginEmpty,
        _OriginError.same => context.l10n.estimateErrorOriginSame,
      };

  String _dateMessage(_DateError e) => switch (e) {
        _DateError.empty => context.l10n.estimateErrorDatesEmpty,
        _DateError.tooShort => context.l10n.estimateErrorDatesTooShort,
        _DateError.tooLong => context.l10n.estimateErrorDatesTooLong,
      };

  List<RouteOption> get _routeOptions {
    final data = _data;
    if (data == null || _originId == null || _destinationId == null || _originId == _destinationId) {
      return const [];
    }
    return TripEstimator(data).routeOptions(_originId!, _destinationId!);
  }

  /// Al cambiar origen o destino: si el medio elegido ya no existe en la
  /// ruta, elige el primero disponible y recomendado.
  void _syncMode() {
    final options = _routeOptions;
    if (options.isEmpty) return;
    final current = options.where((o) => o.mode == _mode && o.available);
    if (current.isNotEmpty) return;
    final best = options.where((o) => o.available && o.recommended).firstOrNull ??
        options.where((o) => o.available).firstOrNull;
    _mode = best?.mode;
  }

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
    final destError = _destinationId == null;
    _OriginError? origin;
    _DateError? date;
    if (_originId == null) {
      origin = _OriginError.empty;
    } else if (_originId == _destinationId) {
      origin = _OriginError.same;
    }
    if (_range == null) {
      date = _DateError.empty;
    } else if (_nights < 1) {
      date = _DateError.tooShort;
    } else if (_days > 30) {
      date = _DateError.tooLong;
    }
    final modeError =
        !destError && origin == null && _mode == null && !_covered.contains(CoveredCost.intercity);
    final allCovered =
        _covered.length == CoveredCost.values.length && !_tours && !_nightlife && !_souvenirs;
    setState(() {
      _destError = destError;
      _originError = origin;
      _dateError = date;
      _modeError = modeError;
      _allCoveredError = allCovered;
    });
    return !destError && origin == null && date == null && !modeError && !allCovered;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _phase = _Phase.loading);
    try {
      // Pausa corta para que la transición no parpadee: el cálculo en sí
      // es inmediato (los precios ya están en caché).
      final results = await Future.wait([
        _repository.fetchReferenceData(),
        _repository.fetchRealSpending(_destinationId!),
        Future<void>.delayed(const Duration(milliseconds: 900)),
      ]);
      final estimator = TripEstimator(results[0] as EstimateReferenceData);
      final real = results[1] as RealSpending?;
      final input = EstimateInput(
          originId: _originId!,
          destinationId: _destinationId!,
          start: _range!.start,
          end: _range!.end,
          travelers: _travelers,
          style: _style,
          // Con la ida y vuelta cubierta el medio no importa (no se cobra).
          mode: _mode ?? TravelMode.bus,
          tours: _tours,
          nightlife: _nightlife,
          souvenirs: _souvenirs,
          covered: {..._covered},
      );
      final estimate = estimator.estimate(input, real: real);
      final comparison = estimator.compareStyles(input, real: real);
      if (!mounted) return;
      setState(() {
        _estimate = estimate;
        _comparison = comparison;
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

  /// Escenario 9: abre "Crear viaje" (HU-05) lleno con la estimación. Si
  /// se guarda, esta pantalla se cierra devolviendo el viaje al inicio.
  Future<void> _createTrip() async {
    final e = _estimate!;
    final trip = await showCreateTripDialog(
      context,
      prefill: CreateTripPrefill(
        name: context.l10n.estimateTripName(e.destination.nombre),
        destination: e.destination.etiqueta,
        start: e.input.start,
        end: e.input.end,
        persons: e.travelers,
        maxBudget: e.total,
        lodgingType: e.input.isCovered(CoveredCost.lodging)
            ? 'Otro'
            : e.style == TripStyle.economico
                ? 'Hostel'
                : 'Hotel',
        lodgingCost: e.lodging,
        meals: e.food,
        transport: e.transport,
        tours: e.tours,
        nightlife: e.nightlife,
        souvenirs: e.souvenirs,
      ),
    );
    if (!mounted || trip == null) return;
    context.pop(trip);
  }

  // ── UI ──

  void _back() => context.canPop() ? context.pop() : context.go('/');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ShellPage(
      section: AppSection.inicio,
      header: (asCard) => InkHeader(
        eyebrow: l.estimateEyebrow,
        title: l.estimateTitleLine1,
        titleAccent: l.estimateTitleLine2,
        subtitle: _phase == _Phase.form ? l.estimateIntro : null,
        asCard: asCard,
        onBack: _back,
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.step,
        switchInCurve: AppMotion.enter,
        child: switch (_phase) {
          _Phase.form => KeyedSubtree(key: const ValueKey('form'), child: _buildFormOrStatus()),
          _Phase.loading => const KeyedSubtree(key: ValueKey('loading'), child: _LoadingView()),
          _Phase.result => KeyedSubtree(
              key: const ValueKey('result'),
              child: _ResultView(estimate: _estimate!, comparison: _comparison!),
            ),
        },
      ),
      action: switch (_phase) {
        _Phase.form => InkButton(
            label: l.estimateButton,
            expand: true,
            trailingArrow: true,
            onPressed: _data == null ? null : _submit,
          ),
        _Phase.loading => InkButton(label: l.estimateButtonLoading, expand: true, loading: true, onPressed: null),
        _Phase.result => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkButton(label: l.estimateCreateTrip, expand: true, trailingArrow: true, onPressed: _createTrip),
              const SizedBox(height: 10),
              InkButton(
                label: l.estimateButtonNew,
                variant: InkButtonVariant.secondary,
                expand: true,
                onPressed: _reset,
              ),
            ],
          ),
      },
    );
  }

  // ── Formulario ──

  /// Mientras cargan los precios de referencia (o si fallan) no se puede
  /// llenar el formulario: los destinos y las rutas salen de esos datos.
  Widget _buildFormOrStatus() {
    final data = _data;
    if (data != null) return _buildForm(data);
    if (!_dataError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    return LoadErrorBox(message: context.l10n.estimateDataError, onRetry: () => _loadData(refresh: true));
  }

  /// En escritorio los campos van de a dos (retícula del sistema); en
  /// móvil, uno debajo del otro.
  Widget _buildForm(EstimateReferenceData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        Widget pair(Widget a, Widget b) => wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: a), const SizedBox(width: 26), Expanded(child: b)],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [a, const SizedBox(height: 22), b],
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            pair(_destinationSection(data), _originSection(data)),
            const SizedBox(height: 22),
            pair(_datesSection(), _travelersSection()),
            const SizedBox(height: 22),
            pair(_modeSection(), _styleSection()),
            const SizedBox(height: 22),
            pair(_extrasSection(), _coveredSection()),
          ],
        );
      },
    );
  }

  Widget _section(String label, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_FieldLabel(label), ...children],
      );

  Widget _destinationSection(EstimateReferenceData data) {
    final l = context.l10n;
    return _section(l.estimateDestinationLabel, [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final city in data.destinos)
            _CityChip(
              city: city,
              selected: _destinationId == city.id,
              onTap: () => setState(() {
                _destinationId = city.id;
                _destError = false;
                if (_originError == _OriginError.same && _originId != city.id) _originError = null;
                _syncMode();
              }),
            ),
        ],
      ),
      if (_destError) _ErrorText(l.estimateErrorDestinationEmpty),
    ]);
  }

  Widget _originSection(EstimateReferenceData data) {
    final l = context.l10n;
    return _section(l.estimateOriginLabel, [
      _OriginField(
        cities: data.ciudades,
        excludeId: _destinationId,
        hasError: _originError != null,
        onChanged: (id) => setState(() {
          _originId = id;
          _originError = null;
          _syncMode();
        }),
      ),
      if (_originError != null) _ErrorText(_originMessage(_originError!)),
    ]);
  }

  Widget _datesSection() {
    final l = context.l10n;
    final date = DateFormat('d MMM', Localizations.localeOf(context).toString());
    return _section(l.estimateDatesLabel, [
      Pressable(
        onTap: _pickRange,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: _shell(error: _dateError != null),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppColors.inkSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _range == null
                      ? l.estimateDatesPlaceholder
                      : '${date.format(_range!.start)} — ${date.format(_range!.end)}'.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _range == null
                      ? AppText.ui(16, color: AppColors.textMuted)
                      : AppText.label(13, color: AppColors.ink, weight: FontWeight.w500),
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
          child: Text(
            l.estimateDurationSummary(_days, _nights).toUpperCase(),
            style: AppText.label(10, color: AppColors.inkSoft),
          ),
        ),
    ]);
  }

  Widget _travelersSection() {
    final l = context.l10n;
    return _section(l.estimateTravelersLabel, [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: _shell(),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined, color: AppColors.inkSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l.estimateTravelersCount(_travelers), style: AppText.ui(16, weight: FontWeight.w600)),
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
    ]);
  }

  Widget _note(IconData icon, String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _shell(),
        child: Row(
          children: [
            Icon(icon, color: AppColors.inkSoft),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: AppText.ui(13, color: AppColors.textMuted))),
          ],
        ),
      );

  Widget _modeSection() {
    final l = context.l10n;
    final routeOptions = _routeOptions;
    final covered = _covered.contains(CoveredCost.intercity);
    final approximate = routeOptions.any((o) => o.mode == _mode && o.approximate);
    return _section(l.estimateModeLabel, [
      if (covered)
        _note(Icons.check_circle_outline, l.estimateModeCovered)
      else if (routeOptions.isEmpty)
        _note(Icons.alt_route_rounded, l.estimateModePickCities)
      else
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in routeOptions) ...[
              Expanded(
                child: _ModeOption(
                  option: option,
                  selected: _mode == option.mode,
                  onTap: option.available
                      ? () => setState(() {
                            _mode = option.mode;
                            _modeError = false;
                          })
                      : null,
                ),
              ),
              if (option != routeOptions.last) const SizedBox(width: 10),
            ],
          ],
        ),
      if (_modeError) _ErrorText(l.estimateErrorModeEmpty),
      if (approximate && !covered)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l.estimateModeApproximate, style: AppText.ui(12, color: AppColors.inkSoft)),
        ),
    ]);
  }

  Widget _styleSection() {
    final l = context.l10n;
    return _section(l.estimateTripTypeLabel, [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    ]);
  }

  Widget _extrasSection() {
    final l = context.l10n;
    return _section(l.estimateExtrasLabel, [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ExtraChip(
            icon: Icons.hiking_outlined,
            label: l.estimateExtraTours,
            selected: _tours,
            onTap: () => setState(() => _tours = !_tours),
          ),
          _ExtraChip(
            icon: Icons.nightlife_outlined,
            label: l.estimateExtraNightlife,
            selected: _nightlife,
            onTap: () => setState(() => _nightlife = !_nightlife),
          ),
          _ExtraChip(
            icon: Icons.card_giftcard_outlined,
            label: l.estimateExtraSouvenirs,
            selected: _souvenirs,
            onTap: () => setState(() => _souvenirs = !_souvenirs),
          ),
        ],
      ),
    ]);
  }

  Widget _coveredSection() {
    final l = context.l10n;
    return _section(l.estimateCoveredLabel, [
      Text(l.estimateCoveredHint, style: AppText.ui(12, color: AppColors.textMuted)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (cost, icon, label) in [
            (CoveredCost.lodging, Icons.hotel_outlined, l.estimateCoveredLodging),
            (CoveredCost.food, Icons.restaurant_outlined, l.estimateCoveredFood),
            (CoveredCost.intercity, Icons.swap_horiz_rounded, l.estimateCoveredIntercity),
            (CoveredCost.localTransport, Icons.directions_transit_outlined, l.estimateCoveredLocal),
          ])
            _ExtraChip(
              icon: icon,
              label: label,
              selected: _covered.contains(cost),
              onTap: () => setState(() {
                if (!_covered.remove(cost)) _covered.add(cost);
                _allCoveredError = false;
                if (cost == CoveredCost.intercity) _modeError = false;
              }),
            ),
        ],
      ),
      if (_allCoveredError) _ErrorText(l.estimateErrorAllCovered),
    ]);
  }
}

/// Campo del sistema: pista `paperDeep`, radio 18, sin borde salvo error.
BoxDecoration _shell({bool error = false}) => BoxDecoration(
      color: AppColors.paperDeep,
      borderRadius: BorderRadius.circular(AppRadius.dateField),
      border: error ? Border.all(color: AppColors.error, width: 1.5) : null,
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
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          color: enabled ? AppColors.surface : AppColors.surface.withValues(alpha: 0.45),
          border: Border.all(color: AppColors.hair),
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.ink : AppColors.textMuted),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.city, required this.selected, required this.onTap});
  final EstimateCity city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.listItem,
        curve: AppMotion.enter,
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: selected ? AppColors.mint : AppColors.inkSoft),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.nombre,
                  style: AppText.ui(14, weight: FontWeight.w700, color: selected ? AppColors.paper : AppColors.ink),
                ),
                Text(
                  city.departamento,
                  style: AppText.ui(11, color: selected ? AppColors.textOnInk : AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Buscador de la ciudad de origen. Solo cuenta como elegida si se toca una
/// opción de la lista; si después se edita el texto, se vuelve a borrar.
class _OriginField extends StatefulWidget {
  const _OriginField({
    required this.cities,
    required this.excludeId,
    required this.hasError,
    required this.onChanged,
  });

  final List<EstimateCity> cities;
  final String? excludeId;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  @override
  State<_OriginField> createState() => _OriginFieldState();
}

class _OriginFieldState extends State<_OriginField> {
  EstimateCity? _selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Autocomplete<EstimateCity>(
        displayStringForOption: (city) => city.nombre,
        optionsBuilder: (value) {
          final q = _normalize(value.text);
          return widget.cities.where(
            (city) =>
                city.id != widget.excludeId &&
                (q.isEmpty || _normalize(city.nombre).contains(q) || _normalize(city.departamento).contains(q)),
          );
        },
        onSelected: (city) {
          _selected = city;
          widget.onChanged(city.id);
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmit) => Container(
          decoration: _shell(error: widget.hasError),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppText.ui(15),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              if (_selected != null && v != _selected!.nombre) {
                _selected = null;
                widget.onChanged(null);
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.estimateOriginHint,
              hintStyle: AppText.ui(15, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.trip_origin_rounded, color: AppColors.inkSoft),
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
                            Expanded(child: Text(option.nombre, style: AppText.ui(14))),
                            Text(option.departamento, style: AppText.ui(12, color: AppColors.textMuted)),
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
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.option, required this.selected, required this.onTap});
  final RouteOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final enabled = onTap != null;
    final caption = !option.available
        ? l.estimateModeUnavailable
        : l.estimateModeHours(NumberFormat('0.#').format(option.hours));
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.listItem,
        curve: AppMotion.enter,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(option.mode.icon, size: 22, color: selected ? AppColors.mint : AppColors.inkSoft),
              const SizedBox(height: 10),
              Text(
                option.mode.label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(13, weight: FontWeight.w700, color: selected ? AppColors.paper : AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(caption, style: AppText.ui(11, color: selected ? AppColors.textOnInk : AppColors.textMuted)),
              if (option.available && !option.recommended) ...[
                const SizedBox(height: 6),
                Text(
                  l.estimateModeNotRecommended,
                  style: AppText.ui(10.5, weight: FontWeight.w700, color: selected ? AppColors.mint : AppColors.warning),
                ),
              ],
            ],
          ),
        ),
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
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.listItem,
        curve: AppMotion.enter,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
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

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.listItem,
        curve: AppMotion.enter,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: selected ? AppColors.ink : AppColors.hair),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.check_rounded : icon, size: 16, color: selected ? AppColors.mint : AppColors.inkSoft),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.ui(13, weight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.mint : AppColors.ink),
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
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
  const _ResultView({required this.estimate, required this.comparison});
  final BudgetEstimate estimate;

  /// La misma estimación en los tres estilos (detalle Premium).
  final Map<TripStyle, BudgetEstimate> comparison;

  int get _percent => (estimate.variation * 100).round();

  @override
  Widget build(BuildContext context) {
    final e = estimate;
    final main = [
      StaggerIn(index: 0, child: _hero(context, e)),
      const SizedBox(height: 18),
      StaggerIn(index: 1, child: _breakdown(context, e)),
    ];
    final side = [
      StaggerIn(
        index: 2,
        child: PremiumGate(
          compact: true,
          icon: Icons.insights_outlined,
          title: context.l10n.estimateDetailTitle,
          description: context.l10n.estimateDetailGateDescription,
          child: _detail(context, e),
        ),
      ),
      const SizedBox(height: 18),
      StaggerIn(index: 3, child: _sources(context, e)),
      const SizedBox(height: 18),
      StaggerIn(index: 4, child: _warning(context)),
    ];
    // Dos columnas asimétricas 1.6 : 1 en escritorio (como Inicio).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...main, const SizedBox(height: 18), ...side],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: main)),
            const SizedBox(width: 26),
            Expanded(flex: 10, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side)),
          ],
        );
      },
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
                      child: Text(l.estimateRangeBadge(_percent), style: AppText.label(10, color: AppColors.ink)),
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
                      e.destination.nombre,
                      style: AppText.displayItalic(24).copyWith(color: AppColors.mint),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l.estimateHeroSubtitle(e.nights, e.travelers, e.style.title(context).toUpperCase()),
                  style: AppText.label(11, color: AppColors.textOnInk),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(e.input.mode.icon, size: 14, color: AppColors.textOnInk),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l.estimateHeroFrom(e.origin.nombre, e.input.mode.label(context).toLowerCase()),
                        style: AppText.ui(12, color: AppColors.textOnInk),
                      ),
                    ),
                  ],
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
    final hasExtras = e.extras > 0;
    final lodgingCovered = e.input.isCovered(CoveredCost.lodging);
    final foodCovered = e.input.isCovered(CoveredCost.food);
    final intercityCovered = e.input.isCovered(CoveredCost.intercity);
    final localCovered = e.input.isCovered(CoveredCost.localTransport);
    return _Card(
      title: l.estimateBreakdownTitle,
      trailing: context.formatMoney(e.total),
      child: Column(
        children: [
          _categoryRow(
            context,
            icon: Icons.hotel_outlined,
            title: l.estimateLodgingTitle,
            caption: lodgingCovered ? l.estimateCoveredCaption : l.estimateLodgingCaption(e.rooms, e.nights),
            amount: e.lodging,
            share: e.lodging / total,
            covered: lodgingCovered,
          ),
          _categoryRow(
            context,
            icon: Icons.restaurant_outlined,
            title: l.estimateFoodTitle,
            caption: foodCovered ? l.estimateCoveredCaption : l.estimateFoodCaption(e.days),
            amount: e.food,
            share: e.food / total,
            covered: foodCovered,
          ),
          _categoryRow(
            context,
            icon: intercityCovered ? Icons.directions_transit_outlined : e.input.mode.icon,
            title: l.estimateTransportTitle,
            caption: intercityCovered && localCovered ? l.estimateCoveredCaption : l.estimateTransportCaption,
            amount: e.transport,
            share: e.transport / total,
            covered: intercityCovered && localCovered,
            isLast: !hasExtras,
            details: intercityCovered && localCovered
                ? const []
                : [
                    (
                      intercityCovered
                          ? l.estimateCoveredIntercity
                          : e.input.mode == TravelMode.carro
                              ? l.estimateIntercityCarLabel(e.vehicles)
                              : l.estimateIntercityLabel(e.input.mode.label(context).toLowerCase()),
                      intercityCovered ? null : e.intercity,
                    ),
                    (l.estimateLocalTransportLabel, localCovered ? null : e.localTransport),
                  ],
          ),
          if (hasExtras)
            _categoryRow(
              context,
              icon: Icons.local_activity_outlined,
              title: l.estimateExtrasTitle,
              caption: l.estimateExtrasCaption,
              amount: e.extras,
              share: e.extras / total,
              isLast: true,
              details: [
                if (e.tours > 0) (l.estimateExtraTours, e.tours),
                if (e.nightlife > 0) (l.estimateExtraNightlife, e.nightlife),
                if (e.souvenirs > 0) (l.estimateExtraSouvenirs, e.souvenirs),
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
    bool covered = false,
    // Monto `null` = ese detalle está cubierto.
    List<(String, double?)> details = const [],
  }) {
    final coveredTag = context.l10n.estimateCoveredTag;
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
              if (covered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(10)),
                  child: Text(coveredTag, style: AppText.ui(12, weight: FontWeight.w700, color: AppColors.inkSoft)),
                )
              else
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
          if (!covered) ...[
            const SizedBox(height: 10),
            BudgetBar(progress: share.clamp(0.0, 1.0), height: 6),
          ],
          for (final d in details)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(d.$1, style: AppText.ui(12, color: AppColors.textMuted))),
                  const SizedBox(width: 8),
                  Text(
                    d.$2 == null ? coveredTag : context.formatMoney(d.$2!),
                    style: AppText.ui(12, weight: FontWeight.w600, color: d.$2 == null ? AppColors.inkSoft : AppColors.ink),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Detalle Premium ──

  Widget _detail(BuildContext context, BudgetEstimate e) {
    final l = context.l10n;
    return Column(
      children: [
        _Card(
          title: l.estimateDetailTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _stat(context, l.estimatePerPerson, e.perPerson)),
                  const SizedBox(width: 10),
                  Expanded(child: _stat(context, l.estimatePerDay, e.perDay)),
                  const SizedBox(width: 10),
                  Expanded(child: _stat(context, l.estimatePerPersonPerDay, e.perPersonPerDay)),
                ],
              ),
              const SizedBox(height: 16),
              _season(context, e),
              const SizedBox(height: 12),
              _realSeal(context, e),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _compare(context, e),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, double amount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(AppRadius.control)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label(9.5, color: AppColors.textLabel)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(context.formatMoney(amount), style: AppText.ui(15, weight: FontWeight.w700, color: AppColors.ink)),
          ),
        ],
      ),
    );
  }

  Widget _season(BuildContext context, BudgetEstimate e) {
    final l = context.l10n;
    final high = e.seasons.isNotEmpty && e.seasonSurcharge > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: high ? AppColors.warningWash : AppColors.paperDeep,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            high ? Icons.trending_up_rounded : Icons.event_available_outlined,
            size: 20,
            color: high ? AppColors.warning : AppColors.inkSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  high ? l.estimateSeasonTitle : l.estimateSeasonNoneTitle,
                  style: AppText.ui(13, weight: FontWeight.w700, color: high ? AppColors.warning : AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  high
                      ? l.estimateSeasonBody(e.seasons.join(', '), context.formatMoney(e.seasonSurcharge))
                      : l.estimateSeasonNone,
                  style: AppText.ui(12.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Escenario 8: con cuántos viajes reales de la app se ajustó.
  Widget _realSeal(BuildContext context, BudgetEstimate e) {
    final l = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          e.calibrated ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
          size: 18,
          color: e.calibrated ? AppColors.inkSoft : AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            e.calibrated
                ? l.estimateRealSeal(e.realTrips, e.destination.nombre)
                : l.estimateRealNone(e.destination.nombre),
            style: AppText.ui(
              12.5,
              weight: e.calibrated ? FontWeight.w700 : FontWeight.w500,
              color: e.calibrated ? AppColors.inkSoft : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _compare(BuildContext context, BudgetEstimate e) {
    final maxTotal = comparison.values.map((c) => c.total).fold<double>(1, (a, b) => b > a ? b : a);
    return _Card(
      title: context.l10n.estimateCompareTitle,
      child: Column(
        children: [
          for (final style in TripStyle.values)
            if (comparison[style] case final c?)
              Padding(
                padding: EdgeInsets.only(bottom: style == TripStyle.values.last ? 0 : 16),
                child: _compareRow(context, c, current: style == e.style, maxTotal: maxTotal),
              ),
        ],
      ),
    );
  }

  Widget _compareRow(BuildContext context, BudgetEstimate c, {required bool current, required double maxTotal}) {
    final diff = c.total - estimate.total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(c.style.icon, size: 18, color: current ? AppColors.ink : AppColors.inkSoft),
            const SizedBox(width: 8),
            Text(
              c.style.title(context),
              style: AppText.ui(14, weight: current ? FontWeight.w800 : FontWeight.w600),
            ),
            if (current) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(8)),
                child: Text(context.l10n.estimateCompareCurrent, style: AppText.label(8.5, color: AppColors.mint)),
              ),
            ],
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(context.formatMoney(c.total), style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
                if (!current)
                  Text(
                    '${diff > 0 ? '+' : '−'}${context.formatMoney(diff.abs())}',
                    style: AppText.ui(11, weight: FontWeight.w600, color: diff > 0 ? AppColors.warning : AppColors.inkSoft),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        BudgetBar(
          progress: (c.total / maxTotal).clamp(0.0, 1.0),
          height: 6,
          fill: current ? AppColors.ink : AppColors.inkSoft.withValues(alpha: 0.45),
        ),
      ],
    );
  }

  Widget _sources(BuildContext context, BudgetEstimate e) {
    final verified = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(e.verifiedAt);
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
                    border: Border.all(color: AppColors.hair),
                  ),
                  child: Text(s.nombre, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.ink.withValues(alpha: 0.10)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 15, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.estimateVerifiedOn(verified),
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
              context.l10n.estimateDisclaimer(_percent),
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
