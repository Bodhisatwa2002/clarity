import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../share/share_sheet.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/layout.dart';

/// 23b · No friends yet.
class EmptyFriendsView extends StatelessWidget {
  const EmptyFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      sheetTop: 140,
      headerPadding: const EdgeInsets.symmetric(horizontal: 22),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          const AccentTitle(lead: 'Your ', accent: 'people'),
          Text('0 friends', style: AppText.headerSubtitle()),
        ],
      ),
      sheet: Padding(
        padding: const EdgeInsets.fromLTRB(22, 54, 22, 0),
        child: Column(
          children: [
            const _Illustration(),
            const SizedBox(height: 18),
            const AccentTitle(
              lead: 'No friends ',
              accent: 'yet',
              size: 28,
              accentSize: 32,
              letterSpacing: -0.7,
              color: AppColors.ink,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                'Clarity works best with the people you already trust. Most of them are in your phone.',
                textAlign: TextAlign.center,
                style: AppText.sans(15, weight: FontWeight.w400, height: 1.5, color: AppColors.slate),
              ),
            ),
          ],
        ),
      ),
      sheetOverlays: [
        Positioned(
          left: 22,
          right: 22,
          bottom: 116,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              PrimaryButton(
                label: 'Find friends from contacts',
                onPressed: () => Navigator.pushNamed(context, Routes.consent),
              ),
              DashedButton(
                label: 'Invite with your map link',
                expand: true,
                borderColor: AppColors.ink,
                foreground: AppColors.ink,
                onPressed: () => showShareSheet(context, target: ShareTarget.map),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 170,
      child: Stack(
        children: [
          Positioned(
            left: 60,
            top: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.36, -0.48),
                  colors: [Color(0xFFEAF2FF), Color(0xFFC9DCF7)],
                ),
              ),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.user, size: 40, color: AppColors.blue, strokeWidth: 1.6),
            ),
          ),
          _question(left: 0, top: 70, size: 58, fontSize: 22),
          _question(left: 166, top: 0, size: 50, fontSize: 20),
          _question(left: 150, top: 110, size: 56, fontSize: 22),
        ],
      ),
    );
  }

  Widget _question({required double left, required double top, required double size, required double fontSize}) {
    return Positioned(
      left: left,
      top: top,
      child: DashedBorder(
        color: AppColors.emptyRing,
        shape: BoxShape.circle,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              '?',
              style: AppText.sans(fontSize, weight: FontWeight.w600, color: AppColors.mapLabelWater),
            ),
          ),
        ),
      ),
    );
  }
}
