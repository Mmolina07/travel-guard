import 'package:flutter/material.dart';

/// Paleta centralizada de TravelGuard.
///
/// `primary` mantiene el teal (`#1A5F7A`) que ya usan casi todas las
/// pantallas del proyecto como color hardcodeado (`_primary`) — así el
/// tema global no compite visualmente con ese código existente, solo
/// lo complementa. `accent` (esmeralda) es nuevo: para CTAs y estados
/// positivos donde antes no había una segunda voz de color.
class AppColors {
  AppColors._();

  // Marca (compartida entre modo claro y oscuro).
  static const Color primaryLight = Color(0xFF1A5F7A);
  static const Color primaryDark = Color(0xFF4FB3D9);
  static const Color accentLight = Color(0xFF10B981);
  static const Color accentDark = Color(0xFF34D399);

  // Modo claro.
  static const Color backgroundLight = Color(0xFFF7FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A2027);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color errorLight = Color(0xFFD32F2F);

  // Modo oscuro (slate/antracita, no negro puro).
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
  static const Color errorDark = Color(0xFFEF5350);
}

/// `ThemeData` global de la app (TG-166): centraliza colores, tipografía,
/// botones, inputs y tarjetas para que cualquier widget que no fije sus
/// propios estilos (la mayoría de código nuevo en `trips/`, `places_map/`
/// y `expenses/`) herede automáticamente un look premium y consistente,
/// sin tocar la maquetación existente de `features/auth/presentation/`.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.primaryLight,
        accent: AppColors.accentLight,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        border: AppColors.borderLight,
        error: AppColors.errorLight,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        accent: AppColors.accentDark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        border: AppColors.borderDark,
        error: AppColors.errorDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color accent,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color error,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
      onSurface: textPrimary,
    );

    final textTheme = _textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: border,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        surfaceTintColor: Colors.transparent,
        shadowColor: primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFF1F5F9)
            : surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.8)),
        labelStyle: TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: error, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.08),
        labelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(color: surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 24),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withOpacity(0.5)
              : null,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : textSecondary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
      ),
    );
  }

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(color: primaryText, fontSize: 16, height: 1.4),
      bodyMedium: TextStyle(color: primaryText, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: secondaryText, fontSize: 12, height: 1.3),
      labelLarge: TextStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
