import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';
import '../data/geocoding_service.dart';
import '../../../widgets/form_section_card.dart';
import '../../../widgets/ink_button.dart';
import '../../../widgets/ink_header.dart';
import '../../../widgets/pressable.dart';
import 'widgets/location_picker_field.dart';

/// Lo que devuelve [BusinessSettingsScreen] al guardar, ya validado.
class BusinessSettingsResult {
  const BusinessSettingsResult({
    required this.name,
    required this.contact,
    required this.description,
    required this.address,
    required this.location,
    required this.openTime,
    required this.closeTime,
    this.newPhoto,
    this.newPhotoContentType,
    this.removePhoto = false,
  });

  final String name;
  final String contact;
  final String description;
  final String address;
  final LatLng location;

  /// "HH:mm:00" (columna `TIME`), o `null` si no tiene horario.
  final String? openTime;
  final String? closeTime;

  /// Foto de portada nueva, todavía sin subir (la sube quien guarda).
  final Uint8List? newPhoto;
  final String? newPhotoContentType;

  /// El comercio quitó la foto que tenía.
  final bool removePhoto;
}

/// HU-20 CA7–CA10: editar datos generales, horario y ubicación del
/// comercio. Lo que se guarda es lo que el turista ve en el mapa
/// (CA11), así que no se deja salir con datos inválidos ni con una
/// dirección que no se puede ubicar.
class BusinessSettingsScreen extends StatefulWidget {
  final String initialName;

  /// `comercios.horario_apertura`/`horario_cierre`, como las devuelve
  /// Supabase ("HH:mm:ss"), o `null` si el comercio no las ha definido.
  final String? initialOpenTime;
  final String? initialCloseTime;
  final String initialContact;
  final String initialDescription;
  final String initialAddress;
  final LatLng? initialLocation;

  /// Foto de portada actual (`comercios.foto_url`), la que ve el viajero.
  final String? initialPhotoUrl;

  const BusinessSettingsScreen({
    Key? key,
    required this.initialName,
    this.initialOpenTime,
    this.initialCloseTime,
    required this.initialContact,
    this.initialDescription = '',
    this.initialAddress = '',
    this.initialLocation,
    this.initialPhotoUrl,
  }) : super(key: key);

  @override
  State<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _geocodingService = GeocodingService();

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  LatLng? _location;

  /// Dirección a la que corresponde [_location]. Si el texto de la
  /// dirección cambia, hay que volver a ubicarla antes de guardar.
  String? _locatedAddress;
  bool _isGeocoding = false;
  String? _addressError;
  String? _scheduleError;

  // Foto de portada.
  static const _maxPhotoBytes = 5 * 1024 * 1024;
  static const _allowedPhotoTypes = {'image/jpeg', 'image/png', 'image/webp'};
  Uint8List? _newPhoto;
  String? _newPhotoType;
  bool _removePhoto = false;
  bool _pickingPhoto = false;
  String? _photoError;

