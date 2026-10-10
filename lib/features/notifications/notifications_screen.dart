import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/social.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../review/write_review_screen.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';

/// 22 · Notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Answer to the friend request card: true accepted, false declined.
  bool? _requestAnswer;

  void _open(AppNotification n) {
    switch (n.kind) {
      case NotificationKind.joined:
        Navigator.pushNamed(context, Routes.friend, arguments: n.personId);
      case NotificationKind.nudge:
        Navigator.pushNamed(context, Routes.review, arguments: const ReviewArgs('lakeside-cafe', editing: true));
      case NotificationKind.listInvite:
        Navigator.pushNamed(context, Routes.collabList);
      default:
        break;
    }
  }

  void _answer(AppNotification n, bool accept) {
    final state = context.appRead;
    accept ? state.acceptRequest(n.personId!) : state.declineRequest(n.personId!);
    setState(() => _requestAnswer = accept);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final unread = state.unreadCount;
    final groups = [
      ('TODAY', MockData.notifications.where((n) => n.isToday).toList()),
      ('THIS WEEK', MockData.notifications.where((n) => !n.isToday).toList()),
    ];

    return SheetScaffold(
      sheetTop: 196,
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
            trailing: PillButton(
              label: 'Mark all read',
              height: 44,
              fontWeight: FontWeight.w700,
              background: Colors.transparent,
              dashedBorder: AppColors.whiteA(0.9),
              onPressed: state.markAllNotificationsRead,
            ),
          ),
          const SizedBox(height: 16),
          Text('Notifications', style: AppText.screenTitle()),
          const SizedBox(height: 4),
          Text(unread > 0 ? '$unread new' : 'You’re all caught up', style: AppText.headerSubtitle()),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
        children: [
          for (final (title, items) in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
              child: Text(
                title,
                style: AppText.sans(12, weight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.slate),
              ),
            ),
            for (final n in items) ...[
              _NotificationCard(
                notification: n,
                unread: n.unread && state.hasUnreadNotifications,
                requestAnswer: n.kind == NotificationKind.friendRequest ? _requestAnswer : null,
                onCta: () => _open(n),
                onAnswer: (accept) => _answer(n, accept),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.unread,
    required this.requestAnswer,
    required this.onCta,
    required this.onAnswer,
  });

  final AppNotification notification;
  final bool unread;
  final bool? requestAnswer;
  final VoidCallback onCta;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final state = context.app;
    final avatar = n.personId == null
        ? InitialsAvatar(
            initials: n.initials,
            background: AppColors.ink,
            foreground: AppColors.white,
            size: 44,
            fontSize: 14,
          )
        : InitialsAvatar.person(state.person(n.personId!), size: 44, fontSize: 14);
    final isRequest = n.kind == NotificationKind.friendRequest;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: unread ? AppColors.tint : AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          avatar,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text.rich(
                  TextSpan(
                    style: AppText.sans(14, weight: FontWeight.w500, height: 1.4, color: AppColors.text),
                    children: [
                      TextSpan(
                        text: n.who,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: ' ${n.text} '),
                      TextSpan(
                        text: '· ${n.when}',
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (isRequest && requestAnswer == null)
                  Row(
                    spacing: 8,
                    children: [
                      PillButton(
                        label: 'Accept',
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        onPressed: () => onAnswer(true),
                      ),
                      PillButton(
                        label: 'Decline',
                        fontWeight: FontWeight.w700,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        background: AppColors.white,
                        foreground: AppColors.text,
                        dashedBorder: AppColors.subtle,
                        onPressed: () => onAnswer(false),
                      ),
                    ],
                  ),
                if (isRequest && requestAnswer != null)
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          requestAnswer! ? 'You are now friends' : 'Request declined',
                          style: AppText.sans(12, weight: FontWeight.w800, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                if (n.cta != null)
                  PillButton(
                    label: n.cta!,
                    height: 38,
                    background: Colors.transparent,
                    foreground: AppColors.ink,
                    dashedBorder: AppColors.ink,
                    onPressed: onCta,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!unread) return card;
    return Stack(
      children: [
        card,
        const Positioned(right: 14, top: 18, child: Dot(color: AppColors.blue, size: 9)),
      ],
    );
  }
}
