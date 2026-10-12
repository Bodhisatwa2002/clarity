import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/layout.dart';
import 'widgets/onboarding_widgets.dart';

/// 06 · Permissions primer — explains contact sync before iOS asks.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SkyScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.blue, AppColors.blueLight, AppColors.blueSky, AppColors.blueMist],
        stops: [0, 0.40, 0.74, 1],
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your friends are',
            textAlign: TextAlign.center,
            style: AppText.sans(30, weight: FontWeight.w700, letterSpacing: -0.8, height: 1.12, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'probably here already',
            textAlign: TextAlign.center,
            style: AppText.serif(36, italic: true, height: 1.05, color: AppColors.white),
          ),
          const SizedBox(height: 30),
          const Center(child: _ContactMatchCard()),
          const SizedBox(height: 34),
          const _Benefit(icon: AppIcon.friends, text: 'See which contacts are on Clarity and open their maps.'),
          const SizedBox(height: 16),
          const _Benefit(
            icon: AppIcon.shieldCheck,
            text: "Numbers are matched, then deleted. We never store people who aren't on Clarity.",
          ),
          const SizedBox(height: 16),
          const _Benefit(
            icon: AppIcon.listCheck,
            text: 'Share all contacts, or just a few. Change it anytime in Settings.',
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Find my friends',
            onPressed: () => Navigator.pushNamed(context, Routes.consent, arguments: true),
          ),
          const SizedBox(height: 6),
          TextLinkButton(
            label: 'Not now',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false),
          ),
          const SizedBox(height: 6),
          const Footnote('Next, your iPhone will ask for permission.'),
        ],
      ),
    );
  }
}

/// A glimpse of what contact sync does: your address book, with the people on
/// Clarity picked out and everyone else left untouched ("not stored").
class _ContactMatchCard extends StatelessWidget {
  const _ContactMatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.whiteA(0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.whiteA(0.38)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 8,
            children: [
              const AppIconView(AppIcon.contacts, size: 18, color: AppColors.white, strokeWidth: 1.8),
              Expanded(
                child: Text(
                  'Your contacts',
                  style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.white),
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(13)),
                alignment: Alignment.center,
                child: Text(
                  '12 on Clarity',
                  style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _ContactRow(
            initials: 'RS',
            name: 'Rahul Sen',
            detail: '18 places · 4 cities',
            bg: AppColors.white,
            fg: AppColors.blue,
          ),
          _divider(),
          const _ContactRow(
            initials: 'PK',
            name: 'Priya Kapoor',
            detail: '11 places · 2 cities',
            bg: AppColors.successBg,
            fg: AppColors.success,
          ),
          _divider(),
          const _ContactRow(
            initials: 'RP',
            name: 'Ravi Plumber',
            detail: 'Not on Clarity',
            bg: AppColors.takenBg,
            fg: AppColors.takenFg,
            onClarity: false,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: AppColors.whiteA(0.22));
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.initials,
    required this.name,
    required this.detail,
    required this.bg,
    required this.fg,
    this.onClarity = true,
  });

  final String initials;
  final String name;
  final String detail;
  final Color bg;
  final Color fg;
  final bool onClarity;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 54,
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppText.sans(13, weight: FontWeight.w800, color: fg),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(15, weight: FontWeight.w700, color: AppColors.white),
                ),
                Text(detail, style: AppText.sans(12, color: AppColors.onBlueSoft)),
              ],
            ),
          ),
          if (onClarity)
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.check, size: 14, color: AppColors.navy, strokeWidth: 2.4),
            )
          else
            Row(
              spacing: 4,
              children: [
                const AppIconView(AppIcon.lock, size: 13, color: AppColors.white, strokeWidth: 1.8),
                Text(
                  'Not stored',
                  style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.white),
                ),
              ],
            ),
        ],
      ),
    );
    return onClarity ? row : Opacity(opacity: 0.62, child: row);
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final AppIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        DashedBorder(
          color: AppColors.navy,
          shape: BoxShape.circle,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(child: AppIconView(icon, size: 20, color: AppColors.navy, strokeWidth: 1.8)),
          ),
        ),
        Expanded(
          child: Text(text, style: AppText.serif(18, height: 1.3, color: AppColors.navy)),
        ),
      ],
    );
  }
}
