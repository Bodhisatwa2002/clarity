import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/models/badge.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import 'badge_detail_sheet.dart';
import 'widgets/badge_emblem.dart';

/// When to celebrate (PRD BDG-5, BDG-6). Call after an action that can earn a
/// badge: posting a review, making a list, accepting a friend, sharing your
/// map.
abstract final class BadgeMoments {
  /// Everyone's progress right now, to compare with after an action.
  static Map<String, int> snapshot(AppState state) => {for (final b in state.badges) b.id: b.progress};

  /// Shows the unlock screen for up to two new badges. Returns whether it
  /// did; a third waits for the next action.
  static bool celebrate(NavigatorState navigator, AppState state) {
    final pending = state.pendingUnlocks;
    if (pending.isEmpty) return false;
    navigator.pushNamed(Routes.unlock, arguments: [for (final b in pending.take(2)) b.id]);
    return true;
  }

  /// After posting a review: the unlock if one was earned, otherwise the
  /// progress toast for the badge that moved closest, otherwise a plain
  /// confirmation.
  static void afterReview({
    required NavigatorState navigator,
    required ScaffoldMessengerState messenger,
    required AppState state,
    required Map<String, int> before,
    required String placeId,
  }) {
    // Let the page transition finish first.
    Timer(const Duration(milliseconds: 450), () {
      if (!navigator.mounted) return;
      if (celebrate(navigator, state)) return;
      final moved =
          state.badges
              .where((b) => b.progress > (before[b.id] ?? 0) && !b.maxed && !b.def.isSecret && b.nextStep != null)
              .toList()
            ..sort((a, b) => b.fraction.compareTo(a.fraction));
      messenger.hideCurrentSnackBar();
      if (moved.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Review posted to your map')));
        return;
      }
      messenger.showSnackBar(
        progressToast(
          badge: moved.first,
          placeName: state.place(placeId).name,
          onTap: () {
            messenger.hideCurrentSnackBar();
            showBadgeDetail(navigator.context, moved.first.id);
          },
        ),
      );
    });
  }

  /// 29 · "Review posted · Neermahal counted — 2 more viewpoints to
  /// Viewpoint chaser". Stays 4 s and never blocks.
  static SnackBar progressToast({required BadgeProgress badge, required String placeName, VoidCallback? onTap}) {
    return SnackBar(
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.white,
      elevation: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Semantics(
          button: true,
          label: 'Review posted. ${badge.nextStep}. Open ${badge.def.title}',
          excludeSemantics: true,
          child: Row(
            spacing: 12,
            children: [
              BadgeEmblem(badge: badge, size: 54),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      'Review posted · $placeName counted',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.success),
                    ),
                    Text(
                      badge.nextStep!,
                      style: AppText.sans(15, weight: FontWeight.w700, height: 1.3, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
