import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// Tokens — dirección "Papel Petróleo"
/// ---------------------------------------------------------------------------
abstract final class AppColors {
  static const ink = Color(0xFF0B3438); // petróleo profundo
  static const inkSoft = Color(0xFF1C7A6B); // petróleo medio / acento
  static const mint = Color(0xFF7FD1B9); // acento claro sobre ink
  static const paper = Color(0xFFFBF8F1); // fondo principal
  static const paperDeep = Color(0xFFF1EEE5); // fondo de pistas / web shell
  static const surface = Color(0xFFFFFFFF);
  static const wash = Color(0xFFE9F0E8); // tarjeta secundaria
  static const line = Color(0xFFE5E9E2);
  static const hair = Color(0xFFDDD7C9);
  static const textMuted = Color(0xFF4C6461);
  static const textLabel = Color(0xFF8A8272);
}

abstract final class AppRadius {
  static const control = 14.0;
  static const card = 22.0;
  static const cardLg = 28.0;
  static const screen = 38.0;
  /// Asimetría: una sola esquina grande por bloque.
  static const BorderRadius headerAsym =
      BorderRadius.only(bottomLeft: Radius.circular(120));
}

abstract final class AppShadow {
  /// Sombra única direccional (nunca elevación de Material).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A092A2E),
      blurRadius: 24,
      spreadRadius: -18,
      offset: Offset(0, 10),
    ),
  ];
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x33092A2E),
      blurRadius: 40,
      spreadRadius: -26,
      offset: Offset(0, 20),
    ),
  ];
  static const List<BoxShadow> inkButton = [
    BoxShadow(
      color: Color(0xCC0B3438),
      blurRadius: 26,
      spreadRadius: -14,
      offset: Offset(0, 14),
    ),
  ];
}

/// Firma de movimiento: entrada con sobre-impulso corto, salida limpia.
abstract final class AppMotion {
  static const pressIn = Duration(milliseconds: 120);
  static const toggle = Duration(milliseconds: 320);
  static const chip = Duration(milliseconds: 380);
  static const step = Duration(milliseconds: 360);
  static const hero = Duration(milliseconds: 420);
  static const openScreen = Duration(milliseconds: 500);
  static const meter = Duration(milliseconds: 700);
  static const listItem = Duration(milliseconds: 300);
  static const stagger = Duration(milliseconds: 60);

  static const press = Curves.easeOutCubic;
  static const enter = Curves.easeOutBack; // rebote físico
  static const bouncy = Curves.elasticOut; // solo chips / micro-elementos
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const meterCurve = Curves.easeOutQuart;
}

abstract final class AppText {
  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        height: 1.05,
        color: color,
      );

  static TextStyle displayItalic(double size,
          {Color color = AppColors.inkSoft}) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        height: 1.05,
        fontStyle: FontStyle.italic,
        color: color,
      );

  static TextStyle ui(double size,
          {FontWeight weight = FontWeight.w500,
          Color color = AppColors.ink,
          double height = 1.4}) =>
      GoogleFonts.instrumentSans(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  /// Etiquetas mono en versalitas con tracking abierto.
  static TextStyle label(double size, {Color color = AppColors.textLabel}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        letterSpacing: size * 0.14,
        color: color,
      );
}

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: AppColors.ink,
        secondary: AppColors.inkSoft,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.instrumentSansTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      splashFactory: NoSplash.splashFactory, // el feedback lo dan las microinteracciones
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
