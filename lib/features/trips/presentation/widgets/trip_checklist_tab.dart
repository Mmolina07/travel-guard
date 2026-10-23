import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../../widgets/form_section_card.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/load_error_box.dart';
import '../../../../widgets/pressable.dart';
import '../../../expenses/providers/notification_prefs_provider.dart';
import '../../../subscriptions/presentation/widgets/premium_gate.dart';
import '../../data/checklist_repository.dart';
import '../../data/models/checklist_models.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/checklist_suggester.dart';
import '../pages/trip_model.dart';

/// HU-26: pestaña "Pendientes" del detalle del viaje. La lista es del
/// usuario que la ve (personal, también en viajes en grupo). Arriba el
/// progreso y el campo para agregar extras; al lado (o debajo, en
/// móvil) las sugerencias según el viaje y el aviso de recordatorios
/// (Premium). Con el viaje terminado queda de solo lectura.
class TripChecklistTab extends StatefulWidget {
  const TripChecklistTab({
    super.key,
    required this.trip,
    required this.userId,
    this.onSummaryChanged,
  });

  final Trip trip;
  final int userId;

  /// Avisa (pendientes sin marcar, total) cada vez que cambia la lista,
  /// para la tarjeta del resumen del viaje.
  final void Function(int pending, int total)? onSummaryChanged;

  @override
  State<TripChecklistTab> createState() => _TripChecklistTabState();
}

class _TripChecklistTabState extends State<TripChecklistTab> {
  static const _maxTitle = 120;
  static const _collapsedSuggestions = 6;

  final ChecklistRepository _repository = ChecklistRepository();
  final TextEditingController _addController = TextEditingController();
  final FocusNode _addFocus = FocusNode();

  List<ChecklistItem> _items = [];
  bool _loading = true;
  String? _error;
  String? _addError;
  ChecklistCategory _addCategory = ChecklistCategory.otro;
  bool _adding = false;
  bool _showAllSuggestions = false;

  /// Sugerencias que se están guardando (evita el doble toque).
  final Set<String> _busyKeys = {};

  int get _tripId => widget.trip.id!;
  bool get _readOnly => widget.trip.isFinished;

  List<ChecklistItem> get _visible => _items.where((i) => !i.dismissed).toList();
  int get _dismissedCount => _items.where((i) => i.dismissed).length;

