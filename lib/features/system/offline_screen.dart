import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';

/// 24a · Offline — what still works, and what's queued to sync.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

enum _Phase { idle, checking, failed }

class _OfflineScreenState extends State<OfflineScreen> {
  _Phase _phase = _Phase.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _retry() {
    if (_phase == _Phase.checking) return;
    setState(() => _phase = _Phase.checking);
    _timer = Timer(const Duration(milliseconds: 1400), () => setState(() => _phase = _Phase.failed));
  }

  @override
  Widget build(BuildContext context) {
    return SkyScaffold(
      padding: const EdgeInsets.fromLTRB(22, 48, 22, 40),
      child: Column(
        children: [
          DashedBorder(
            color: AppColors.whiteA(0.6),
            shape: BoxShape.circle,
            child: SizedBox(
              width: 168,
              height: 168,
              child: Center(
                child: GlassOrb(
                  size: 130,
                  shadow: true,
                  child: const AppIconView(AppIcon.wifiOff, size: 48, color: AppColors.white, strokeWidth: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          const AccentTitle(lead: "You're ", accent: 'offline', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              "No signal in the hills? Your map still works. We'll sync when you're back.",
              textAlign: TextAlign.center,
              style: AppText.sans(15, height: 1.5, color: AppColors.onBlueSoft),
            ),
          ),
          const SizedBox(height: 26),
          const _WhatWorksCard(),
          const Spacer(),
          SizedBox(
            height: 20,
            child: Text(
              _phase == _Phase.failed ? 'Still no connection. We’ll keep trying in the background.' : '',
              textAlign: TextAlign.center,
              style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: _phase == _Phase.checking ? 'Checking…' : 'Try again', onPressed: _retry),
          ),
          const SizedBox(height: 10),
          TextLinkButton(label: 'Open my map offline', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _WhatWorksCard extends StatelessWidget {
  const _WhatWorksCard();

  @override
  Widget build(BuildContext context) {
    Widget line(String text, {required bool works}) => Row(
      spacing: 10,
      children: [
        AppIconView(
          works ? AppIcon.check : AppIcon.close,
          size: 18,
          color: works ? AppColors.success : AppColors.muted,
          strokeWidth: 2.4,
        ),
        Text(
          text,
          style: AppText.sans(14, weight: FontWeight.w600, color: works ? AppColors.navy : AppColors.slate),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.whiteA(0.85), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          line('Your map and saved places', works: true),
          line('Writing reviews, posted later', works: true),
          line('Feed, search and new friends', works: false),
          Container(height: 1, color: AppColors.fieldBorder),
          Row(
            spacing: 10,
            children: [
              DashedBorder(
                color: AppColors.blue,
                shape: BoxShape.circle,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(child: AppIconView(AppIcon.clock, size: 16, color: AppColors.blue)),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppText.sans(13, weight: FontWeight.w600, height: 1.4, color: AppColors.navy),
                    children: const [
                      TextSpan(
                        text: '1 review waiting to post\n',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: 'Neermahal · saved on your phone'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
