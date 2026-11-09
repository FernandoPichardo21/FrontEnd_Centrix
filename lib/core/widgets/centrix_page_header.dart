import 'package:flutter/material.dart';

import '../theme/centrix_theme.dart';
import 'centrix_glass.dart';

class CentrixPageHeader extends StatelessWidget {
  const CentrixPageHeader({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.eyebrow = 'CENTRIX',
  });

  final String title;
  final String description;
  final IconData icon;
  final String eyebrow;

  @override
  Widget build(BuildContext context) => CentrixGlass(
    dark: true,
    child: Stack(
      children: [
        const Positioned(
          right: -45,
          top: -90,
          child: Opacity(opacity: .10, child: CentrixOrbit(size: 270)),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: CentrixColors.sage,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CentrixColors.white,
                            letterSpacing: -.8,
                          ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      description,
                      style: TextStyle(
                        color: CentrixColors.mint.withValues(alpha: .85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: .2),
                      Colors.white.withValues(alpha: .06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: CentrixColors.mint.withValues(alpha: .3),
                  ),
                ),
                child: Icon(icon, size: 25, color: CentrixColors.mint),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