  List<ChecklistSuggestion> get _suggestions {
    final used = {for (final i in _items) ?i.suggestionKey};
    return suggestChecklist(widget.trip).where((s) => !used.contains(s.key)).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addController.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repository.fetchItems(tripId: _tripId, userId: widget.userId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      _notifySummary();
    } catch (e, st) {
      debugPrint('TripChecklistTab._load error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = context.l10n.checklistLoadError;
        _loading = false;
      });
    }
  }

  void _notifySummary() {
    final visible = _visible;
    widget.onSummaryChanged?.call(visible.where((i) => !i.done).length, visible.length);
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.checklistSaveError), backgroundColor: AppColors.error),
    );
  }

  // ─── Acciones ───

  Future<void> _addSuggestions(List<ChecklistSuggestion> suggestions) async {
    final l = context.l10n;
    final pending = suggestions.where((s) => !_busyKeys.contains(s.key)).toList();
    if (pending.isEmpty) return;
    setState(() => _busyKeys.addAll(pending.map((s) => s.key)));
    try {
      final added = await _repository.addItems(
        tripId: _tripId,
        userId: widget.userId,
        items: [
          for (final s in pending)
            (title: checklistSuggestionTitle(l, s.key), category: s.category, suggestionKey: s.key),
        ],
      );
      if (!mounted) return;
      setState(() => _items = [..._items, ...added]);
      _notifySummary();
    } catch (e, st) {
      debugPrint('TripChecklistTab._addSuggestions error: $e\n$st');
      _showSaveError();
    } finally {
      if (mounted) setState(() => _busyKeys.removeAll(pending.map((s) => s.key)));
    }
  }

  Future<void> _dismissSuggestion(ChecklistSuggestion s) async {
    if (_busyKeys.contains(s.key)) return;
    setState(() => _busyKeys.add(s.key));
    try {
      final item = await _repository.dismissSuggestion(
        tripId: _tripId,
        userId: widget.userId,
        suggestion: s,
        title: checklistSuggestionTitle(context.l10n, s.key),
      );
      if (!mounted) return;
      setState(() => _items = [..._items, item]);
    } catch (e, st) {
      debugPrint('TripChecklistTab._dismissSuggestion error: $e\n$st');
      _showSaveError();
    } finally {
      if (mounted) setState(() => _busyKeys.remove(s.key));
    }
  }

  Future<void> _restoreDismissed() async {
    final before = _items;
    setState(() => _items = _items.where((i) => !i.dismissed).toList());
    try {
      await _repository.restoreDismissed(tripId: _tripId, userId: widget.userId);
    } catch (e, st) {
      debugPrint('TripChecklistTab._restoreDismissed error: $e\n$st');
      if (mounted) setState(() => _items = before);
      _showSaveError();
    }
  }

  String? _validateTitle(String text) {
    final title = text.trim();
    if (title.isEmpty) return context.l10n.checklistTitleRequired;
    if (title.length > _maxTitle) return context.l10n.checklistTitleTooLong;
    return null;
  }

  Future<void> _addCustom() async {
    final error = _validateTitle(_addController.text);
    setState(() => _addError = error);
    if (error != null || _adding) return;
    setState(() => _adding = true);
    try {
      final added = await _repository.addItems(
        tripId: _tripId,
        userId: widget.userId,
        items: [(title: _addController.text, category: _addCategory, suggestionKey: null)],
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...added];
        _addController.clear();
      });
      _addFocus.requestFocus();
      _notifySummary();
    } catch (e, st) {
      debugPrint('TripChecklistTab._addCustom error: $e\n$st');
      _showSaveError();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  /// Cambio optimista: se ve al instante y se revierte si falla.
  Future<void> _replaceItem(ChecklistItem updated, Future<void> Function() persist) async {
    final before = _items;
    setState(() => _items = [for (final i in _items) i.id == updated.id ? updated : i]);
    _notifySummary();
    try {
      await persist();
    } catch (e, st) {
      debugPrint('TripChecklistTab._replaceItem error: $e\n$st');
      if (!mounted) return;
      setState(() => _items = before);
      _notifySummary();
      _showSaveError();
    }
  }

  void _toggle(ChecklistItem item) {
    if (_readOnly) return;
    final updated = item.copyWith(done: !item.done);
    _replaceItem(updated, () => _repository.setDone(item.id, updated.done));
  }

  Future<void> _delete(ChecklistItem item) async {
    final before = _items;
    setState(() => _items = _items.where((i) => i.id != item.id).toList());
    _notifySummary();
    try {
      await _repository.deleteItem(item.id);
    } catch (e, st) {
      debugPrint('TripChecklistTab._delete error: $e\n$st');
      if (!mounted) return;
      setState(() => _items = before);
      _notifySummary();
      _showSaveError();
    }
  }

  Future<void> _edit(ChecklistItem item) async {
    final result = await showDialog<(String, ChecklistCategory)>(
      context: context,
      builder: (_) => _EditItemDialog(item: item, validate: _validateTitle),
    );
    if (result == null || !mounted) return;
    final (title, category) = result;
    if (title.trim() == item.title && category == item.category) return;
    _replaceItem(
      item.copyWith(title: title.trim(), category: category),
      () => _repository.updateItem(item.id, title: title, category: category),
    );
  }

  // ─── UI ───

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    if (_error != null) {
      return LoadErrorBox(message: _error!, onRetry: _load);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final list = _buildListCard();
        final side = [
          if (!_readOnly) _buildSuggestionsCard(),
          if (!_readOnly && !_tripStarted) ...[
            const SizedBox(height: 16),
            _buildReminderCard(),
          ],
        ];
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: list),
              if (side.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(flex: 2, child: Column(children: side)),
              ],
            ],
          );
        }
        // Móvil: con la lista vacía, las sugerencias van primero.
        final suggestionsFirst = _visible.isEmpty;
        return Column(
          children: [
            if (suggestionsFirst && side.isNotEmpty) ...[...side, const SizedBox(height: 16)],
            list,
            if (!suggestionsFirst && side.isNotEmpty) ...[const SizedBox(height: 16), ...side],
          ],
        );
      },
    );
  }

  bool get _tripStarted {
    final start = parseDdMmYyyy(widget.trip.startDate);
    if (start == null) return false;
    final now = DateTime.now();
    return !start.isAfter(DateTime(now.year, now.month, now.day));
  }

  Widget _buildListCard() {
    final l = context.l10n;
    final visible = _visible;
    final done = visible.where((i) => i.done).length;
    final total = visible.length;
    final remaining = total - done;

    return FormSectionCard(
      title: l.checklistTitle,
      trailing: total == 0
          ? null
          : Text(l.checklistProgress(done, total).toUpperCase(), style: AppText.label(11, color: AppColors.inkSoft)),
      children: [
        if (total > 0) ...[
          BudgetBar(progress: done / total, height: 8, track: AppColors.paperDeep, fill: AppColors.inkSoft),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                remaining == 0 ? Icons.check_circle_rounded : Icons.pending_actions_outlined,
                size: 16,
                color: AppColors.inkSoft,
              ),
              const SizedBox(width: 6),
              Text(
                remaining == 0 ? l.checklistAllDone : l.checklistRemaining(remaining),
                style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (_readOnly)
          _notice(Icons.lock_outline, l.checklistReadOnly)
        else
          _buildAddField(),
        const SizedBox(height: 8),
        if (total == 0 && !_readOnly)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: EmptyStateCard(
              icon: Icons.checklist_rounded,
              title: l.checklistEmptyTitle,
              subtitle: l.checklistEmptySubtitle,
            ),
          ),
        for (final category in ChecklistCategory.values)
          if (visible.any((i) => i.category == category))
            _buildGroup(category, visible.where((i) => i.category == category).toList()),
      ],
    );
  }

  Widget _buildAddField() {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _addController,
                focusNode: _addFocus,
                maxLength: _maxTitle,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addCustom(),
                onChanged: (_) {
                  if (_addError != null) setState(() => _addError = null);
                },
                style: AppText.ui(14, weight: FontWeight.w600),
                decoration: _fieldDecoration(l.checklistAddHint, error: _addError),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: InkButton(
                label: l.checklistAddButton,
                icon: Icons.add,
                loading: _adding,
                onPressed: _adding ? null : _addCustom,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _CategoryPicker(
          selected: _addCategory,
          onSelect: (c) => setState(() => _addCategory = c),
        ),
      ],
    );
  }

  Widget _buildGroup(ChecklistCategory category, List<ChecklistItem> items) {
    final l = context.l10n;
    final done = items.where((i) => i.done).length;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 15, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  checklistCategoryLabel(l, category).toUpperCase(),
                  style: AppText.label(10.5, color: AppColors.textLabel, weight: FontWeight.w600),
                ),
              ),
              Text('$done/${items.length}', style: AppText.label(10.5, color: AppColors.textLabel)),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in items) _buildItemRow(item),
        ],
      ),
    );
  }

  Widget _buildItemRow(ChecklistItem item) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: item.done ? AppColors.paper : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              scale: 0.98,
              onTap: _readOnly ? null : () => _toggle(item),
              semanticLabel: item.title,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  children: [
                    _CheckCircle(done: item.done),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: AppMotion.toggle,
                        curve: AppMotion.press,
                        style: AppText.ui(
                          14,
                          weight: FontWeight.w600,
                          color: item.done ? AppColors.textMuted : AppColors.ink,
                        ).copyWith(
                          decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
                          decorationColor: AppColors.textMuted,
                        ),
                        child: Text(item.title),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_readOnly)
            PopupMenuButton<String>(
              tooltip: l.checklistMoreTooltip,
              icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.textMuted),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
              onSelected: (v) => v == 'edit' ? _edit(item) : _delete(item),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l.checklistEdit, style: AppText.ui(14))),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l.checklistDelete, style: AppText.ui(14, color: AppColors.error)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    final l = context.l10n;
    final all = _suggestions;
    final shown = _showAllSuggestions || all.length <= _collapsedSuggestions
        ? all
        : all.take(_collapsedSuggestions).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: AnimatedSize(
        duration: AppMotion.listItem,
        curve: AppMotion.press,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.inkSoft),
                const SizedBox(width: 8),
                Expanded(child: Text(l.checklistSuggestionsTitle, style: AppText.display(22))),
              ],
            ),
            const SizedBox(height: 4),
            Text(l.checklistSuggestionsSubtitle, style: AppText.ui(13, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            if (all.isEmpty)
              _notice(Icons.check_circle_outline, l.checklistSuggestionsDone)
            else ...[
              for (final s in shown) _buildSuggestionRow(s),
              if (all.length > _collapsedSuggestions && !_showAllSuggestions)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAllSuggestions = true),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('+${all.length - _collapsedSuggestions}'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft),
                  ),
                ),
              const SizedBox(height: 12),
              InkButton(
                label: l.checklistAddAll(all.length),
                icon: Icons.playlist_add_rounded,
                variant: InkButtonVariant.secondary,
                expand: true,
                onPressed: _busyKeys.isNotEmpty ? null : () => _addSuggestions(all),
              ),
            ],
            if (_dismissedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextButton(
                  onPressed: _restoreDismissed,
                  style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                  child: Text(l.checklistShowDismissed(_dismissedCount), style: AppText.ui(12, color: AppColors.textMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionRow(ChecklistSuggestion s) {
    final l = context.l10n;
    final busy = _busyKeys.contains(s.key);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(s.category.icon, size: 17, color: AppColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(child: Text(checklistSuggestionTitle(l, s.key), style: AppText.ui(13, weight: FontWeight.w600))),
          IconButton(
            tooltip: l.checklistDismissTooltip,
            onPressed: busy ? null : () => _dismissSuggestion(s),
            icon: const Icon(Icons.close_rounded, size: 17, color: AppColors.textMuted),
            visualDensity: VisualDensity.compact,
          ),
          Pressable(
            onTap: busy ? null : () => _addSuggestions([s]),
            semanticLabel: l.checklistAddSuggestionTooltip,
            child: Tooltip(
              message: l.checklistAddSuggestionTooltip,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: busy ? AppColors.textMuted : AppColors.ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paper),
                      )
                    : const Icon(Icons.add, size: 18, color: AppColors.mint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recordatorios automáticos antes del viaje (Premium, HU-11/HU-24).
  Widget _buildReminderCard() {
    final l = context.l10n;
    final enabled = context.watch<NotificationPrefsProvider>().checklistReminder;
    return PremiumGate(
      compact: true,
      icon: Icons.notifications_active_outlined,
      title: l.checklistReminderGateTitle,
      description: l.checklistReminderGateDescription,
      child: _notice(
        enabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
        enabled ? l.checklistReminderInfo : l.checklistReminderOff,
        background: AppColors.surface,
      ),
    );
  }

  Widget _notice(IconData icon, String text, {Color background = AppColors.paperDeep}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.ui(13, color: AppColors.textMuted))),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hint, {String? error}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.ui(14, color: AppColors.textMuted),
    errorText: error,
    counterText: '',
    filled: true,
    fillColor: AppColors.paperDeep,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.dateField),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.dateField),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    ),
  );
}

/// Círculo de marcado: borde `hair` vacío, `inkSoft` con chulo al marcar.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.toggle,
      curve: AppMotion.press,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.inkSoft : Colors.transparent,
        border: Border.all(color: done ? AppColors.inkSoft : AppColors.hair, width: 1.6),
      ),
      child: AnimatedScale(
        scale: done ? 1 : 0,
        duration: AppMotion.chip,
        curve: AppMotion.enter,
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      ),
    );
  }
}

