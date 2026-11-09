import 'package:flutter/material.dart';

/// Paleta proporcionada para la identidad visual de Centrix.
abstract final class CentrixColors {
  static const ink = Color(0xFF051F20);
  static const deep = Color(0xFF0B2B26);
  static const forest = Color(0xFF163832);
  static const leaf = Color(0xFF235347);
  static const sage = Color(0xFF8EB69B);
  static const mint = Color(0xFFDAF1DE);
  static const canvas = Color(0xFFEDF5F1);
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
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
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
      appBarTheme: AppBarTheme(
        backgroundColor: CentrixColors.white.withValues(alpha: .62),
        foregroundColor: CentrixColors.deep,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        shape: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: .9)),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.deep,
          fontSize: 18,
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
        fillColor: CentrixColors.white.withValues(alpha: .68),
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
          disabledBackgroundColor: CentrixColors.sage.withValues(alpha: .5),
          elevation: 0,
          disabledForegroundColor: CentrixColors.forest,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CentrixColors.leaf,
          backgroundColor: CentrixColors.white.withValues(alpha: .38),
          side: BorderSide(color: CentrixColors.leaf.withValues(alpha: .25)),
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
          fontFamily: 'Roboto',
          color: CentrixColors.ink,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: CentrixColors.sage.withValues(alpha: 0.35),
    );
  }
}
