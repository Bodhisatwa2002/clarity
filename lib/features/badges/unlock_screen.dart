import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/badge.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'badge_share_sheet.dart';
import 'widgets/badge_emblem.dart';

/// 28 · Badge unlocked (PRD BDG-5, design boards 28a–c): first badge, level
/// up, or two at once. Opened with the ids of one or two badges.
///
/// Motion (board notes): ground fades in; at 120 ms the badge scales
/// 0.6 → 1.06 → 1.0 (400 ms); at 400 ms the mint ring fills (600 ms); at
/// 1000 ms a soft haptic and ~24 pieces of confetti (1 s); at 1200 ms the
/// text and buttons fade up. Reduce Motion: cross-fade only, haptic stays.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key, required this.badgeIds});

  final List<String> badgeIds;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  );
  late final AnimationController _confetti = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  Timer? _haptic;

  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0.6), weight: 120),
    TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 280),
    TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 120),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 930),
  ]).animate(_intro);
  late final Animation<double> _ring = CurvedAnimation(
    parent: _intro,
    curve: const Interval(400 / 1450, 1000 / 1450, curve: Curves.easeOut),
  );
  late final Animation<double> _text = CurvedAnimation(
    parent: _intro,
    curve: const Interval(1200 / 1450, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.appRead.markBadgesSeen(widget.badgeIds);
      if (MediaQuery.disableAnimationsOf(context)) {
        _intro.value = 1;
      } else {
        _intro.forward();
      }
      _haptic = Timer(const Duration(milliseconds: 1000), () {
        HapticFeedback.mediumImpact();
        if (mounted && !MediaQuery.disableAnimationsOf(context)) _confetti.forward();
      });
    });
  }

  @override
  void dispose() {
    _haptic?.cancel();
    _intro.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final badges = [for (final id in widget.badgeIds.take(2)) state.badge(id)];
    final first = badges.first;
    final pair = badges.length > 1;
    final levelUp = !pair && first.def.hasLevels && first.level > 1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final next = !first.maxed && first.def.hasLevels ? first : state.nextBadge;

    final (kicker, lead, accent) = pair
        ? ('2 NEW BADGES', 'Two at ', 'once')
        : levelUp
        ? ('LEVEL UP', 'You’re now ', first.titleWithLevel)
        : ('NEW BADGE', 'You unlocked ', first.titleWithLevel);

    return Stack(
      children: [
        SkyScaffold(
          child: AnimatedBuilder(
            animation: _intro,
            builder: (context, _) => Column(
              children: [
                const SizedBox(height: 24),
                GlassTag(label: kicker),
                const SizedBox(height: 28),
                Transform.scale(
                  scale: reduceMotion ? 1 : _scale.value,
                  child: Opacity(
                    opacity: reduceMotion ? _intro.value.clamp(0, 1) : 1,
                    child: GlassOrb(
                      size: pair ? 236 : 220,
                      shadow: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          for (final b in badges)
                            BadgeEmblem(
                              badge: b,
                              size: pair ? 104 : 168,
                              ringFill: _ring.value < 1 ? _ring.value : null,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: _text.value,
                  child: Transform.translate(
                    offset: Offset(0, reduceMotion ? 0 : 8 * (1 - _text.value)),
                    child: Column(
                      children: [
                        AccentTitle(lead: lead, accent: accent, size: 30, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Text(
                          _why(state, badges),
                          textAlign: TextAlign.center,
                          style: AppText.sans(15, height: 1.5, color: AppColors.onBlueSoft),
                        ),
                        if (next != null && next.nextStep != null) ...[
                          const SizedBox(height: 20),
                          _NextCard(badge: next),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _text.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      PrimaryButton(label: 'Keep exploring', onPressed: () => Navigator.pop(context)),
                      DashedButton(
                        label: pair ? 'Share both badges' : 'Share badge',
                        expand: true,
                        background: Colors.transparent,
                        borderColor: AppColors.navy,
                        foreground: AppColors.navy,
                        onPressed: () => showBadgesShareSheet(context, [for (final b in badges) b.id]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!reduceMotion)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (_, _) =>
                  CustomPaint(size: MediaQuery.sizeOf(context), painter: _ConfettiPainter(_confetti.value)),
            ),
          ),
      ],
    );
  }

  /// The one line that says what counted (board 28: "Your map starts with
  /// one place: Neermahal.").
  static String _why(AppState state, List<BadgeProgress> badges) {
    final b = badges.first;
    // First pin names your first place; everything else the latest one.
    final ids = b.id == 'first_pin' ? b.placeIds.reversed.toList() : b.placeIds;
    final latest = ids.isEmpty
        ? (state.myVisits.isEmpty ? null : state.place(state.myVisits.first.placeId).name)
        : state.place(ids.first).name;
    if (badges.length > 1) {
      return latest == null
          ? '${badges[0].def.title} and ${badges[1].def.title}.'
          : '${badges[0].def.title} and ${badges[1].def.title}, both from $latest.';
    }
    final friend = state.friends.isEmpty ? null : state.friends.first.firstName;
    final list = state.lists.where((l) => l.ownerId == state.me.id).firstOrNull?.title;
    return switch (b.id) {
      'first_pin' when latest != null => 'Your map starts with one place: $latest.',
      'one_thing' when latest != null => 'Your first tip is on $latest. Friends will thank you.',
      'first_friend' when friend != null => 'You and $friend can see each other’s maps now.',
      'list_maker' when list != null => 'Your first list: $list.',
      'map_sharer' => 'Your map is out there. Friends without the app can open it too.',
      'straight_talker' when latest != null => 'An honest no helps friends most. Thanks for $latest.',
      'taste_twin' => 'A ${b.progress}% taste match with a friend. Their picks are worth a look.',
      'squad_explorer' => '${b.progress} friends are planning with you.',
      'regular' when latest != null => '${b.progress} visits to $latest. They know your order by now.',
      'hidden_gem' when latest != null => 'You found $latest before any of your friends.',
      _ when b.def.unit != null && latest != null =>
        '${b.progress} ${b.def.units(b.progress)} logged. The latest was $latest.',
      _ => b.def.howTo,
    };
  }
}

/// "NEXT · 9 more places to Places I" with a small mint ring.
class _NextCard extends StatelessWidget {
  const _NextCard({required this.badge});

  final BadgeProgress badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: BoxDecoration(color: AppColors.whiteA(0.85), borderRadius: BorderRadius.circular(22)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          BadgeEmblem(badge: badge, size: 44),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT',
                  style: AppText.sans(11, weight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.muted),
                ),
                Text(
                  badge.nextStep!,
                  style: AppText.sans(14, weight: FontWeight.w700, height: 1.3, color: AppColors.navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// About 24 pieces in mint, white and blue-100, drifting down and fading.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  static final List<({double x, double y, double drift, double size, double spin, int color})> _pieces = () {
    final r = math.Random(7);
    return [
      for (var i = 0; i < 24; i++)
        (
          x: r.nextDouble(),
          y: 0.12 + r.nextDouble() * 0.25,
          drift: (r.nextDouble() - 0.5) * 0.12,
          size: 5 + r.nextDouble() * 5,
          spin: r.nextDouble() * math.pi,
          color: i % 3,
        ),
    ];
  }();

  static const _colors = [AppColors.mint, AppColors.white, AppColors.tintStrong];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    for (final p in _pieces) {
      final paint = Paint()..color = _colors[p.color].withValues(alpha: (1 - t).clamp(0, 1));
      final pos = Offset((p.x + p.drift * t) * size.width, (p.y + 0.35 * t) * size.height);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin + t * 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