  bool get _hasPhoto => _newPhoto != null || (widget.initialPhotoUrl != null && !_removePhoto);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _contactController = TextEditingController(text: widget.initialContact);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _addressController = TextEditingController(text: widget.initialAddress);
    _openTime = _parseTime(widget.initialOpenTime);
    _closeTime = _parseTime(widget.initialCloseTime);
    _location = widget.initialLocation;
    if (_location != null) _locatedAddress = widget.initialAddress.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
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
      _scheduleError = null;
    });
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _pickingPhoto = true;
      _photoError = null;
    });
    try {
      // Se reduce antes de subir: una portada no necesita más de 1600 px.
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      final type = _photoType(file);
      if (!mounted) return;
      if (type == null) {
        setState(() => _photoError = context.l10n.businessSettingsPhotoInvalidType);
        return;
      }
      if (bytes.length > _maxPhotoBytes) {
        setState(() => _photoError = context.l10n.businessSettingsPhotoTooLarge);
        return;
      }
      setState(() {
        _newPhoto = bytes;
        _newPhotoType = type;
        _removePhoto = false;
      });
    } catch (e) {
      debugPrint('BusinessSettingsScreen._pickPhoto error: $e');
      if (mounted) setState(() => _photoError = context.l10n.businessSettingsPhotoPickError);
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  /// Tipo MIME de la imagen elegida (por el que reporta el navegador o
  /// por la extensión); `null` si no es JPG, PNG ni WebP.
  String? _photoType(XFile file) {
    final reported = file.mimeType;
    if (reported != null && _allowedPhotoTypes.contains(reported)) return reported;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }

  void _clearPhoto() => setState(() {
        _newPhoto = null;
        _newPhotoType = null;
        _removePhoto = widget.initialPhotoUrl != null;
        _photoError = null;
      });

  /// Ubica la dirección escrita y mueve el mapa ahí. Devuelve `false`
  /// si no se pudo localizar (CA10).
  Future<bool> _locateAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty || _isGeocoding) return false;
    setState(() {
      _isGeocoding = true;
      _addressError = null;
    });
    final location = await _geocodingService.geocodeAddress(address);
    if (!mounted) return false;
    setState(() {
      _isGeocoding = false;
      if (location == null) {
        _addressError = context.l10n.businessSettingsAddressNotFound;
      } else {
        _location = location;
        _locatedAddress = address;
      }
    });
    return location != null;
  }

  String? _validateSchedule() {
    final open = _openTime;
    final close = _closeTime;
    if (open == null && close == null) return null;
    if (open == null || close == null) {
      return context.l10n.businessSettingsScheduleIncomplete;
    }
    if (open == close) return context.l10n.businessSettingsScheduleSameTime;
    return null;
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final scheduleError = _validateSchedule();
    setState(() => _scheduleError = scheduleError);
    if (!formOk || scheduleError != null) return;

    // CA9/CA10: si la dirección cambió, tiene que poder ubicarse en el
    // mapa; si no, no se guarda nada.
    final address = _addressController.text.trim();
    if (_location == null || address != _locatedAddress) {
      final located = await _locateAddress();
      if (!located || !mounted) return;
    }

    Navigator.pop(
      context,
      BusinessSettingsResult(
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        description: _descriptionController.text.trim(),
        address: address,
        location: _location!,
        openTime: _formatTime(_openTime),
        closeTime: _formatTime(_closeTime),
        newPhoto: _newPhoto,
        newPhotoContentType: _newPhotoType,
        removePhoto: _removePhoto,
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? context.l10n.productFormRequiredField : null;

  /// Vista previa como la tarjeta destacada que ve el viajero (16:9,
  /// radio 28).
  Widget _buildPhotoPreview() {
    final Widget content;
    if (_newPhoto != null) {
      content = Image.memory(_newPhoto!, fit: BoxFit.cover);
    } else if (widget.initialPhotoUrl != null && !_removePhoto) {
      content = Image.network(
        widget.initialPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _photoPlaceholder(),
      );
    } else {
      content = _photoPlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.cardLg),
      child: AspectRatio(aspectRatio: 16 / 9, child: content),
    );
  }

  Widget _photoPlaceholder() => ColoredBox(
        color: AppColors.wash,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 36, color: AppColors.inkSoft),
              const SizedBox(height: 8),
              Text(
                context.l10n.businessSettingsPhotoEmpty.toUpperCase(),
                style: AppText.label(10, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkHeader(
              eyebrow: l10n.businessSettingsAppBarTitle,
              title: l10n.businessSettingsHeaderTitle,
              titleAccent: l10n.businessSettingsHeaderAccent,
              subtitle: l10n.businessSettingsSectionSubtitle,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormSectionCard(
                          title: l10n.businessSettingsPhotoTitle,
                          subtitle: l10n.businessSettingsPhotoSubtitle,
                          children: [
                            _buildPhotoPreview(),
                            if (_photoError != null) FieldErrorText(_photoError!),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                InkButton(
                                  label: _hasPhoto
                                      ? l10n.businessSettingsPhotoChange
                                      : l10n.businessSettingsPhotoUpload,
                                  icon: Icons.add_photo_alternate_outlined,
                                  variant: InkButtonVariant.secondary,
                                  loading: _pickingPhoto,
                                  onPressed: _pickPhoto,
                                ),
                                if (_hasPhoto)
                                  InkButton(
                                    label: l10n.businessSettingsPhotoRemove,
                                    icon: Icons.delete_outline,
                                    variant: InkButtonVariant.danger,
                                    onPressed: _clearPhoto,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.businessSettingsPhotoHint.toUpperCase(),
                              style: AppText.label(10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        FormSectionCard(
                          title: l10n.businessSettingsSectionTitle,
                          children: [
                            FieldLabel('${l10n.businessSettingsNameLabel} *'),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                AppInputFormatters.safeText,
                                AppInputFormatters.maxLength(150),
                              ],
                              decoration: InputDecoration(hintText: l10n.businessSettingsNameHint),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return l10n.businessSettingsNameRequiredSnackbar;
                                if (value.length < 3) return l10n.businessSettingsNameTooShort;
                                return Validators.title(context, value, max: 150);
                              },
                            ),
                            const SizedBox(height: 18),
                            FieldLabel('${l10n.businessSettingsContactLabel} *'),
                            TextFormField(
                              controller: _contactController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                AppInputFormatters.phone,
                                AppInputFormatters.maxLength(20),
                              ],
                              decoration: InputDecoration(
                                hintText: l10n.businessSettingsContactHint,
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return l10n.productFormRequiredField;
                                final digits = value.replaceAll(RegExp(r'\D'), '');
                                final allowed = RegExp(r'^\+?[\d\s\-()]+$').hasMatch(value);
                                if (!allowed || digits.length < 7 || digits.length > 15) {
                                  return l10n.businessSettingsPhoneInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            FieldLabel(l10n.businessSettingsScheduleLabel),
                            Row(
                              children: [
                                Expanded(
                                  child: _TimeField(
                                    label: l10n.businessSettingsOpenTimeLabel,
                                    time: _openTime,
                                    hasError: _scheduleError != null,
                                    onTap: () => _pickTime(isOpenTime: true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TimeField(
                                    label: l10n.businessSettingsCloseTimeLabel,
                                    time: _closeTime,
                                    hasError: _scheduleError != null,
                                    onTap: () => _pickTime(isOpenTime: false),
                                  ),
                                ),
                              ],
                            ),
                            if (_scheduleError != null) FieldErrorText(_scheduleError!),
                            const SizedBox(height: 18),
                            FieldLabel(l10n.businessSettingsDescriptionLabel),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              maxLength: 500,
                              inputFormatters: [AppInputFormatters.safeText],
                              validator: (v) => Validators.freeText(context, v, max: 500),
                              decoration: InputDecoration(hintText: l10n.businessSettingsDescriptionHint),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        FormSectionCard(
                          title: l10n.businessSettingsLocationTitle,
                          subtitle: l10n.businessSettingsLocationSubtitle,
                          children: [
                            FieldLabel('${l10n.commerceRegisterAddressLabel} *'),
                            TextFormField(
                              controller: _addressController,
                              textInputAction: TextInputAction.search,
                              onFieldSubmitted: (_) => _locateAddress(),
                              onChanged: (_) {
                                if (_addressError != null) setState(() => _addressError = null);
                              },
                              inputFormatters: [
                                AppInputFormatters.safeText,
                                AppInputFormatters.maxLength(255),
                              ],
                              validator: (v) =>
                                  _required(v) ?? Validators.title(context, v, min: 5, max: 255),
                              decoration: InputDecoration(
                                hintText: l10n.commerceRegisterAddressHint,
                                prefixIcon: const Icon(Icons.location_on_outlined),
                                errorText: _addressError,
                                errorMaxLines: 3,
                                suffixIcon: _isGeocoding
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : IconButton(
                                        tooltip: l10n.commerceRegisterAddressSearchTooltip,
                                        icon: const Icon(Icons.search_rounded),
                                        onPressed: _locateAddress,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            LocationPickerField(
                              initialLocation: _location,
                              // Ajustar el marcador no "valida" la dirección: si
                              // el texto cambió sin buscarlo, al guardar se ubica
                              // igual (y si no se encuentra, no se guarda).
                              onLocationSelected: (latLng) => setState(() => _location = latLng),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        InkButton(
                          label: l10n.businessSettingsSaveButton,
                          trailingArrow: true,
                          expand: true,
                          loading: _isGeocoding,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    this.hasError = false,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: InputDecorator(
        // `errorText: ''` pinta el borde de error sin texto propio: el
        // mensaje va una sola vez debajo de los dos campos.
        decoration: InputDecoration(
          labelText: label,
          errorText: hasError ? '' : null,
          errorStyle: AppText.ui(0, height: 0),
        ),
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
