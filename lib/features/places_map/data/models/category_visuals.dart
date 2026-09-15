import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ícono + color por categoría de comercio/lugar de interés (HU-07):
/// para que el mapa y las tarjetas de "Comercios cercanos" se vean
/// distintos según qué es cada lugar, en vez de un mismo pin genérico
/// para todo. No usa fotos reales (no hay URLs de imágenes en la BD)
/// sino ilustraciones consistentes por categoría.
class CategoryVisual {
  final IconData icon;
  final Color color;
  final double markerHue;

  const CategoryVisual({
    required this.icon,
    required this.color,
    required this.markerHue,
  });

  static const _restaurante = CategoryVisual(
    icon: Icons.restaurant,
    color: Color(0xFFE67E22),
    markerHue: 25,
  );
  static const _hotel = CategoryVisual(
    icon: Icons.hotel,
    color: Color(0xFF8E44AD),
    markerHue: 270,
  );
  static const _tienda = CategoryVisual(
    icon: Icons.shopping_bag,
    color: Color(0xFF16A085),
    markerHue: 160,
  );
  static const _discoteca = CategoryVisual(
    icon: Icons.nightlife,
    color: Color(0xFFE74C3C),
    markerHue: 0,
  );
  static const _tour = CategoryVisual(
    icon: Icons.hiking,
    color: Color(0xFF2980B9),
    markerHue: 210,
  );
  static const _transporte = CategoryVisual(
    icon: Icons.directions_car,
    color: Color(0xFF7F8C8D),
    markerHue: 0, // gris, sin equivalente de hue -> se ignora al pintar
  );
  static const _mirador = CategoryVisual(
    icon: Icons.landscape,
    color: Color(0xFF27AE60),
    markerHue: 130,
  );
  static const _museo = CategoryVisual(
    icon: Icons.museum,
    color: Color(0xFF9B59B6),
    markerHue: 280,
  );
  static const _parque = CategoryVisual(
    icon: Icons.park,
    color: Color(0xFF2ECC71),
    markerHue: 140,
  );
  static const _otro = CategoryVisual(
    icon: Icons.place,
    color: Color(0xFF1A5F7A),
    markerHue: 200,
  );

  static CategoryVisual forCategory(String categoria) {
    switch (categoria.trim().toLowerCase()) {
      case 'restaurante':
        return _restaurante;
      case 'hotel':
        return _hotel;
      case 'tienda':
        return _tienda;
      case 'discoteca':
        return _discoteca;
      case 'tour':
        return _tour;
      case 'transporte':
        return _transporte;
      case 'mirador':
        return _mirador;
      case 'museo':
        return _museo;
      case 'parque':
        return _parque;
      default:
        return _otro;
    }
  }

  BitmapDescriptor toMarkerIcon() =>
      BitmapDescriptor.defaultMarkerWithHue(markerHue);
}
