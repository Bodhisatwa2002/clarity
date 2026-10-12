import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/layout.dart';

/// The core page layout of the app: a blue gradient with a header on top
/// and a white sheet with 32pt rounded corners sliding up from [sheetTop].
///
/// [sheetTop] is the design's y-offset of the sheet on a 390×844 frame; it is
/// shifted for the device's status bar automatically.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.header,
    required this.sheetTop,
    required this.sheet,
    this.sheetColor = AppColors.white,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 20),
    this.sheetOverlays = const [],
    this.resizeToAvoidBottomInset = false,
  });

  final Widget header;
  final double sheetTop;
  final Widget sheet;
  final Color sheetColor;
  final EdgeInsets headerPadding;

  /// Widgets positioned inside the sheet's frame on top of its content —
  /// the floating nav, sticky bottom buttons, toasts.
  final List<Widget> sheetOverlays;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.blue,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.header),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: Layout.top(context),
                child: Padding(padding: headerPadding, child: header),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: Layout.y(context, sheetTop),
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: ColoredBox(
                    color: sheetColor,
                    child: Stack(
                      children: [
                        Positioned.fill(child: sheet),
                        ...sheetOverlays,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed sky-gradient page (onboarding, offline).
class SkyScaffold extends StatelessWidget {
  const SkyScaffold({
    super.key,
    required this.child,
    this.gradient = AppGradients.sky,
    this.padding = const EdgeInsets.fromLTRB(22, 0, 22, 40),
    this.resizeToAvoidBottomInset = true,
    this.scrollable = true,
  });

  /// Usually a [Column] that uses a [Spacer] to pin actions to the bottom.
  final Widget child;
  final Gradient gradient;

  /// Top padding is added on top of the device's header inset.
  final EdgeInsets padding;

  /// Shrinks the page above the keyboard so actions pinned to the bottom
  /// (Send code, Verify) stay visible while typing.
  final bool resizeToAvoidBottomInset;

  /// Lets the page scroll when it doesn't fit (small phones, big text).
  /// Turn off when [child] manages its own scrolling.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.blue,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        // Tapping outside a field closes the keyboard — the iOS number pad
        // has no Done key of its own.
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: gradient),
            child: scrollable
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: padding.copyWith(top: padding.top + Layout.top(context)),
                          child: child,
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: padding.copyWith(top: padding.top + Layout.top(context)),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}

/// A three-slot row: leading button, centered title, trailing widget.
/// Empty slots keep the title centered.
class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key, this.leading, this.center, this.trailing});

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          SizedBox(width: 44, child: leading),
          Expanded(child: Center(child: center)),
          trailing ?? const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// A headline mixing bold Manrope with an italic Newsreader accent:
/// "Your *people*", "Friends' *feed*", "No pins *yet*".
class AccentTitle extends StatelessWidget {
  const AccentTitle({
    super.key,
    required this.lead,
    required this.accent,
    this.trail = '',
    this.size = 30,
    this.accentSize,
    this.color = AppColors.white,
    this.letterSpacing = -0.8,
    this.textAlign = TextAlign.start,
    this.height = 1.1,
  });

  final String lead;
  final String accent;
  final String trail;
  final double size;
  final double? accentSize;
  final Color color;
  final double letterSpacing;
  final TextAlign textAlign;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppText.sans(size, weight: FontWeight.w700, letterSpacing: letterSpacing, height: height, color: color),
        children: [
          TextSpan(text: lead),
          TextSpan(
            text: accent,
            style: AppText.serif(accentSize ?? size + 4, italic: true, color: color, letterSpacing: letterSpacing),
          ),
          if (trail.isNotEmpty) TextSpan(text: trail),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Upper-case section label ("RECENT VISITS").
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.color = AppColors.slate,
    this.size = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  });

  final String text;
  final Color color;
  final double size;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: AppText.sans(size, weight: FontWeight.w800, letterSpacing: size < 13 ? 0.5 : 0.4, color: color),
      ),
    );
  }
}

/// The pale grey rounded card used for list rows and grouped content.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.radius = 22,
    this.color = AppColors.card,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}

/// A sticky bottom area that fades the scrolling content out behind it.
class BottomFadeBar extends StatelessWidget {
  const BottomFadeBar({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(18, 14, 18, 30)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: padding,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00FFFFFF), AppColors.white],
            stops: [0, 0.3],
          ),
        ),
        child: child,
      ),
    );
  }
}
