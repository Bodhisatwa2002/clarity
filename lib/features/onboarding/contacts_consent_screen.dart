import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../friends/find_friends_screen.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';

/// 21 · Privacy / contacts consent — explicit DPDP consent before reading
/// contacts. Shown at the moment the user taps "Find friends".
class ContactsConsentScreen extends StatefulWidget {
  const ContactsConsentScreen({super.key, this.fromOnboarding = false});

  /// When true, finishing (or skipping) lands on the home map.
  final bool fromOnboarding;

  @override
  State<ContactsConsentScreen> createState() => _ContactsConsentScreenState();
}

class _ContactsConsentScreenState extends State<ContactsConsentScreen> {
  bool _agreed = false;

  static const _does = [
    'Read phone numbers from the contacts you choose to share.',
    'Send them securely to check who is already on Clarity.',
    'Show you the matches so you can add them as friends.',
  ];
  static const _never = [
    'Store numbers of people who are not on Clarity. They are deleted right after matching.',
    'Message your contacts without you tapping Invite.',
    'Upload names, emails or photos. Only numbers leave your phone.',
  ];

  void _notNow() {
    if (widget.fromOnboarding) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
    } else {
      Navigator.pop(context);
    }
  }

  void _allow() {
    Navigator.pushReplacementNamed(
      context,
      Routes.findFriends,
      arguments: FindFriendsArgs(fromOnboarding: widget.fromOnboarding),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      sheetTop: 194,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            leading: GlassIconButton(
              icon: AppIcon.back,
              iconSize: 20,
              semanticLabel: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            center: const GlassTag(
              label: 'Your consent',
              leading: AppIconView(AppIcon.shield, size: 13, color: AppColors.white, strokeWidth: 2.2),
            ),
          ),
          const SizedBox(height: 18),
          const AccentTitle(
            lead: 'Before we read ',
            accent: 'your contacts',
            size: 28,
            accentSize: 32,
            letterSpacing: -0.7,
            height: 1.12,
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 200),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
            child: _ConsentList(title: 'WHAT WE DO', color: AppColors.success, icon: AppIcon.check, items: _does),
          ),
          const SizedBox(height: 16),
          DashedBorder(
            color: AppColors.dashed,
            radius: 22,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ConsentList(
                title: 'WHAT WE NEVER DO',
                color: AppColors.danger,
                icon: AppIcon.close,
                items: _never,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text.rich(
              TextSpan(
                style: AppText.sans(13, weight: FontWeight.w400, height: 1.5, color: AppColors.slate),
                children: [
                  const TextSpan(
                    text: "Under India's Digital Personal Data Protection Act, 2023, you can withdraw consent anytime in ",
                  ),
                  TextSpan(
                    text: 'Settings',
                    style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.blue),
                  ),
                  const TextSpan(text: ', and delete your account and data. Read the full '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.blue),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
      sheetOverlays: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Pressable(
                  onTap: () => setState(() => _agreed = !_agreed),
                  pressedOpacity: 0.85,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      _Checkbox(checked: _agreed),
                      Expanded(
                        child: Text(
                          "I agree to let Clarity check my contacts' numbers to find friends.",
                          style: AppText.sans(14, weight: FontWeight.w600, height: 1.45, color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    DashedButton(label: 'Not now', onPressed: _notNow),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Allow access',
                        height: 56,
                        fontSize: 16,
                        disabledLook: DisabledLook.onWhite,
                        onPressed: _agreed ? _allow : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentList extends StatelessWidget {
  const _ConsentList({required this.title, required this.color, required this.icon, required this.items});

  final String title;
  final Color color;
  final AppIcon icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(title, style: AppText.sectionLabel(color: color)),
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AppIconView(icon, size: 18, color: color, strokeWidth: 2.4),
              ),
              Expanded(
                child: Text(
                  item,
                  style: AppText.sans(14, weight: FontWeight.w400, height: 1.45, color: AppColors.text),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: checked ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: checked ? AppColors.ink : const Color(0xFF767676), width: 1.5),
      ),
      child: checked
          ? const Center(child: AppIconView(AppIcon.check, size: 16, color: AppColors.white, strokeWidth: 3))
          : null,
    );
  }
}
