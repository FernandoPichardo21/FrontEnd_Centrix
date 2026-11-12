import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/centrix_theme.dart';

/// A shared visual surface; presentation only, independent of the ViewModels.
class CentrixGlass extends StatefulWidget {
  const CentrixGlass({
    super.key,
    required this.child,
    this.dark = false,
    this.interactive = false,
    this.margin = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
    this.radius = 26,
  });

  final Widget child;
  final bool dark;
  final bool interactive;
  final EdgeInsetsGeometry margin;
  final Clip clipBehavior;
  final double radius;

  @override
  State<CentrixGlass> createState() => _CentrixGlassState();
}

class _CentrixGlassState extends State<CentrixGlass> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: widget.margin,
    child: MouseRegion(
      onEnter: widget.interactive
          ? (_) => setState(() => _hovered = true)
          : null,
      onExit: widget.interactive
          ? (_) => setState(() => _hovered = false)
          : null,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [
            BoxShadow(
              color: CentrixColors.ink.withValues(alpha: _hovered ? .13 : .055),
              blurRadius: _hovered ? 32 : 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          clipBehavior: widget.clipBehavior,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.dark
                      ? [const Color(0xEC14432D), const Color(0xF4111613)]
                      : [const Color(0xE9283730), const Color(0xD0141B18)],
                ),
                border: Border.all(
                  color: widget.dark
                      ? CentrixColors.leaf.withValues(alpha: .32)
                      : CentrixColors.mint.withValues(alpha: .13),
                ),
              ),
              child: Material(color: Colors.transparent, child: widget.child),
            ),
          ),
        ),
      ),
    ),
  );
}

class CentrixBackdrop extends StatelessWidget {
  const CentrixBackdrop({super.key, required this.child, this.dark = false});
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: dark ? CentrixColors.ink : CentrixColors.canvas,
    ),
    child: CustomPaint(painter: _AmbientPainter(dark), child: child),
  );
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    void glow(Offset center, double radius, Color color) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(rect),
      );
    }

    glow(
      Offset(size.width * .08, size.height * .12),
      size.width * .65,
      const Color(0xFF123E2C),
    );
    glow(
      Offset(size.width * .92, size.height * .78),
      size.width * .6,
      const Color(0xFF0C241A),
    );
    final dots = Paint()
      ..color = (dark ? CentrixColors.mint : CentrixColors.leaf).withValues(
        alpha: .025,
      );
    for (double x = 18; x < size.width; x += 28) {
      for (double y = 18; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), .7, dots);
      }
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter oldDelegate) => dark != oldDelegate.dark;
}

/// Abstract brand artwork, without fabricated business data.
class CentrixOrbit extends StatelessWidget {
  const CentrixOrbit({super.key, this.size = 240});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _OrbitPainter(),
        child: Center(
          child: Transform.rotate(
            angle: -.18,
            child: Container(
              width: size * .36,
              height: size * .36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * .11),
                gradient: const LinearGradient(
                  colors: [Color(0xFFDCFFE8), Color(0xFF76C9A9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: CentrixColors.mint.withValues(alpha: .22),
                    blurRadius: 45,
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: .8)),
              ),
              child: Icon(
                Icons.hub_rounded,
                size: size * .19,
                color: CentrixColors.deep,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .43;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final factor in [.73, 1.0]) {
      canvas.drawCircle(
        center,
        radius * factor,
        line..color = CentrixColors.mint.withValues(alpha: .19),
      );
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.15,
        height: radius,
      ),
      line..color = CentrixColors.mint.withValues(alpha: .33),
    );
    canvas.restore();
    for (final angle in [-.7, 1.45, 3.5]) {
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(point, 6, Paint()..color = CentrixColors.mint);
      canvas.drawCircle(
        point,
        12,
        line..color = CentrixColors.mint.withValues(alpha: .2),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => false;
}
