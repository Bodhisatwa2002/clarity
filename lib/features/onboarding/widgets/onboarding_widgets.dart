import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/layout.dart';

/// Back button + "Step n of 3" used across the sign-up steps.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, this.total = 3});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      leading: GlassIconButton(
        icon: AppIcon.back,
        iconSize: 20,
        semanticLabel: 'Back',
        onPressed: () => Navigator.maybePop(context),
      ),
      center: Text(
        'Step $step of $total',
        style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.white),
      ),
    );
  }
}

/// Centered title + subtitle at the top of each onboarding step.
class StepIntro extends StatelessWidget {
  const StepIntro({super.key, required this.title, required this.subtitle});

  final Widget title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        title,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppText.sans(15, height: 1.45, color: AppColors.onBlueSoft),
          ),
        ),
      ],
    );
  }
}

/// Plain bold step title ("What's your number?").
class StepTitle extends StatelessWidget {
  const StepTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.center, style: AppText.screenTitle());
  }
}

/// Small navy footnote under the main button.
class Footnote extends StatelessWidget {
  const Footnote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.sans(12, weight: FontWeight.w400, height: 1.5, color: AppColors.navy),
    );
  }
}

/// The white pill input used on blue onboarding screens.
class WhitePillField extends StatelessWidget {
  const WhitePillField({
    super.key,
    required this.child,
    this.height = 58,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: AppShadows.soft,
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

/// Frosted info card with an icon ("Only used to verify you…").
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.icon, required this.text});

  final AppIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.whiteA(0.82), borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIconView(icon, size: 20, color: AppColors.blue, strokeWidth: 1.8),
          ),
          Expanded(
            child: Text(text, style: AppText.sans(13, height: 1.45, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}
