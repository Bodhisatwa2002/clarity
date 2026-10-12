import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/person_tiles.dart';

/// Arguments for [Routes.findFriends].
class FindFriendsArgs {
  const FindFriendsArgs({this.fromOnboarding = false});

  /// When true, "Done" continues to the home map instead of going back.
  final bool fromOnboarding;
}

/// 13 · Find friends from contacts — the core hook.
///
/// Numbers are matched and discarded: only contacts already on Clarity are
/// kept, and invites are sent by the user, never automatically.
class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key, this.args = const FindFriendsArgs()});

  final FindFriendsArgs args;

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final _query = TextEditingController();
  final Set<String> _invited = {};

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(String name) {
    final q = _query.text.trim().toLowerCase();
    return q.isEmpty || name.toLowerCase().contains(q);
  }

  void _done() {
    final state = context.appRead;
    if (state.isNewAccount) state.confirmRequestedContacts();
    if (widget.args.fromOnboarding) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final onClarity = state.contactsOnClarity.map(state.person).where((p) => _matches(p.name)).toList();
    final invites = MockData.contactsToInvite.where((c) => _matches(c.name)).toList();
    final requested = state.contactsOnClarity.where(state.isRequested).length;

    return SheetScaffold(
      sheetTop: 248,
      resizeToAvoidBottomInset: true,
      header: Column(
        children: [
          HeaderBar(
            leading: GlassIconButton(
              icon: AppIcon.back,
              iconSize: 20,
              semanticLabel: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            center: Text(
              'Find friends',
              style: AppText.sans(16, weight: FontWeight.w700, color: AppColors.white),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 16,
              children: [
                ProgressRing(
                  size: 100,
                  progress: 120 / 289,
                  strokeWidth: 3,
                  child: GlassOrb(
                    size: 80,
                    strength: 0.92,
                    child: Text(
                      '${state.isRemote ? state.contactsOnClarity.length : MockData.matchedContacts}',
                      style: AppText.sans(34, weight: FontWeight.w800, letterSpacing: -1, color: AppColors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const AccentTitle(
                        lead: 'of your contacts are ',
                        accent: 'already here',
                        size: 22,
                        accentSize: 25,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                      Text(
                        'From ${MockData.sharedContacts} contacts you shared',
                        style: AppText.sans(13, color: AppColors.onBlueSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: [
          SearchField(
            controller: _query,
            hint: 'Search your contacts',
            look: SearchFieldLook.flat,
            height: 50,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ON CLARITY', style: AppText.sectionLabel()),
                TextLinkButton(
                  label: 'Add all',
                  height: 36,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blue,
                  onPressed: () {
                    for (final p in state.contactsOnClarity) {
                      if (!state.isFriend(p) && !state.isRequested(p)) state.toggleRequest(p);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final p in onClarity)
            ContactRow(
              avatar: InitialsAvatar.person(
                p,
                fontSize: 15,
                onTap: () => Navigator.pushNamed(context, Routes.friend, arguments: p.id),
              ),
              title: p.name,
              subtitle: '${p.handle} · ${p.placesCount} places · ${p.citiesCount} cities',
              action: _AddButton(
                friend: state.isFriend(p.id),
                requested: state.isRequested(p.id),
                onTap: () => state.toggleRequest(p.id),
              ),
            ),
          const SizedBox(height: 20),
          const SectionLabel('INVITE TO CLARITY'),
          const SizedBox(height: 14),
          for (final c in invites)
            ContactRow(
              avatar: GhostAvatar(label: c.initials),
              title: c.name,
              subtitle: 'Not on Clarity yet',
              action: PillButton(
                label: _invited.contains(c.id) ? 'Invited' : 'Invite',
                minWidth: 96,
                background: _invited.contains(c.id) ? AppColors.successBg : AppColors.white,
                foreground: AppColors.ink,
                dashedBorder: AppColors.ink,
                onPressed: () => setState(() => _invited.add(c.id)),
              ),
            ),
          const SizedBox(height: 18),
          Pressable(
            onTap: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Choose more contacts in iOS Settings › Clarity › Contacts.'))),
            child: DashedBorder(
              color: AppColors.blueLight,
              radius: 20,
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  spacing: 12,
                  children: [
                    const AppIconView(AppIcon.plus, size: 20, color: AppColors.blue),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Add more contacts',
                          style: AppText.sans(14, weight: FontWeight.w800, color: AppColors.navy),
                        ),
                        Text(
                          'You shared only some contacts with Clarity',
                          style: AppText.sans(12, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      sheetOverlays: [
        BottomFadeBar(
          child: PrimaryButton(label: requested > 0 ? 'Done · $requested requested' : 'Done', onPressed: _done),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.friend, required this.requested, required this.onTap});

  final bool friend;
  final bool requested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (friend) {
      return PillButton(
        label: 'Friends',
        minWidth: 96,
        background: AppColors.successBg,
        foreground: AppColors.success,
        onPressed: null,
      );
    }
    return PillButton(
      label: requested ? 'Requested' : 'Add',
      minWidth: 96,
      background: requested ? AppColors.white : AppColors.ink,
      foreground: requested ? AppColors.slate : AppColors.white,
      dashedBorder: requested ? AppColors.chipBorder : null,
      onPressed: onTap,
    );
  }
}
