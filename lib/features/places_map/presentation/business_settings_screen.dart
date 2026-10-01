import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';

class BusinessSettingsScreen extends StatefulWidget {
  final String initialName;

  /// `comercios.horario_apertura`/`horario_cierre`, como las devuelve
  /// Supabase ("HH:mm:ss"), o `null` si el comercio no las ha definido.
  final String? initialOpenTime;
  final String? initialCloseTime;
  final String initialContact;

  const BusinessSettingsScreen({
    Key? key,
    required this.initialName,
    this.initialOpenTime,
    this.initialCloseTime,
    required this.initialContact,
  }) : super(key: key);

  @override
  State<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _contactController = TextEditingController(
      text: widget.initialContact,
    );

    _openTime = _parseTime(widget.initialOpenTime);
    _closeTime = _parseTime(widget.initialCloseTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// "HH:mm:00", listo para una columna `TIME` de Postgres.
  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _pickTime({required bool isOpenTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isOpenTime ? _openTime : _closeTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isOpenTime) {
        _openTime = picked;
      } else {
        _closeTime = picked;
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.businessSettingsNameRequiredSnackbar),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      <String, String?>{
        'name': name,
        'openTime': _formatTime(_openTime),
        'closeTime': _formatTime(_closeTime),
        'contact': contact,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          context.l10n.businessSettingsAppBarTitle,
          style: AppText.ui(
            18,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.businessSettingsSectionTitle,
                    style: AppText.display(26),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    context.l10n.businessSettingsSectionSubtitle,
                    style: AppText.ui(
                      13,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    context.l10n.businessSettingsNameLabel,
                    style: AppText.ui(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: context.l10n.businessSettingsNameHint,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    context.l10n.businessSettingsScheduleLabel,
                    style: AppText.ui(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: context.l10n.businessSettingsOpenTimeLabel,
                          time: _openTime,
                          onTap: () => _pickTime(isOpenTime: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: context.l10n.businessSettingsCloseTimeLabel,
                          time: _closeTime,
                          onTap: () => _pickTime(isOpenTime: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Text(
                    context.l10n.businessSettingsContactLabel,
                    style: AppText.ui(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: context.l10n.businessSettingsContactHint,
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        context.l10n.businessSettingsSaveButton,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.dateField),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time?.format(context) ?? context.l10n.businessSettingsTimeNotSet,
              style: AppText.ui(15),
            ),
            const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
