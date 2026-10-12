import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/icons/app_icons.dart';
import '../../core/models/badge.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/share_links.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/badge_emblem.dart';
import 'widgets/badge_stamp.dart';

/// Share a badge (PRD BDG-12, design boards 35a/b): a calm card with the
/// badge, one line and your map link, as a square or a Story, drawn as the
/// emblem or a passport stamp. Share image renders it at 1080 px wide and
/// opens the system share sheet; copying the link counts as sharing your map.
Future<void> showBadgeShareSheet(BuildContext context, String badgeId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => BadgeShareSheet(badgeIds: [badgeId]),
  );
}

/// Same, for the two-at-once unlock ("Share both badges").
Future<void> showBadgesShareSheet(BuildContext context, List<String> badgeIds) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => BadgeShareSheet(badgeIds: badgeIds),
  );
}

enum ShareCardFormat { square, story }

class BadgeShareSheet extends StatefulWidget {
  const BadgeShareSheet({super.key, required this.badgeIds});

  final List<String> badgeIds;

  @override
  State<BadgeShareSheet> createState() => _BadgeShareSheetState();
}

class _BadgeShareSheetState extends State<BadgeShareSheet> {
  final _card = GlobalKey();
  ShareCardFormat _format = ShareCardFormat.square;
  bool _stamp = false;
  bool _copied = false;
  bool _sharing = false;

  void _copy(String link) {
    Clipboard.setData(ClipboardData(text: ShareLinks.https(link)));
    context.appRead.recordMapShared();
    setState(() => _copied = true);
  }

  /// Renders the card at 1080 px wide and hands it to the system share sheet
  /// (WhatsApp, Instagram Stories, Save Image…).
  Future<void> _shareImage(String link) async {
    final boundary = _card.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    final state = context.appRead;
    final origin = boundary.localToGlobal(Offset.zero) & boundary.size;
    try {
      final image = await boundary.toImage(pixelRatio: 1080 / boundary.size.width);
      final png = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      if (png == null) throw StateError('Could not draw the card');
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(png.buffer.asUint8List(), mimeType: 'image/png')],
          fileNameOverrides: const ['clarity-badge.png'],
          text: ShareLinks.https(link),
          sharePositionOrigin: origin,
        ),
      );
      state.recordMapShared();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't share the image. Copy the link instead.")));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final badges = [for (final id in widget.badgeIds) state.badge(id)];
    final link = ShareLinks.map(state.username);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Share badge', style: AppText.sans(22, weight: FontWeight.w700, letterSpacing: -0.4)),
            const SizedBox(height: 14),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SegmentedTabs(
                    labels: const ['Square', 'Story'],
                    selected: _format.index,
                    onChanged: (i) => setState(() => _format = ShareCardFormat.values[i]),
                  ),
                ),
                Expanded(
                  child: SegmentedTabs(
                    labels: const ['Badge', 'Stamp'],
                    selected: _stamp ? 1 : 0,
                    onChanged: (i) => setState(() => _stamp = i == 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: RepaintBoundary(
                key: _card,
                child: BadgeShareCard(
                  firstName: state.firstName,
                  badges: badges,
                  link: link,
                  format: _format,
                  stamp: _stamp,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _sharing ? 'Getting it ready…' : 'Share image',
              icon: AppIcon.share,
              onPressed: _sharing ? null : () => _shareImage(link),
              disabledLook: DisabledLook.onWhite,
            ),
            const SizedBox(height: 12),
            DashedBorder(
              color: AppColors.subtle,
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 18, right: 6),
                child: Row(
                  spacing: 10,
                  children: [
                    const AppIconView(AppIcon.link, size: 17, color: AppColors.slate),
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(15, weight: FontWeight.w700),
                      ),
                    ),
                    PillButton(
                      label: _copied ? 'Copied' : 'Copy',
                      height: 44,
                      fontSize: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      background: _copied ? AppColors.successBg : AppColors.ink,
                      foreground: _copied ? AppColors.success : AppColors.white,
                      onPressed: () => _copy(link),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Friends without Clarity can open the link in any browser.',
              textAlign: TextAlign.center,
              style: AppText.sans(12, weight: FontWeight.w400, height: 1.5, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Pressable(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text('Done', style: AppText.sans(15, weight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card itself (boards 35a/b): badge, "Bodhi is now *Trekker II*", the
/// places that counted, the link. Square is 300×300, Story 252×448 (9:16);
/// both export at 1080 px wide.
class BadgeShareCard extends StatelessWidget {
  const BadgeShareCard({
    super.key,
    required this.firstName,
    required this.badges,
    required this.link,
    this.format = ShareCardFormat.square,
    this.stamp = false,
  });

  final String firstName;
  final List<BadgeProgress> badges;
  final String link;
  final ShareCardFormat format;
  final bool stamp;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final story = format == ShareCardFormat.story;
    final first = badges.first;
    final who = firstName.isEmpty ? 'I' : firstName;
    final names = badges.map((b) => b.titleWithLevel).join(' & ');
    final verb = badges.length == 1 && first.def.hasLevels ? 'is now' : 'earned';
    final places = first.placeIds.map((id) => state.place(id).name).toList();
    final line = switch (places.length) {
      0 => first.def.howTo,
      1 => places.single,
      _ => '${first.progress} ${first.def.units(first.progress)}, from ${places.last} to ${places.first}',
    };
    final mark = story ? 150.0 : 112.0;
    return Container(
      width: story ? 252 : 300,
      height: story ? 448 : 300,
      padding: EdgeInsets.fromLTRB(20, story ? 28 : 18, 20, story ? 24 : 16),
      decoration: BoxDecoration(gradient: AppGradients.shareCard, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              const AppIconView(AppIcon.pin, size: 11, color: AppColors.white, strokeWidth: 2.4),
              Text(
                'CLARITY',
                style: AppText.sans(10, weight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.white),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              for (final b in badges)
                stamp
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: BadgeStamp(
                          badge: b,
                          caption: stampCaption(b.placeIds.isEmpty ? null : state.place(b.placeIds.first).name, b),
                          size: badges.length == 1 ? mark : mark * 0.72,
                        ),
                      )
                    : BadgeEmblem(badge: b, size: badges.length == 1 ? mark : mark * 0.72),
            ],
          ),
          SizedBox(height: story ? 24 : 12),
          Text.rich(
            TextSpan(
              style: AppText.sans(
                story ? 22 : 19,
                weight: FontWeight.w700,
                letterSpacing: -0.4,
                color: AppColors.white,
              ),
              children: [
                TextSpan(text: '$who $verb '),
                TextSpan(
                  text: names,
                  style: AppText.serif(story ? 25 : 22, italic: true, color: AppColors.white),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            line,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(13, height: 1.4, color: AppColors.onBlueSoft),
          ),
          const Spacer(),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: AppColors.whiteA(0.9), borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text(
              link,
              style: AppText.sans(12, weight: FontWeight.w800, color: AppColors.navy),
            ),
          ),
          if (story) ...[
            const SizedBox(height: 10),
            Text(
              'Honest places, from people you trust.',
              style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.onBlueSoft),
            ),
          ],
        ],
      ),
    );
  }
}
