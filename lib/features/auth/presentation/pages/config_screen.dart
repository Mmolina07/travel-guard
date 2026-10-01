import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../trips/presentation/pages/home_screen_client.dart';
import 'package:go_router/go_router.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late String _selectedLanguage;
  late String _selectedCurrency;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    // TODO: Obtener valores reales de SharedPreferences o Provider
    _selectedLanguage = 'es'; // español
    _selectedCurrency = 'COP';
    _notificationsEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: AppText.ui(18, weight: FontWeight.w600),
        ),
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreenClient()));},
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== SECCIÓN: IDIOMA Y REGIÓN ==========
                Text(
                  'Idioma y región',
                  style: AppText.ui(14, weight: FontWeight.w600, color: AppColors.textLabel),
                ),
                const SizedBox(height: 12),

                // Selector de Idioma
                _SettingCard(
                  icon: Icons.language,
                  label: 'Idioma',
                  value: _getLanguageName(_selectedLanguage),
                  onTap: () => _showLanguageBottomSheet(context),
                ),
                const SizedBox(height: 12),

                // Selector de Moneda
                _SettingCard(
                  icon: Icons.currency_exchange,
                  label: 'Moneda',
                  value: _selectedCurrency,
                  onTap: () => _showCurrencyBottomSheet(context),
                ),
                const SizedBox(height: 32),

                // ========== SECCIÓN: NOTIFICACIONES ==========
                Text(
                  'Notificaciones',
                  style: AppText.ui(14, weight: FontWeight.w600, color: AppColors.textLabel),
                ),
                const SizedBox(height: 12),

                // Toggle Notificaciones
                _SettingToggle(
                  icon: Icons.notifications_outlined,
                  label: 'Activar notificaciones',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // TODO: Guardar en SharedPreferences o Provider
                  },
                ),
                const SizedBox(height: 32),

                Text(
                  'Plan y suscripción',
                  style: AppText.ui(14, weight: FontWeight.w600, color: AppColors.textLabel),
                ),
                const SizedBox(height: 12),

                // Botón Ver planes
                _ActionButton(
                  icon: Icons.card_membership,
                  label: 'Mejora tu plan',
                  onTap: _openSubscriptions,
                ),
                const SizedBox(height: 32),

                // ========== SECCIÓN: SEGURIDAD ==========
                Text(
                  'Seguridad',
                  style: AppText.ui(14, weight: FontWeight.w600, color: AppColors.textLabel),
                ),
                const SizedBox(height: 12),

                // Botón Cambiar Contraseña
                _ActionButton(
                  icon: Icons.lock_outline,
                  label: 'Cambiar contraseña',
                  onTap: () {
                    _showChangePasswordModal(context, auth);
                  },
                ),
                const SizedBox(height: 12),

                // Botón Cerrar Sesión
                _ActionButton(
                  icon: Icons.logout,
                  label: 'Cerrar sesión',
                  isDestructive: true,
                  onTap: () {
                    _showLogoutDialog(context, auth);
                  },
                ),
                const SizedBox(height: 40),

                // ========== FOOTER CON VERSIÓN ==========
                Center(
                  child: Text(
                    'Versión 1.0.0',
                    style: AppText.label(10, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSubscriptions() => context.go('/suscripciones');

  // ========== MODAL: CAMBIAR CONTRASEÑA ==========
  void _showChangePasswordModal(BuildContext context, AppAuthProvider auth) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showPassword = false;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          title: Text(
            'Cambiar contraseña',
            style: AppText.display(18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensaje de error (si existe)
                if (errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage!,
                      style: AppText.ui(12, color: Colors.red[600]!),
                    ),
                  ),
                ],

                // Campo: Contraseña actual
                Text(
                  'Contraseña actual',
                  style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: currentPasswordController,
                  obscureText: !showPassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu contraseña actual',
                    hintStyle: AppText.ui(13, color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.inkSoft, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.paper,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: AppText.ui(13),
                ),
                const SizedBox(height: 16),

                // Campo: Nueva contraseña
                Text(
                  'Nueva contraseña',
                  style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showPassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu nueva contraseña',
                    hintStyle: AppText.ui(13, color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.inkSoft, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.paper,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: AppText.ui(13),
                ),
                const SizedBox(height: 16),

                // Campo: Confirmar contraseña
                Text(
                  'Confirmar contraseña',
                  style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showPassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Confirma tu nueva contraseña',
                    hintStyle: AppText.ui(13, color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.inkSoft, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.paper,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: AppText.ui(13),
                ),
                const SizedBox(height: 12),

                // Checkbox: Mostrar contraseña
                Row(
                  children: [
                    Checkbox(
                      value: showPassword,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setDialogState(() {
                                showPassword = value ?? false;
                              });
                            },
                      activeColor: AppColors.inkSoft,
                    ),
                    Text(
                      'Mostrar contraseña',
                      style: AppText.ui(12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: AppText.ui(14, color: AppColors.ink),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validaciones
                      if (currentPasswordController.text.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'Ingresa tu contraseña actual';
                        });
                        return;
                      }
                      if (newPasswordController.text.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'Ingresa tu nueva contraseña';
                        });
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        setDialogState(() {
                          errorMessage = 'La contraseña debe tener al menos 6 caracteres';
                        });
                        return;
                      }
                      if (newPasswordController.text != confirmPasswordController.text) {
                        setDialogState(() {
                          errorMessage = 'Las contraseñas no coinciden';
                        });
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        // TODO: Llamar al servicio de cambio de contraseña
                        // await auth.changePassword(
                        //   currentPassword: currentPasswordController.text,
                        //   newPassword: newPasswordController.text,
                        // );

                        // Simulación de éxito
                        await Future.delayed(const Duration(seconds: 1));

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Contraseña actualizada correctamente',
                                style: AppText.ui(13, color: AppColors.paper),
                              ),
                              backgroundColor: Colors.green[600],
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          errorMessage = 'Error al cambiar la contraseña: $e';
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.inkSoft),
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: AppText.ui(14, color: AppColors.inkSoft, weight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== BOTTOM SHEETS ==========

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.card),
          topRight: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona idioma',
              style: AppText.display(20),
            ),
            const SizedBox(height: 24),
            _LanguageOption(
              language: 'Español',
              code: 'es',
              isSelected: _selectedLanguage == 'es',
              onTap: () {
                setState(() {
                  _selectedLanguage = 'es';
                });
                Navigator.pop(context);
                // TODO: Cambiar idioma en la app
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              language: 'English',
              code: 'en',
              isSelected: _selectedLanguage == 'en',
              onTap: () {
                setState(() {
                  _selectedLanguage = 'en';
                });
                Navigator.pop(context);
                // TODO: Cambiar idioma en la app
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              language: 'Português',
              code: 'pt',
              isSelected: _selectedLanguage == 'pt',
              onTap: () {
                setState(() {
                  _selectedLanguage = 'pt';
                });
                Navigator.pop(context);
                // TODO: Cambiar idioma en la app
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.card),
          topRight: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona moneda',
              style: AppText.display(20),
            ),
            const SizedBox(height: 24),
            _CurrencyOption(
              currency: 'Peso Colombiano',
              code: 'COP',
              isSelected: _selectedCurrency == 'COP',
              onTap: () {
                setState(() {
                  _selectedCurrency = 'COP';
                });
                Navigator.pop(context);
                // TODO: Cambiar moneda en la app
              },
            ),
            const SizedBox(height: 12),
            _CurrencyOption(
              currency: 'Dólar estadounidense',
              code: 'USD',
              isSelected: _selectedCurrency == 'USD',
              onTap: () {
                setState(() {
                  _selectedCurrency = 'USD';
                });
                Navigator.pop(context);
                // TODO: Cambiar moneda en la app
              },
            ),
            const SizedBox(height: 12),
            _CurrencyOption(
              currency: 'Euro',
              code: 'EUR',
              isSelected: _selectedCurrency == 'EUR',
              onTap: () {
                setState(() {
                  _selectedCurrency = 'EUR';
                });
                Navigator.pop(context);
                // TODO: Cambiar moneda en la app
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppAuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          '¿Cerrar sesión?',
          style: AppText.display(18),
        ),
        content: Text(
          'Se cerrará tu sesión en la aplicación.',
          style: AppText.ui(14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: AppText.ui(14, color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Cerrar sesión',
              style: AppText.ui(14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      default:
        return 'Español';
    }
  }
}

// ========== WIDGET: TARJETA DE CONFIGURACIÓN ==========
class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadow.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.wash,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: AppColors.inkSoft, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.ui(12, color: AppColors.textLabel),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppText.ui(15, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET: TOGGLE DE CONFIGURACIÓN ==========
class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.inkSoft, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppText.ui(15, weight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.inkSoft,
            inactiveTrackColor: AppColors.line,
          ),
        ],
      ),
    );
  }
}

// ========== WIDGET: OPCIÓN DE IDIOMA ==========
class _LanguageOption extends StatelessWidget {
  final String language;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wash : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.inkSoft : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: AppText.ui(15, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code.toUpperCase(),
                    style: AppText.label(11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.inkSoft,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET: OPCIÓN DE MONEDA ==========
class _CurrencyOption extends StatelessWidget {
  final String currency;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.currency,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wash : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.inkSoft : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency,
                    style: AppText.ui(15, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code.toUpperCase(),
                    style: AppText.label(11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.inkSoft,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET: BOTÓN DE ACCIÓN ==========
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.pressIn,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.press),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isDestructive ? Colors.red[600]! : AppColors.inkSoft;
    final bgColor =
        widget.isDestructive ? Colors.red[50]! : AppColors.wash;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.line),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(widget.icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppText.ui(15, weight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}