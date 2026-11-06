import 'package:flutter/material.dart';

import '../theme/centrix_theme.dart';

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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CentrixColors.ink, CentrixColors.forest, CentrixColors.leaf],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: CentrixColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: CentrixColors.mint,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: CentrixColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: CentrixColors.mint.withValues(alpha: 0.24),
              ),
            ),
            child: Icon(icon, size: 29, color: CentrixColors.mint),
          ),
        ],
      ),
    );
  }
}
