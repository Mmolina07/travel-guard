import 'package:flutter/material.dart';
import "../widgets/Register_Type_Card.dart";
import "../pages/Comercio_Register_Screen.dart";
import "../pages/client_register_screen.dart";

class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo azul que ocupa TODA la pantalla
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
            // Área superior con botón volver
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

            // Área central EXPANDIDA con contenido centrado
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título
                    const Text(
                      '¿Cómo te quieres registrar?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtítulo
                    Text(
                      'Selecciona como quieres registrarte en TravelGuard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Tarjeta Turista
                    RegisterTypeCard(
                      icon: Icons.person,
                      title: 'Turista',
                      description:
                          'Accede a experiencias, mapas, recomendaciones y más.',
                      onTap: () {
                        _handleTuristaSelection(context);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta Comercio
                    RegisterTypeCard(
                      icon: Icons.storefront,
                      title: 'Comercio',
                      description:
                          'Registra tu negocio y llega a más visitantes.',
                      onTap: () {
                        _handleComercioSelection(context);
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//Navegacion a registro de Turista y Comercio 
  void _handleTuristaSelection(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ClienteRegisterScreen()));
  }

  void _handleComercioSelection(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ComercioRegisterScreen()));
  }
}


