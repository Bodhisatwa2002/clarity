import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/glass.dart';

/// 01 · Splash — brand moment while the app boots.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _tick;
  Timer? _done;
  int _dot = 0;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 380), (_) => setState(() => _dot = (_dot + 1) % 3));
    _done = Timer(const Duration(milliseconds: 1900), () async {
      // A restored Supabase session goes straight to the map.
      final state = context.appRead;
      await state.ready;
      // Only advance if the splash is still on screen (deep links may cover it).
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        final signedIn = state.isSignedIn && state.hasProfile;
        Navigator.pushReplacementNamed(context, signedIn ? Routes.home : Routes.welcome);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _done?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.splash),
          child: LayoutBuilder(
            builder: (context, box) {
              // Concentric rings are drawn relative to a 390-wide frame.
              final dx = (box.maxWidth - 390) / 2;
              return Stack(
                children: [
                  _ring(left: -65 + dx, top: 90, size: 520, opacity: 0.18),
                  _ring(left: -155 + dx, top: 0, size: 700, opacity: 0.10),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _LogoOrb(),
                        const SizedBox(height: 28),
                        Text(
                          'Clarity',
                          style: AppText.sans(
                            46,
                            weight: FontWeight.w700,
                            letterSpacing: -1.6,
                            height: 1,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Honest places, from people you trust.',
                          textAlign: TextAlign.center,
                          style: AppText.serif(20, italic: true, height: 1.3, color: AppColors.onBlueSoft),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 64,
                    child: Column(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            for (var i = 0; i < 3; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _dot ? AppColors.navy : AppColors.navy.withValues(alpha: 0.4),
                                ),
                              ),
                          ],
                        ),
                        Text('Loading your map…', style: AppText.sans(13, color: AppColors.navy)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ring({required double left, required double top, required double size, required double opacity}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.whiteA(opacity)),
        ),
      ),
    );
  }
}

class _LogoOrb extends StatelessWidget {
  const _LogoOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ProgressRing(
            size: 184,
            inset: 6,
            progress: 190 / (2 * math.pi * 86),
            strokeWidth: 3,
            trackWidth: 2,
            trackColor: AppColors.whiteA(0.28),
            startAngle: -200 * math.pi / 180,
          ),
          Positioned(
            left: 6,
            top: 59,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            ),
          ),
          CircleOuterShadow(
            shadows: [
              BoxShadow(
                color: const Color(0xFF143C8C).withValues(alpha: 0.25),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.36, -0.48),
                  radius: 0.9,
                  colors: [AppColors.whiteA(0.62), AppColors.whiteA(0.2), AppColors.whiteA(0.08)],
                  stops: const [0, 0.46, 1],
                ),
                border: Border.all(color: AppColors.whiteA(0.65)),
              ),
              alignment: Alignment.center,
              child: const AppIconView(AppIcon.pin, size: 60, color: AppColors.white, strokeWidth: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
