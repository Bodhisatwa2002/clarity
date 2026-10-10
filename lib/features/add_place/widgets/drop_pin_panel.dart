import 'package:flutter/material.dart';

import '../../../core/models/place_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/map_art.dart';

/// "Drop a pin" — for places without a listing.
class DropPinPanel extends StatelessWidget {
  const DropPinPanel({
    super.key,
    required this.nameController,
    required this.category,
    required this.onNameChanged,
    required this.onCategory,
  });

  final TextEditingController nameController;
  final PlaceCategory? category;
  final VoidCallback onNameChanged;
  final ValueChanged<PlaceCategory> onCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Container(
          height: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.mapLand,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: FittedBox(fit: BoxFit.cover, child: MapArtView(MapArt.pinDrop)),
              ),
              // Shadow under the pin, then the pin standing on it.
              Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  width: 14,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.shadow.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -27),
                child: const SizedBox(
                  width: 46,
                  height: 54,
                  child: FittedBox(child: MapPinMarker(color: AppColors.ink, selected: true)),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.whiteA(0.92), borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: Text(
                    'Move the map to place the pin',
                    style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.navy),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: AppColors.shadow.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: BareTextField(
            controller: nameController,
            hint: 'Name it, e.g. Hidden waterfall',
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => onNameChanged(),
            style: AppText.sans(16, weight: FontWeight.w600, color: AppColors.navyInk),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in PlaceCategory.pickable)
              PillButton(
                label: c.label,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                fontWeight: FontWeight.w700,
                background: c == category ? AppColors.ink : AppColors.whiteA(0.75),
                foreground: c == category ? AppColors.white : AppColors.navy,
                dashedBorder: c == category ? AppColors.ink : AppColors.muted,
                leading: Dot(color: c.color),
                onPressed: () => onCategory(c),
              ),
          ],
        ),
      ],
    );
  }
}
