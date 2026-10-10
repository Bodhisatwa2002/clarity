import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/map_art.dart';
import '../shared/widgets/pressable.dart';

enum ShareTarget { map, place, list }

/// 17 · Share sheet. Opens over the current screen.
Future<void> showShareSheet(BuildContext context, {ShareTarget target = ShareTarget.map, String? placeId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    barrierColor: AppColors.scrim,
    backgroundColor: Colors.transparent,
    builder: (_) => ShareSheet(initial: target, placeId: placeId ?? 'neermahal'),
  );
}

class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.initial, required this.placeId});

  final ShareTarget initial;
  final String placeId;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  late ShareTarget _target = widget.initial;
  bool _copied = false;

  ({String kicker, String title, String link}) _card(AppState state) {
    switch (_target) {
      case ShareTarget.map:
        return (
          kicker: "${state.firstName.isEmpty ? 'My' : "${state.firstName}'s"} map · ${state.placesCount} places",
          title: 'Where I’ve been, honestly',
          link: 'clarity.in/${state.username}',
        );
      case ShareTarget.place:
        final place = state.place(widget.placeId);
        final mine = state.myVisitFor(place.id);
        final rating = mine?.rating ?? state.friendsRating(place.id);
        return (
          kicker: '${place.category.label}${rating == null ? '' : ' · ${Fmt.rating(rating)} from ${state.firstName}'}',
          title: place.name,
          link: 'clarity.in/${state.username}/${place.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
        );
      case ShareTarget.list:
        return (
          kicker: 'List · 9 places · 4 friends',
          title: MockData.goaTrip.title,
          link: 'clarity.in/l/goa-trip-2027',
        );
    }
  }

  void _copy(String link) {
    Clipboard.setData(ClipboardData(text: 'https://$link'));
    setState(() => _copied = true);
  }

  void _sendTo(String app) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $app…')));
  }

  @override
  Widget build(BuildContext context) {
    final card = _card(context.app);
    return Container(
      height: 640,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 34),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Share', style: AppText.sans(22, weight: FontWeight.w700, letterSpacing: -0.4)),
              Pressable(
                semanticLabel: 'Close',
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.segment, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const AppIconView(AppIcon.close, size: 16, strokeWidth: 2.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedTabs(
            labels: const ['My map', 'This place', 'A list'],
            selected: _target.index,
            onChanged: (i) => setState(() {
              _target = ShareTarget.values[i];
              _copied = false;
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: _PreviewCard(kicker: card.kicker, title: card.title, link: card.link),
          ),
          const SizedBox(height: 16),
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
                      card.link,
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
                    onPressed: () => _copy(card.link),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ShareApp(
                label: 'WhatsApp',
                icon: AppIcon.whatsapp,
                bg: AppColors.successBg,
                fg: AppColors.success,
                onTap: () => _sendTo('WhatsApp'),
              ),
              _ShareApp(
                label: 'Story',
                icon: AppIcon.instagram,
                bg: const Color(0xFFFDE2EC),
                fg: const Color(0xFFA61E4D),
                onTap: () => _sendTo('Instagram'),
              ),
              _ShareApp(
                label: 'Messages',
                icon: AppIcon.chatPlain,
                bg: AppColors.tintStrong,
                fg: const Color(0xFF1D4E9E),
                onTap: () => _sendTo('Messages'),
              ),
              _ShareApp(
                label: 'More',
                icon: AppIcon.more,
                fg: AppColors.slate,
                dashed: true,
                onTap: () => _sendTo('the share sheet'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Friends without Clarity can open the link in any browser.',
            textAlign: TextAlign.center,
            style: AppText.sans(12, weight: FontWeight.w400, height: 1.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.kicker, required this.title, required this.link});

  final String kicker;
  final String title;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.shareCard,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 18)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              const AppIconView(AppIcon.pin, size: 11, color: AppColors.white, strokeWidth: 2.4),
              Text(
                'CLARITY',
                style: AppText.sans(10, weight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            kicker,
            style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.onBlueSoft),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.serif(26, height: 1.05, color: AppColors.white),
          ),
          const Spacer(),
          Container(
            height: 92,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.whiteA(0.85), borderRadius: BorderRadius.circular(16)),
            child: const FittedBox(fit: BoxFit.cover, child: MapArtView(MapArt.shareCard)),
          ),
          const SizedBox(height: 10),
          Text(
            link,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(11, weight: FontWeight.w700, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

class _ShareApp extends StatelessWidget {
  const _ShareApp({
    required this.label,
    required this.icon,
    required this.fg,
    required this.onTap,
    this.bg,
    this.dashed = false,
  });

  final String label;
  final AppIcon icon;
  final Color? bg;
  final Color fg;
  final bool dashed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: AppIconView(icon, size: dashed ? 22 : 24, color: fg),
    );
    if (dashed) circle = DashedBorder(color: AppColors.subtle, shape: BoxShape.circle, child: circle);
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Column(
          spacing: 6,
          children: [
            circle,
            Text(
              label,
              style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
