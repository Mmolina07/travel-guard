import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import '../../../../core/widgets/underline_field.dart';
import '../../../places_map/data/geocoding_service.dart';
import '../../../places_map/presentation/home_screen_comercio.dart';
import '../../../places_map/presentation/widgets/location_picker_field.dart';
import '../../providers/app_auth_provider.dart';

class ComercioRegisterScreen extends StatefulWidget {
  const ComercioRegisterScreen({Key? key}) : super(key: key);

  @override
  State<ComercioRegisterScreen> createState() =>
      _ComercioRegisterScreenState();
}

class _ComercioRegisterScreenState extends State<ComercioRegisterScreen> {
  late TextEditingController _nitController;
  late TextEditingController _nameController;
  late TextEditingController _directionController;
  late TextEditingController _phoneController;
  late TextEditingController _sedeController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleAccount = false;
  bool _isGeocoding = false;
  LatLng? _comercioLocation;
  final GeocodingService _geocodingService = GeocodingService();

  @override
  void initState() {
    super.initState();
    _nitController = TextEditingController();
    _nameController = TextEditingController();
    _directionController = TextEditingController();
    _phoneController = TextEditingController();
    _sedeController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nitController.dispose();
    _nameController.dispose();
    _directionController.dispose();
    _phoneController.dispose();
    _sedeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final success = _isGoogleAccount
        ? await auth.completeComercioGoogleRegistration(
            nombreComercio: _nameController.text.trim(),
            nit: _nitController.text.trim(),
            direccion: _directionController.text.trim(),
            telefono: _phoneController.text.trim(),
            sede: _sedeController.text.trim(),
            latitud: _comercioLocation?.latitude,
            longitud: _comercioLocation?.longitude,
          )
        : await auth.registerComercio(
            nombreComercio: _nameController.text.trim(),
            nit: _nitController.text.trim(),
            direccion: _directionController.text.trim(),
            telefono: _phoneController.text.trim(),
            sede: _sedeController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            latitud: _comercioLocation?.latitude,
            longitud: _comercioLocation?.longitude,
          );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      _showError(auth.errorMessage ?? context.l10n.commonRegisterErrorGeneric);
      return;
    }

