import 'package:flutter/material.dart';
import "../Pages/Register_Type_Screen.dart";
import "../Pages/login_screen.dart";

class WelcomeHome extends StatelessWidget {
  const WelcomeHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                //arreglar el link de la imagen 
                image: AssetImage('assets/images/HomeImage.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradiente oscuro sobre la imagen 
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF1A5F7A).withOpacity(0.7),
                  const Color(0xFF1A5F7A).withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Contenido principal
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Espaciador superior entre el logo
                  const SizedBox(height: 80),

                  // Logo y descripción
                  Column(
                    children: [
                      // Logo/Icono
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
                          Icons.location_on,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nombre de la app
                      const Text(
                        'TravelGuard',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      Text(
                        'Explora Medellin con seguridad y control de tu presupuesto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),

                  // Configurar botones
                  Column(
                    children: [
                      // Botón para iniciar sesión
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navegar a pantalla de login
                            _navigateToLogin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A5F7A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón para crear cuenta
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navegar a pantalla de registro
                            _navigateToRegister(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pregunta de registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Deseas crear una cuenta?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _navigateToRegister(context);
                            },
                            child: const Text(
                              'Regístrate aquí',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
  // TODO: Navegar a LoginScreen
  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
}

  void _navigateToRegister(BuildContext context) {
    // TODO: Navegar a RegisterScreen
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterTypeScreen()));
  }
}