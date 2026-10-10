import 'package:flutter/widgets.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import 'pressable.dart';

/// The black floating pill at the bottom of every main screen:
/// Map · Feed · (+) · Friends · Profile.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.current, required this.onSelect, required this.onAdd});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(33)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(AppTab.map, AppIcon.map, 'My map'),
          _item(AppTab.feed, AppIcon.feed, 'Friends feed'),
          Pressable(
            onTap: onAdd,
            semanticLabel: 'Add a place',
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.plus, size: 22, color: AppColors.ink, strokeWidth: 2.4),
            ),
          ),
          _item(AppTab.friends, AppIcon.friends, 'Friends'),
          _item(AppTab.profile, AppIcon.user, 'My profile'),
        ],
      ),
    );
  }

  Widget _item(AppTab tab, AppIcon icon, String label) {
    final active = tab == current;
    return Pressable(
      onTap: () => onSelect(tab),
      semanticLabel: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconView(icon, size: 22, color: active ? AppColors.white : AppColors.navIdle),
            if (active) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
