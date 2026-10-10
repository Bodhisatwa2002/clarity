import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
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
          const Center(child: _ContactsOrbit()),
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

class _ContactsOrbit extends StatelessWidget {
  const _ContactsOrbit();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 230,
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _OrbitPainter())),
          Positioned(
            left: 70,
            top: 55,
            child: GlassOrb(
              size: 120,
              shadow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  const AppIconView(AppIcon.contacts, size: 30, color: AppColors.white, strokeWidth: 1.7),
                  Text(
                    'Contacts',
                    style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          _bubble(left: 6, top: 70, size: 44, text: 'RS', bg: AppColors.white, fg: AppColors.blue, fontSize: 15),
          _bubble(
            left: 196,
            top: 24,
            size: 40,
            text: 'AD',
            bg: const Color(0xFFFFE3CC),
            fg: AppColors.takenFg,
            fontSize: 14,
          ),
          _bubble(
            left: 212,
            top: 148,
            size: 46,
            text: 'PK',
            bg: AppColors.successBg,
            fg: AppColors.success,
            fontSize: 15,
          ),
          Positioned(
            left: 60,
            top: 186,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(17)),
              alignment: Alignment.center,
              child: Text(
                '12 contacts on Clarity',
                style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble({
    required double left,
    required double top,
    required double size,
    required String text,
    required Color bg,
    required Color fg,
    required double fontSize,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: AppShadows.chip),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppText.sans(fontSize, weight: FontWeight.w800, color: fg),
        ),
      ),
    );
  }
}

/// Dashed ellipse with a mint arc, rotated like the design's SVG.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: const Offset(130, 115), width: 244, height: 208);
    final dashed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.whiteA(0.45);
    final oval = Path()..addOval(rect);
    for (final m in oval.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 4), dashed);
      }
    }

    canvas.save();
    canvas.translate(130, 115);
    canvas.rotate(-60 * math.pi / 180);
    canvas.translate(-130, -115);
    final arc = Path()..addOval(rect);
    final metric = arc.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, 120),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = AppColors.mint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => false;
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
