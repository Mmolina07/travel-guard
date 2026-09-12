import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5F7A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mapa',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 80,
                color: const Color(0xFF1A5F7A).withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Mapa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A5F7A).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contenido en desarrollo',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF757575).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}