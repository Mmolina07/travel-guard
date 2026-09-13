import 'package:flutter/material.dart';
import '../../../places_map/presentation/home_screen_comercio.dart';

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

  void _handleRegister() {
  if (_validateForm()) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro exitoso!')),
      );

      // Navegar SOLO si la validación pasó
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreenComercio(),
        ),
      );
    });
  }
}

  bool _validateForm() {
    if (_nitController.text.isEmpty) {
      _showError('Por favor ingresa el NIT');
      return false;
    }
    if (_nameController.text.isEmpty) {
      _showError('Por favor ingresa el nombre del negocio');
      return false;
    }
    if (_directionController.text.isEmpty) {
      _showError('Por favor ingresa la dirección');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Por favor ingresa el número telefónico');
      return false;
    }
    if (_sedeController.text.isEmpty) {
      _showError('Por favor ingresa la sede');
      return false;
    }
    if (_emailController.text.isEmpty) {
      _showError('Por favor ingresa tu correo');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showError('Correo inválido');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Por favor ingresa tu contraseña');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A5F7A),
              const Color(0xFF0F4C5F),
            ],
          ),
        ),
        child: Column(
          children: [
            // Botón volver
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Registro de Comercio',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    Text(
                      'Registra tu negocio en TravelGuard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Contenedor de formulario
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo NIT
                          _buildLabel('NIT'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nitController,
                            hint: 'Ingresa el NIT',
                            icon: Icons.badge_outlined,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Nombre
                          _buildLabel('Nombre del Negocio'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Ingresa el nombre del negocio',
                            icon: Icons.storefront,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Dirección
                          _buildLabel('Dirección'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _directionController,
                            hint: 'Ingresa la dirección',
                            icon: Icons.location_on_outlined,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Teléfono
                          _buildLabel('Número Telefónico'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hint: 'Ingresa el número',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Sede
                          _buildLabel('Sede'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _sedeController,
                            hint: 'Ingresa la sede',
                            icon: Icons.business,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Email
                          _buildLabel('Correo electrónico'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'ejemplo@correo.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Campo Contraseña
                          _buildLabel('Contraseña'),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: _passwordController,
                            isVisible: _isPasswordVisible,
                            hint: '••••••••',
                            onVisibilityChange: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
                            },
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('Confirmar Contraseña'),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            isVisible: _isPasswordVisible,
                            hint: '••••••••',
                            onVisibilityChange: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
                            },
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 24),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A5F7A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Términos y condiciones
                          Center(
                            child: Text(
                              'Al registrarte aceptas nuestros Términos y Condiciones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF1A5F7A),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixIconColor: const Color(0xFF1A5F7A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4A90A4),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4A90A4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1A5F7A),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      enabled: enabled,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required String hint,
    required VoidCallback onVisibilityChange,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        prefixIconColor: const Color(0xFF1A5F7A),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF1A5F7A),
          ),
          onPressed: onVisibilityChange,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4A90A4),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4A90A4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1A5F7A),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      enabled: enabled,
    );
  }
}