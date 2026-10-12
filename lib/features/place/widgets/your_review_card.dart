import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/visit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/chips.dart';
import '../../shared/widgets/rating.dart';

/// "YOUR REVIEW" — your stars, text, tags and tip for a place.
class YourReviewCard extends StatelessWidget {
  const YourReviewCard({super.key, required this.visit, required this.onEdit});

  final Visit visit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tags = [if (visit.tags.isNotEmpty) visit.tags.first, ?visit.budgetLabel, ...visit.tags.skip(1)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('YOUR REVIEW', style: AppText.sectionLabel()),
              PillButton(
                label: 'Edit',
                height: 32,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                background: Colors.transparent,
                foreground: AppColors.text,
                dashedBorder: AppColors.muted,
                onPressed: onEdit,
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              StarRow(rating: visit.rating),
              Text(
                '${Fmt.dayMonthYear(visit.date)} · ${visit.companionsLabel}',
                style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
          if (visit.text.isNotEmpty) Text(visit.text, style: AppText.serif(17, height: 1.4, color: AppColors.text)),
          if (tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < tags.length; i++)
                  TagChip(
                    label: tags[i],
                    look: i == 0 && visit.tags.isNotEmpty ? ChipLook.tinted : ChipLook.outline,
                    height: 30,
                    fontSize: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    outlineColor: AppColors.chipBorder,
                    background: Colors.transparent,
                  ),
              ],
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: AppIconView(AppIcon.bulb, size: 18, color: AppColors.blue),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: AppText.sans(13, weight: FontWeight.w400, height: 1.45, color: AppColors.text),
                      children: [
                        const TextSpan(
                          text: 'One thing to know: ',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: visit.tip),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
