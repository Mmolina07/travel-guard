import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "Papel Petróleo" — ver
/// `design_handoff_travelguard_papel_petroleo/README.md` para la
/// especificación completa (fidelidad alta: valores finales, no
/// aproximados). Única fuente de colores de la app — nada de
/// `Color(0xFF...)` sueltos fuera de esta clase.
abstract final class AppColors {
  AppColors._();

  static const ink = Color(0xFF0B3438); // petróleo profundo
  static const inkSoft = Color(0xFF1C7A6B); // acento medio
  static const mint = Color(0xFF7FD1B9); // acento claro — solo sobre ink
  static const paper = Color(0xFFFBF8F1); // fondo de pantalla
  static const paperDeep = Color(0xFFF1EEE5); // fondo de pistas/campos
  static const surface = Color(0xFFFFFFFF); // tarjetas
  static const wash = Color(0xFFE9F0E8); // tarjeta secundaria / tags
  static const line = Color(0xFFE5E9E2); // bordes de nav y pistas
  static const hair = Color(0xFFDDD7C9); // subrayados/bordes sutiles
  static const textMuted = Color(0xFF4C6461); // texto secundario
  static const textLabel = Color(0xFF8A8272); // etiquetas mono
  static const textOnInk = Color(0xFF9DB3B0); // texto secundario sobre ink
  static const error = Color(0xFFB4413A); // error de campo
}

abstract final class AppRadius {
  AppRadius._();

  static const control = 14.0;
  static const chip = 13.0;
  static const dateField = 18.0;
  static const button = 20.0;
  static const card = 22.0;
  static const cardLg = 28.0;
  static const nav = 26.0;
  static const screen = 38.0;

  /// Asimetría: una sola esquina grande por bloque.
  static const BorderRadius headerLogin =
      BorderRadius.only(bottomLeft: Radius.circular(120));
  static const BorderRadius headerDetail =
      BorderRadius.only(bottomRight: Radius.circular(44));
}

/// Sombra única y direccional — nunca `elevation` de Material.
abstract final class AppShadow {
  AppShadow._();

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
/// Ver tabla de movimiento del handoff — aplicar tal cual, nada de
/// `Curves.linear`.
abstract final class AppMotion {
  AppMotion._();

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
  AppText._();

  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      GoogleFonts.instrumentSerif(fontSize: size, height: 1.05, color: color);

  static TextStyle displayItalic(
    double size, {
    Color color = AppColors.inkSoft,
  }) => GoogleFonts.instrumentSerif(
    fontSize: size,
    height: 1.05,
    fontStyle: FontStyle.italic,
    color: color,
  );

  static TextStyle ui(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double height = 1.4,
  }) => GoogleFonts.instrumentSans(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// Etiquetas mono en versalitas con tracking abierto (+0.14em).
  static TextStyle label(double size, {Color color = AppColors.textLabel}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        letterSpacing: size * 0.14,
        color: color,
      );
}

/// `ThemeData` global de la app. Cubre los tokens del handoff
/// (colorScheme, textTheme, splash desactivado) y además recolorea los
/// estilos de componentes Material que el resto de la app (fuera de las
/// 5 pantallas rediseñadas a mano) sigue heredando por defecto —
/// botones, inputs, cards, diálogos — para que toda la app comparta una
/// sola paleta aunque no todas las pantallas tengan layout rediseñado
/// todavía.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: Brightness.light,
      primary: AppColors.ink,
      secondary: AppColors.inkSoft,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.instrumentSansTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.paper,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.hair, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inkSoft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.mint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.control)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperDeep,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.dateField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.dateField),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.dateField),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.dateField),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.dateField),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.wash,
        labelStyle: const TextStyle(
          color: AppColors.inkSoft,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: AppColors.paper),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.inkSoft,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hair,
        thickness: 1,
        space: 24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.ink
              : Colors.transparent,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.ink : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.ink.withValues(alpha: 0.5)
              : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.ink
              : AppColors.textMuted,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.ink,
      ),
    );
  }
}

/// Puntos de quiebre del layout web — ver
/// `design_handoff_travelguard_papel_petroleo/WEB_LAYOUT.md`: por debajo
/// de `mobile` va una columna con nav flotante, entre `mobile` y
/// `desktop` el sidebar se colapsa a iconos, desde `desktop` el sidebar
/// queda fijo en 248px. Comparar siempre contra el ancho disponible
/// (`LayoutBuilder`/`MediaQuery`), nunca contra la plataforma.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 720;
  static const double desktop = 1024;
}

extension AppBreakpointsX on BuildContext {
  double get _screenWidth => MediaQuery.sizeOf(this).width;

  bool get isDesktop => _screenWidth >= AppBreakpoints.desktop;
  bool get isTablet =>
      _screenWidth >= AppBreakpoints.mobile &&
      _screenWidth < AppBreakpoints.desktop;
  bool get isMobile => _screenWidth < AppBreakpoints.mobile;
}
