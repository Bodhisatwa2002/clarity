import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/layout.dart';

/// 24b · "Couldn't load the feed", with a retry that recovers, plus the
/// failed-upload toast.
class FeedErrorView extends StatefulWidget {
  const FeedErrorView({super.key, required this.onRecovered});

  /// Called when the user opens the recovered feed.
  final VoidCallback onRecovered;

  @override
  State<FeedErrorView> createState() => _FeedErrorViewState();
}

enum _Phase { error, retrying, ok }

class _FeedErrorViewState extends State<FeedErrorView> {
  _Phase _phase = _Phase.error;
  bool _showToast = true;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _retry() {
    if (_phase == _Phase.retrying) return;
    setState(() => _phase = _Phase.retrying);
    _timer = Timer(const Duration(milliseconds: 1200), () => setState(() => _phase = _Phase.ok));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          right: 18,
          top: 60,
          child: Column(
            spacing: 16,
            children: [
              DashedBorder(
                color: AppColors.dangerRing,
                shape: BoxShape.circle,
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Center(
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const AppIconView(AppIcon.warning, size: 36, color: AppColors.danger, strokeWidth: 1.8),
                    ),
                  ),
                ),
              ),
              const AccentTitle(
                lead: "Couldn't load ",
                accent: 'the feed',
                size: 26,
                letterSpacing: -0.6,
                height: 1.15,
                color: AppColors.ink,
                textAlign: TextAlign.center,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(
                  _phase == _Phase.ok
                      ? 'All good now.'
                      : 'Something went wrong on our side. Your reviews are safe. Try again in a moment.',
                  textAlign: TextAlign.center,
                  style: AppText.sans(15, weight: FontWeight.w400, height: 1.5, color: AppColors.slate),
                ),
              ),
              if (_phase == _Phase.ok)
                PillButton(
                  label: 'Feed is back. Open it',
                  height: 52,
                  fontSize: 15,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  background: AppColors.successBg,
                  foreground: AppColors.success,
                  onPressed: widget.onRecovered,
                )
              else
                PillButton(
                  label: _phase == _Phase.retrying ? 'Retrying…' : 'Try again',
                  height: 56,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  onPressed: _retry,
                ),
              Text(
                'Error code FEED-503',
                style: AppText.sans(12, weight: FontWeight.w400, color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (_showToast)
          Positioned(
            left: 16,
            right: 16,
            bottom: 108,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                spacing: 10,
                children: [
                  const AppIconView(AppIcon.alertCircle, size: 18, color: AppColors.dangerSoft),
                  Expanded(
                    child: Text(
                      "1 photo didn't upload",
                      style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.white),
                    ),
                  ),
                  PillButton(
                    label: 'Retry',
                    background: AppColors.white,
                    foreground: AppColors.ink,
                    onPressed: () => setState(() => _showToast = false),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
