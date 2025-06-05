// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // App Constants
  static const String currentUser = 'surajgore-007';
  static const String currentDateTime = '2025-02-06 17:57:29';
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);

  // Base Colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1F36);
  static const Color textMedium = Color(0xFF4A5568);
  static const Color textLight = Color(0xFF718096);
  static const Color accent = Color(0xFF6366F1); // Indigo
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF48BB78);
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color divider = Color(0xFFE2E8F0);

  // Additional Colors
  static const Color secondary = Color(0xFF818CF8);
  static const Color tertiary = Color(0xFF4F46E5);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color warning = Color(0xFFF6AD37);
  static const Color info = Color(0xFF63B3ED);

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];

  // All Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textDark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textMedium,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textMedium,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMedium,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textLight,
  );

  // Special Text Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
    height: 1.3,
  );

  static const TextStyle greetingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.2,
  );

  static const TextStyle greetingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textMedium,
    height: 1.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.4,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    color: textMedium,
    height: 1.4,
  );

  static const TextStyle monospace = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    color: textDark,
    height: 1.5,
  );

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: softShadow,
      );

  static BoxDecoration get buttonDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: softShadow,
      );

  // Tile Decorations
  static BoxDecoration get tilePrimaryDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      );

  static BoxDecoration get tileSecondaryDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [secondary, secondary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      );

  // Input Decorations
  static InputDecoration get searchDecoration => InputDecoration(
        hintText: 'Search...',
        hintStyle: bodyMedium.copyWith(color: textLight),
        prefixIcon: const Icon(Icons.search, color: textMedium, size: 20),
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );

  static InputDecoration getInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: accent,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: accent),
        ),
        elevation: 0,
      );

  // Theme Data
  static ThemeData get themeData => ThemeData(
        primaryColor: accent,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textDark),
          titleTextStyle: headlineMedium,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: white,
          selectedItemColor: accent,
          unselectedItemColor: textMedium,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          displaySmall: displaySmall,
          headlineLarge: headlineLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          titleLarge: titleLarge,
          titleMedium: titleMedium,
          titleSmall: titleSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        ),
        colorScheme: ColorScheme.light(
          primary: accent,
          secondary: secondary,
          tertiary: tertiary,
          surface: white,
          background: background,
          onPrimary: white,
          onSecondary: white,
          onSurface: textDark,
          onBackground: textDark,
          error: error,
          onError: white,
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
          space: 1,
        ),
      );
}
