import 'package:flutter/material.dart';

/// Paleta proporcionada para la identidad visual de Centrix.
abstract final class CentrixColors {
  static const ink = Color(0xFF051F20);
  static const deep = Color(0xFF0B2B26);
  static const forest = Color(0xFF163832);
  static const leaf = Color(0xFF235347);
  static const sage = Color(0xFF8EB69B);
  static const mint = Color(0xFFDAF1DE);
  static const canvas = Color(0xFFF3F8F4);
  static const white = Color(0xFFFFFFFF);
}

abstract final class CentrixTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: CentrixColors.leaf,
          brightness: Brightness.light,
        ).copyWith(
          primary: CentrixColors.leaf,
          onPrimary: CentrixColors.white,
          primaryContainer: CentrixColors.mint,
          onPrimaryContainer: CentrixColors.ink,
          secondary: CentrixColors.sage,
          onSecondary: CentrixColors.ink,
          secondaryContainer: CentrixColors.mint,
          onSecondaryContainer: CentrixColors.ink,
          surface: CentrixColors.white,
          onSurface: CentrixColors.ink,
          outline: CentrixColors.sage,
        );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: CentrixColors.canvas,
      textTheme: text.copyWith(
        headlineLarge: text.headlineLarge?.copyWith(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CentrixColors.ink,
        foregroundColor: CentrixColors.mint,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: CentrixColors.mint,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: CentrixColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: CentrixColors.sage.withValues(alpha: 0.28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CentrixColors.white,
        labelStyle: const TextStyle(color: CentrixColors.forest),
        hintStyle: TextStyle(
          color: CentrixColors.forest.withValues(alpha: 0.66),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CentrixColors.sage.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CentrixColors.leaf, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CentrixColors.leaf,
          foregroundColor: CentrixColors.white,
          disabledBackgroundColor: CentrixColors.sage,
          disabledForegroundColor: CentrixColors.forest,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CentrixColors.leaf,
          side: const BorderSide(color: CentrixColors.sage),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CentrixColors.mint,
        selectedColor: CentrixColors.sage,
        side: BorderSide.none,
        labelStyle: const TextStyle(
          color: CentrixColors.ink,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: CentrixColors.sage.withValues(alpha: 0.35),
    );
  }
}
