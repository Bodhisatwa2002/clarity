import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../badges/widgets/get_started_card.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/layout.dart';
import '../../shared/widgets/map_art.dart';

/// 23a · Empty map — a new account before its first pin.
class EmptyMapView extends StatelessWidget {
  const EmptyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final greeting = state.firstName.isEmpty ? 'Hi there' : 'Hi, ${state.firstName}';
    return SheetScaffold(
      sheetTop: 140,
      sheetColor: AppColors.mapLand,
      headerPadding: const EdgeInsets.symmetric(horizontal: 22),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(greeting, style: AppText.screenTitle()),
          Text('Your map starts with one place', style: AppText.headerSubtitle()),
        ],
      ),
      sheet: const Opacity(
        opacity: 0.55,
        child: FittedBox(fit: BoxFit.cover, alignment: Alignment.topCenter, child: MapArtView(MapArt.empty)),
      ),
      sheetOverlays: [
        Positioned(
          left: 22,
          right: 22,
          top: 70,
          child: Column(
            children: [
              DashedBorder(
                color: AppColors.emptyRing,
                shape: BoxShape.circle,
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.14),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const GhostPin(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const AccentTitle(
                lead: 'No pins ',
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
                  "Add a place you loved, or one you'd warn a friend about. Your map fills in as you go.",
                  textAlign: TextAlign.center,
                  style: AppText.sans(15, weight: FontWeight.w400, height: 1.5, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 18),
              const GetStartedStrip(),
            ],
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: 116,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                label: 'Add your first place',
                icon: AppIcon.plus,
                onPressed: () => Navigator.pushNamed(context, Routes.addPlace),
              ),
              TextLinkButton(
                label: "Or see your friends' maps first",
                onPressed: () => Navigator.pushNamed(context, Routes.consent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
