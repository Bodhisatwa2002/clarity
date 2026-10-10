import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/place.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/glass.dart';
import 'place_result_card.dart';

/// "I'm here" — uses (dummy) GPS to suggest where you are.
class HerePanel extends StatelessWidget {
  const HerePanel({super.key, required this.candidates, required this.pickedId, required this.onPick});

  /// Places near your (dummy) GPS fix, with how far away each is.
  final List<({Place place, String distance})> candidates;
  final String? pickedId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        DashedBorder(
          color: AppColors.whiteA(0.7),
          shape: BoxShape.circle,
          child: const SizedBox(
            width: 130,
            height: 130,
            child: Center(
              child: GlassOrb(
                size: 96,
                child: AppIconView(AppIcon.crosshair, size: 34, color: AppColors.white, strokeWidth: 1.8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Using your location · accurate to 15 m',
          style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.white),
        ),
        const SizedBox(height: 16),
        PlaceResultCard(
          title: 'ARE YOU AT…',
          places: [for (final c in candidates) c.place],
          distanceFor: (p) => candidates.firstWhere((c) => c.place.id == p.id).distance,
          pickedId: pickedId,
          onPick: onPick,
          showIcon: false,
          trailingRow: PlaceResultRow(
            name: 'Something else here',
            address: 'Name it yourself',
            distance: '',
            selected: false,
            onTap: () =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Use “Drop a pin” to name a new place.'))),
          ),
        ),
      ],
    );
  }
}
