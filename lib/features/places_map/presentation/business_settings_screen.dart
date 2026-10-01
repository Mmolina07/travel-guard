import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';

class BusinessSettingsScreen extends StatefulWidget {
  final String initialName;
  final String initialSchedule;
  final String initialContact;

  const BusinessSettingsScreen({
    Key? key,
    required this.initialName,
    required this.initialSchedule,
    required this.initialContact,
  }) : super(key: key);

  @override
  State<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _scheduleController;
  late final TextEditingController _contactController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _scheduleController = TextEditingController(
      text: widget.initialSchedule,
    );

    _contactController = TextEditingController(
      text: widget.initialContact,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final schedule = _scheduleController.text.trim();
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
      {
        'name': name,
        'schedule': schedule,
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

                  TextField(
                    controller: _scheduleController,
                    decoration: InputDecoration(
                      hintText: context.l10n.businessSettingsScheduleHint,
                    ),
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
