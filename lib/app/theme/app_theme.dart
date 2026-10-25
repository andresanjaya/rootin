import 'package:flutter/material.dart';

/// Application theme configuration based on Material 3
/// Following design tokens from docs/04-mobile-design-system.md
class AppTheme {
  AppTheme._();

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B5E20),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFA3F2A7),
    onPrimaryContainer: Color(0xFF002105),
    secondary: Color(0xFF006A60),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF9CF2E4),
    onSecondaryContainer: Color(0xFF00201C),
    tertiary: Color(0xFF8C5000),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDCC1),
    onTertiaryContainer: Color(0xFF2E1500),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1A1C19),
    surfaceContainerHighest: Color(0xFFE0E4DB),
    onSurfaceVariant: Color(0xFF43483F),
    outline: Color(0xFF73796E),
    outlineVariant: Color(0xFFC3C8BC),
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF88D68D),
    onPrimary: Color(0xFF00390E),
    primaryContainer: Color(0xFF005318),
    onPrimaryContainer: Color(0xFFA3F2A7),
    secondary: Color(0xFF80D5C8),
    onSecondary: Color(0xFF003731),
    secondaryContainer: Color(0xFF004F47),
    onSecondaryContainer: Color(0xFF9CF2E4),
    tertiary: Color(0xFFFFB77C),
    onTertiary: Color(0xFF4B2800),
    tertiaryContainer: Color(0xFF6B3B00),
    onTertiaryContainer: Color(0xFFFFDCC1),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121411),
    onSurface: Color(0xFFE1E3DE),
    surfaceContainerHighest: Color(0xFF43483F),
    onSurfaceVariant: Color(0xFFC3C8BC),
    outline: Color(0xFF8D9387),
    outlineVariant: Color(0xFF43483F),
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E221D) : const Color(0xFFF5F7F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        helperStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        errorStyle: TextStyle(color: colorScheme.error, fontSize: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Light theme configuration
  static ThemeData light() => _buildTheme(lightColorScheme);

  /// Dark theme configuration
  static ThemeData dark() => _buildTheme(darkColorScheme);
}
