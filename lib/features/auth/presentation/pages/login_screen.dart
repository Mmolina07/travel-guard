import 'package:flutter/material.dart';
import "../pages/Register_Type_Screen.dart";
import '../../../trips/presentation/pages/home_screen_client.dart';
import '../../../places_map/presentation/home_screen_comercio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin({required Widget destination}) {
  if (_validateForm()) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Ingreso exitoso!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    });
  }
}

  bool _validateForm() {
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
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Descripción
                    Text(
                      'Accede a tu cuenta en TravelGuard',
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
                          // Etiqueta Email
                          Text(
                            'Correo electrónico',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF1A5F7A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Campo Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'ejemplo@correo.com',
                              prefixIcon: const Icon(Icons.email_outlined),
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
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 20),

                          // Etiqueta Contraseña
                          Text(
                            'Contraseña',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF1A5F7A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Campo Contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              prefixIconColor: const Color(0xFF1A5F7A),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF1A5F7A),
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible);
                                },
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
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Enlace Olvidé contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Función en desarrollo'),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A5F7A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botones: iniciar sesion como turista y comercio
                          Row(
                            children: [
                              // Botón iniciar sesion como turista 
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : () => _handleLogin(destination: const HomeScreenClient()),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF1A5F7A),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar sesión como Turista',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A5F7A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Botón iniciar sesion como comercio
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    // Poner la navegacion al comercio 
                                    onPressed: _isLoading ? null : () => _handleLogin(destination: const HomeScreenComercio()),
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
                                                  AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Iniciar sesión como Comercio',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                          const SizedBox(height: 16),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿No tienes cuenta?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterTypeScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Regístrate aquí',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A5F7A),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}