/// Chips de categoría (borde `hair`, seleccionada en `ink`).
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onSelect});

  final ChecklistCategory selected;
  final ValueChanged<ChecklistCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final c in ChecklistCategory.values)
          Pressable(
            onTap: () => onSelect(c),
            semanticLabel: checklistCategoryLabel(l, c),
            child: AnimatedContainer(
              duration: AppMotion.toggle,
              curve: AppMotion.press,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c == selected ? AppColors.ink : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(color: c == selected ? AppColors.ink : AppColors.hair),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon, size: 14, color: c == selected ? AppColors.mint : AppColors.inkSoft),
                  const SizedBox(width: 5),
                  Text(
                    checklistCategoryLabel(l, c),
                    style: AppText.ui(12, weight: FontWeight.w600, color: c == selected ? AppColors.paper : AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  const _EditItemDialog({required this.item, required this.validate});

  final ChecklistItem item;
  final String? Function(String) validate;

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.item.title);
  late ChecklistCategory _category = widget.item.category;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final error = widget.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, (_controller.text, _category));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.cardLg)),
      title: Text(l.checklistEditTitle, style: AppText.display(26)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: _TripChecklistTabState._maxTitle,
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              style: AppText.ui(14, weight: FontWeight.w600),
              decoration: _fieldDecoration(l.checklistAddHint, error: _error),
            ),
            const SizedBox(height: 10),
            _CategoryPicker(selected: _category, onSelect: (c) => setState(() => _category = c)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: Text(l.checklistCancel),
        ),
        InkButton(label: l.checklistSave, onPressed: _save),
      ],
    );
  }
}

