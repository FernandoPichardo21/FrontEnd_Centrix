import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared dark palette for every Centrix screen.
abstract final class CentrixColors {
  static const canvas = Color(0xFF07100D);
  static const ink = canvas;
  static const deep = Color(0xFF0B2117);
  static const surface = Color(0xFF13211C);
  static const raised = Color(0xFF21372B);
  static const outline = Color(0xFF345044);
  static const forest = Color(0xFF94ADA0); // Secondary text.
  static const leaf = Color(0xFF65FA8C); // Primary action / neon accent.
  static const emerald = Color(0xFF0DBF83);
  static const sage = Color(0xFF8CBF9C);
  static const mint = Color(0xFFD8F9E4);
  static const white = Color(0xFFFFFFFF);
  static const amber = Color(0xFFFFB97D);
  static const error = Color(0xFFFF9BA9);
}

abstract final class CentrixTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: CentrixColors.leaf,
      onPrimary: CentrixColors.canvas,
      primaryContainer: CentrixColors.raised,
      onPrimaryContainer: CentrixColors.mint,
      secondary: CentrixColors.emerald,
      onSecondary: CentrixColors.canvas,
      secondaryContainer: CentrixColors.raised,
      onSecondaryContainer: CentrixColors.mint,
      surface: CentrixColors.surface,
      onSurface: CentrixColors.mint,
      onSurfaceVariant: CentrixColors.forest,
      outline: CentrixColors.outline,
      error: CentrixColors.error,
      onError: Color(0xFF420F1C),
      errorContainer: Color(0xFF3B1F25),
      onErrorContainer: Color(0xFFFFD9DF),
    );
    final base = ThemeData(
      fontFamily: 'Roboto',
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
    );
    final text = base.textTheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: CentrixColors.surface,
      dividerColor: CentrixColors.mint.withValues(alpha: .1),
      textTheme: text.copyWith(
        headlineLarge: text.headlineLarge?.copyWith(
          color: CentrixColors.mint,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: CentrixColors.mint,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: CentrixColors.mint,
          fontWeight: FontWeight.w700,
          letterSpacing: -.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: CentrixColors.mint,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: CentrixColors.mint,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: text.bodyLarge?.copyWith(color: CentrixColors.mint),
        bodyMedium: text.bodyMedium?.copyWith(color: CentrixColors.mint),
        bodySmall: text.bodySmall?.copyWith(color: CentrixColors.forest),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CentrixColors.canvas.withValues(alpha: .92),
        foregroundColor: CentrixColors.mint,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        shape: Border(
          bottom: BorderSide(color: CentrixColors.leaf.withValues(alpha: .10)),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: CentrixColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: CentrixColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xBF0C1912),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.forest,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.forest.withValues(alpha: .7),
        ),
        prefixIconColor: CentrixColors.sage,
        suffixIconColor: CentrixColors.sage,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: border(CentrixColors.outline),
        enabledBorder: border(CentrixColors.outline),
        focusedBorder: border(CentrixColors.leaf, 1.5),
        disabledBorder: border(CentrixColors.outline.withValues(alpha: .4)),
        errorBorder: border(CentrixColors.error),
        focusedErrorBorder: border(CentrixColors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CentrixColors.leaf,
          foregroundColor: CentrixColors.canvas,
          disabledBackgroundColor: CentrixColors.raised,
          disabledForegroundColor: CentrixColors.forest,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CentrixColors.mint,
          backgroundColor: CentrixColors.surface.withValues(alpha: .5),
          side: const BorderSide(color: CentrixColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: CentrixColors.leaf),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CentrixColors.raised,
        selectedColor: CentrixColors.leaf.withValues(alpha: .18),
        checkmarkColor: CentrixColors.leaf,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: CentrixColors.outline),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CentrixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: CentrixColors.outline),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
          fontWeight: FontWeight.w700,
          fontSize: 21,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CentrixColors.surface,
        modalBackgroundColor: CentrixColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: CentrixColors.forest,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: CentrixColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: CentrixColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CentrixColors.outline),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(CentrixColors.raised),
        headingTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
        ),
        dividerThickness: .5,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CentrixColors.leaf,
        linearTrackColor: CentrixColors.raised,
        circularTrackColor: CentrixColors.raised,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CentrixColors.leaf,
        selectionColor: CentrixColors.leaf.withValues(alpha: .25),
        selectionHandleColor: CentrixColors.leaf,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CentrixColors.raised,
        contentTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          color: CentrixColors.mint,
        ),
        actionTextColor: CentrixColors.leaf,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