    // SnackBar de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.commerceRegisterSuccessSnackbar),
        backgroundColor: Colors.green,
      ),
    );

    // Navegar SOLO si la validación pasó
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreenComercio(),
      ),
    );
  }

  void _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final user = await auth.beginGoogleSignIn(context);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      if (auth.errorMessage != null) _showError(auth.errorMessage!);
      return; // Cancelado por el usuario: no hay error que mostrar.
    }

    final displayName = user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String?;
    setState(() {
      _isGoogleAccount = true;
      _nameController.text = displayName ?? _nameController.text;
      _emailController.text = user.email ?? _emailController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.commerceRegisterGoogleVerifiedSnackbar),
      ),
    );
  }

  bool _validateForm() {
    // Escenario 6 de HU-02: campos obligatorios vacíos.
    final camposVacios = _nitController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _directionController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _sedeController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        (!_isGoogleAccount &&
            (_passwordController.text.isEmpty ||
                _confirmPasswordController.text.isEmpty));
    if (camposVacios) {
      _showError(context.l10n.commerceRegisterFieldsRequired);
      return false;
    }

    // HU-07: sin ubicación, el comercio nunca aparece en el mapa.
    if (_comercioLocation == null) {
      _showError(context.l10n.commerceRegisterLocationRequired);
      return false;
    }

    // Escenario 4 de HU-02: formato de NIT (la duplicidad la valida el
    // backend en AppAuthProvider.registerComercio).
    if (!_isValidNit(_nitController.text)) {
      _showError(context.l10n.commerceRegisterNitInvalid);
      return false;
    }

    // Escenario 2 de HU-02: formato de email (la duplicidad la valida el
    // backend en AppAuthProvider.registerComercio).
    if (!_isValidEmail(_emailController.text)) {
      _showError(context.l10n.commerceRegisterEmailInvalidOrTaken);
      return false;
    }

    if (_isGoogleAccount) return true; // Ya autenticado, sin contraseña.

    // HU-02 Escenario 1: mínimo 8 caracteres.
    if (_passwordController.text.length < 8) {
      _showError(context.l10n.commerceRegisterPasswordMin);
      return false;
    }
    // Escenario 3 de HU-02.
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError(context.l10n.commonPasswordsMismatch);
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool _isValidNit(String nit) {
    final RegExp nitRegex = RegExp(r'^\d{5,15}(-\d)?$');
    return nitRegex.hasMatch(nit.trim());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Busca [address] con [GeocodingService] y, si encuentra un punto,
  /// mueve el mapa de "Ubicación del negocio" ahí solo (HU-02 + HU-07):
  /// sin esto, el comercio tenía que buscar manualmente su ubicación en
  /// el mapa aunque ya hubiera escrito la dirección completa.
  Future<void> _geocodeAddress(String address) async {
    if (address.trim().isEmpty || _isGeocoding) return;
    setState(() => _isGeocoding = true);
    final location = await _geocodingService.geocodeAddress(address);
    if (!mounted) return;
    setState(() => _isGeocoding = false);

    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.commerceRegisterGeocodeNotFound),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _comercioLocation = location);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.commerceRegisterGeocodeFound),
        backgroundColor: AppColors.ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: context.l10n.commerceRegisterTitle,
      subtitle: context.l10n.commerceRegisterSubtitle,
      maxContentWidth: 560,
      content: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UnderlineField(
                  label: context.l10n.commerceRegisterNitLabel,
                  hint: context.l10n.commerceRegisterNitHint,
                  controller: _nitController,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commerceRegisterNameLabel,
                  hint: context.l10n.commerceRegisterNameHint,
                  controller: _nameController,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commerceRegisterAddressLabel,
                  hint: context.l10n.commerceRegisterAddressHint,
                  controller: _directionController,
                  enabled: !_isLoading,
                  onFieldSubmitted: _geocodeAddress,
                  helperText: context.l10n.commerceRegisterAddressHelper,
                  trailing: IconButton(
                    icon: _isGeocoding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    tooltip: context.l10n.commerceRegisterAddressSearchTooltip,
                    onPressed: _isLoading || _isGeocoding
                        ? null
                        : () => _geocodeAddress(_directionController.text),
                  ),
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commerceRegisterPhoneLabel,
                  hint: context.l10n.commerceRegisterPhoneHint,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commerceRegisterSedeLabel,
                  hint: context.l10n.commerceRegisterSedeHint,
                  controller: _sedeController,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                Text(context.l10n.commerceRegisterLocationLabel, style: AppText.label(10)),
                const SizedBox(height: 8),
                LocationPickerField(
                  initialLocation: _comercioLocation,
                  onLocationSelected: (latLng) =>
                      setState(() => _comercioLocation = latLng),
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commonEmailLabel,
                  hint: context.l10n.commonEmailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commonPasswordLabel,
                  hint: '••••••••',
                  controller: _passwordController,
                  obscure: !_isPasswordVisible,
                  enabled: !_isLoading,
                  helperText: context.l10n.commerceRegisterPasswordHelper,
                  trailing: UnderlineFieldPasswordToggle(
                    visible: _isPasswordVisible,
                    onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                const SizedBox(height: 20),
                UnderlineField(
                  label: context.l10n.commonConfirmPasswordLabel,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscure: !_isPasswordVisible,
                  enabled: !_isLoading,
                ),
              ],
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(context.l10n.commonRegisterButton),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  context.l10n.commerceRegisterOr,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleRegister,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(
                _isGoogleAccount
                    ? context.l10n.commerceRegisterGoogleVerified
                    : context.l10n.commerceRegisterGoogleVerify,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.commonTermsNotice,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