String checklistCategoryLabel(AppLocalizations l, ChecklistCategory c) => switch (c) {
      ChecklistCategory.documentos => l.checklistCategoryDocumentos,
      ChecklistCategory.dinero => l.checklistCategoryDinero,
      ChecklistCategory.equipaje => l.checklistCategoryEquipaje,
      ChecklistCategory.salud => l.checklistCategorySalud,
      ChecklistCategory.tecnologia => l.checklistCategoryTecnologia,
      ChecklistCategory.reservas => l.checklistCategoryReservas,
      ChecklistCategory.casa => l.checklistCategoryCasa,
      ChecklistCategory.otro => l.checklistCategoryOtro,
    };

/// Texto traducido de una sugerencia de `suggestChecklist`. Al agregarla
/// se guarda este texto como título del pendiente.
String checklistSuggestionTitle(AppLocalizations l, String key) => switch (key) {
      'doc_id' => l.checklistSugDocId,
      'doc_license' => l.checklistSugDocLicense,
      'doc_soat' => l.checklistSugDocSoat,
      'doc_work' => l.checklistSugDocWork,
      'money_cash' => l.checklistSugMoneyCash,
      'money_cards' => l.checklistSugMoneyCards,
      'money_bank_notice' => l.checklistSugMoneyBankNotice,
      'money_tolls' => l.checklistSugMoneyTolls,
      'bag_pack' => l.checklistSugBagPack,
      'bag_extra_clothes' => l.checklistSugBagExtraClothes,
      'bag_liquids' => l.checklistSugBagLiquids,
      'bag_swimsuit' => l.checklistSugBagSwimsuit,
      'bag_sunglasses' => l.checklistSugBagSunglasses,
      'bag_jacket' => l.checklistSugBagJacket,
      'bag_umbrella' => l.checklistSugBagUmbrella,
      'health_meds' => l.checklistSugHealthMeds,
      'health_sunscreen' => l.checklistSugHealthSunscreen,
      'health_repellent' => l.checklistSugHealthRepellent,
      'tech_charger' => l.checklistSugTechCharger,
      'tech_powerbank' => l.checklistSugTechPowerbank,
      'tech_laptop' => l.checklistSugTechLaptop,
      'book_lodging' => l.checklistSugBookLodging,
      'book_checkin' => l.checklistSugBookCheckin,
      'book_boarding_pass' => l.checklistSugBookBoardingPass,
      'book_airport_early' => l.checklistSugBookAirportEarly,
      'book_bus_tickets' => l.checklistSugBookBusTickets,
      'home_unplug' => l.checklistSugHomeUnplug,
      'home_care' => l.checklistSugHomeCare,
      'other_car_check' => l.checklistSugOtherCarCheck,
      'other_group' => l.checklistSugOtherGroup,
      'other_itinerary' => l.checklistSugOtherItinerary,
      _ => key,
    };
