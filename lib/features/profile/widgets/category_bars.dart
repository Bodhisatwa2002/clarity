import 'package:flutter/material.dart';

import '../../../core/models/place_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/glass.dart';

/// Horizontal bars for "TOP CATEGORIES", scaled to the biggest count.
class CategoryBars extends StatelessWidget {
  const CategoryBars({super.key, required this.counts});

  final List<MapEntry<PlaceCategory, int>> counts;

  @override
  Widget build(BuildContext context) {
    final max = counts.map((e) => e.value).fold<int>(1, (a, b) => b > a ? b : a);
    return Column(
      spacing: 10,
      children: [
        for (final e in counts)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 10,
              children: [
                SizedBox(
                  width: 82,
                  child: Row(
                    spacing: 6,
                    children: [
                      Dot(color: e.key.color),
                      Text(e.key.label, style: AppText.sans(13, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 10,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: AppColors.barTrack, borderRadius: BorderRadius.circular(5)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: e.value / max,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: e.key.color, borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 22,
                  child: Text(
                    '${e.value}',
                    textAlign: TextAlign.right,
                    style: AppText.sans(13, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
