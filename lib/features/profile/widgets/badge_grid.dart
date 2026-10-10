import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/dashed_border.dart';

class _Badge {
  const _Badge(this.label, this.mark, {this.color});
  final String label;
  final String mark;

  /// Null means not earned yet.
  final Color? color;
  bool get earned => color != null;
}

const _badges = [
  _Badge('First 10 places', '10', color: AppColors.blue),
  _Badge('Café hopper', 'CH', color: Color(0xFF7A4A1E)),
  _Badge('Trekker', 'TR', color: Color(0xFF2B8A3E)),
  _Badge('5 states', '3/5'),
  _Badge('Night owl', 'NO'),
  _Badge('Early riser', 'ER', color: Color(0xFFE8590C)),
];

/// "Badges · 4 of 6" — earned ones are solid, the rest dashed.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.earned).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Badges', style: AppText.sans(20, weight: FontWeight.w700, letterSpacing: -0.3)),
              Text(
                '$earned of ${_badges.length}',
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 96,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [for (final b in _badges) _BadgeTile(badge: b)],
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: badge.earned ? AppColors.card : AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: badge.color ?? const Color(0xFFB8C0CC), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              badge.mark,
              style: AppText.sans(13, weight: FontWeight.w800, color: AppColors.white),
            ),
          ),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: AppText.sans(
              11,
              weight: FontWeight.w700,
              height: 1.2,
              color: badge.earned ? AppColors.text : AppColors.muted,
            ),
          ),
        ],
      ),
    );
    return badge.earned ? tile : DashedBorder(color: AppColors.dashed, radius: 20, child: tile);
  }
}
