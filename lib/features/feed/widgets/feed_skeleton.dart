import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/content.dart';

/// 24c · Placeholder cards while the feed loads.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading feed',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        children: const [
          _SkeletonCard(titleWidth: 0.62, lineWidth: 0.58),
          SizedBox(height: 14),
          _SkeletonCard(titleWidth: 0.48, lineWidth: 0.70),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.titleWidth, required this.lineWidth});

  final double titleWidth;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                spacing: 10,
                children: [
                  const SkeletonBox(width: 42, height: 42),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, inner) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 7,
                        children: [
                          SkeletonBox(width: inner.maxWidth * titleWidth, height: 12),
                          SkeletonBox(width: inner.maxWidth * 0.3, height: 10, color: AppColors.skeletonLight),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SkeletonBox(height: 150, radius: 18, color: AppColors.skeletonBlock),
              SkeletonBox(width: w * 0.92, height: 12),
              SkeletonBox(width: w * lineWidth, height: 12),
              const Row(
                spacing: 8,
                children: [
                  SkeletonBox(width: 64, height: 34, color: AppColors.skeletonLight),
                  SkeletonBox(width: 140, height: 34, color: AppColors.skeletonLight),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
