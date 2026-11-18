import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/centrix_theme.dart';

abstract final class DashboardColors {
  static const background = CentrixColors.canvas;
  static const surface = CentrixColors.surface;
  static const emerald = CentrixColors.emerald;
  static const neon = CentrixColors.leaf;
  static const mint = CentrixColors.mint;
  static const muted = CentrixColors.forest;
  static const amber = CentrixColors.amber;
  static ThemeData get theme =>
      CentrixTheme.dark.copyWith(scaffoldBackgroundColor: background);
}

class DashboardGlass extends StatelessWidget {
  const DashboardGlass({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderColor,
    this.colors,
  });
  final Widget child;
  final double radius;
  final Color? borderColor;
  final List<Color>? colors;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  colors ?? [const Color(0xE9283730), const Color(0xD0141B18)],
            ),
            border: Border.all(
              color: borderColor ?? DashboardColors.mint.withValues(alpha: .13),
            ),
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    ),
  );
}
