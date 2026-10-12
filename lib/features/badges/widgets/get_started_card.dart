import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/models/badge.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../share/share_sheet.dart';
import '../../shared/widgets/pressable.dart';
import '../badge_detail_sheet.dart';
import 'badge_emblem.dart';

/// "Get started" (PRD BDG-10, design board 34): five small steps, each
/// unlocking a starter badge. Shown on the empty map and the profile until
/// all five are done.
class GetStartedCard extends StatelessWidget {
  const GetStartedCard({super.key, this.color = AppColors.white});

  final Color color;

  static const _tasks = {
    'first_pin': 'Add your first place',
    'one_thing': 'Write one thing to know',
    'first_friend': 'Add a friend',
    'list_maker': 'Make a list',
    'map_sharer': 'Share your map',
  };

  @override
  Widget build(BuildContext context) {
    final steps = context.app.starterBadges;
    final done = steps.where((b) => b.earned).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 12,
            children: [
              _Ring(done: done, total: steps.length),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text('Get started', style: AppText.sans(17, weight: FontWeight.w700)),
                    Text(
                      done == steps.length
                          ? 'All set. Your map is ready to grow.'
                          : 'Each step unlocks a starter badge.',
                      style: AppText.sans(13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final b in steps) _Step(badge: b, label: _tasks[b.id]!),
        ],
      ),
    );
  }

  /// Where each step's action happens.
  static void open(BuildContext context, String badgeId) {
    switch (badgeId) {
      case 'first_pin' || 'one_thing':
        Navigator.pushNamed(context, Routes.addPlace);
      case 'first_friend':
        Navigator.pushNamed(context, Routes.findFriends);
      case 'list_maker':
        Navigator.pushNamed(context, Routes.collabList);
      case 'map_sharer':
        showShareSheet(context, target: ShareTarget.map);
    }
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.badge, required this.label});

  final BadgeProgress badge;
  final String label;

  @override
  Widget build(BuildContext context) {
    final done = badge.earned;
    return Pressable(
      onTap: () => done ? showBadgeDetail(context, badge.id) : GetStartedCard.open(context, badge.id),
      semanticLabel: done ? '$label, done. Unlocked ${badge.def.title}' : '$label. Unlocks ${badge.def.title}',
      child: SizedBox(
        height: 56,
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.ink : null,
                border: done ? null : Border.all(color: AppColors.chipBorder, width: 1.5),
              ),
              alignment: Alignment.center,
              child: done ? const AppIconView(AppIcon.check, size: 13, color: AppColors.white, strokeWidth: 2.8) : null,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 1,
                children: [
                  Text(
                    label,
                    style: AppText.sans(
                      15,
                      weight: FontWeight.w700,
                      color: done ? AppColors.muted : AppColors.ink,
                    ).copyWith(decoration: done ? TextDecoration.lineThrough : null),
                  ),
                  Text(
                    '${done ? 'Unlocked' : 'Unlocks'} ${badge.def.title}',
                    style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            BadgeEmblem(badge: badge, size: 36),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _RingPainter(done / total),
        child: Center(
          child: Text(
            '$done/$total',
            style: AppText.sans(13, weight: FontWeight.w800, color: AppColors.navy),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = AppColors.badgeTrack);
    if (t > 0) canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * t, false, paint..color = AppColors.mint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

/// The one-line version for the empty map: "Get started · 0 of 5", opening
/// the checklist on All badges.
class GetStartedStrip extends StatelessWidget {
  const GetStartedStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = context.app.starterBadges;
    final done = steps.where((b) => b.earned).length;
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.badges),
      semanticLabel: 'Get started, $done of ${steps.length} done. Each step unlocks a starter badge',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            SizedBox(width: 36, height: 36, child: CustomPaint(painter: _RingPainter(done / steps.length))),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get started · $done of ${steps.length}', style: AppText.sans(14, weight: FontWeight.w700)),
                  Text(
                    'Each step unlocks a starter badge',
                    style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const AppIconView(AppIcon.chevronRight, size: 16, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}
