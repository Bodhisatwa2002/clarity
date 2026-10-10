import 'package:flutter/widgets.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import 'dashed_border.dart';
import 'pressable.dart';

/// How a disabled [PrimaryButton] looks, depending on what it sits on.
enum DisabledLook {
  /// Translucent black with white text — on blue gradients.
  onBlue,

  /// Flat grey with slate text — on white sheets.
  onWhite,
}

/// The black, full-width call to action ("Get started", "Post review").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 60,
    this.fontSize = 17,
    this.disabledLabel,
    this.disabledLook = DisabledLook.onBlue,
    this.shadow = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppIcon? icon;
  final double height;
  final double fontSize;

  /// Optional hint shown instead of [label] while disabled.
  final String? disabledLabel;
  final DisabledLook disabledLook;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final Color bg;
    final Color fg;
    if (enabled) {
      bg = AppColors.ink;
      fg = AppColors.white;
    } else if (disabledLook == DisabledLook.onBlue) {
      bg = AppColors.ink.withValues(alpha: 0.28);
      fg = AppColors.white;
    } else {
      bg = AppColors.disabled;
      fg = AppColors.slate;
    }
    final text = enabled ? label : (disabledLabel ?? label);
    final size = !enabled && disabledLabel != null ? 16.0 : fontSize;

    return Pressable(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: shadow && enabled ? AppShadows.button : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[AppIconView(icon!, size: 18, color: fg, strokeWidth: 2.4), const SizedBox(width: 8)],
            Flexible(
              child: Text(
                text,
                style: AppText.button(color: fg, size: size),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill with a dashed outline — secondary actions ("Not now", "Decline").
class DashedButton extends StatelessWidget {
  const DashedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.borderColor = AppColors.subtle,
    this.foreground = AppColors.text,
    this.background = AppColors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color borderColor;
  final Color foreground;
  final Color background;
  final EdgeInsets padding;
  final AppIcon? icon;

  /// Stretch to the available width instead of hugging the label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: DashedBorder(
        color: borderColor,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(height / 2)),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AppIconView(icon!, size: 16, color: foreground, strokeWidth: 2.4),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppText.sans(fontSize, weight: fontWeight, color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact solid or dashed pill used inside cards ("Add", "Accept", "Copy").
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 40,
    this.minWidth = 0,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w800,
    this.background = AppColors.ink,
    this.foreground = AppColors.white,
    this.dashedBorder,
    this.solidBorder,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
    this.leading,
    this.expand = false,
    this.serif = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double minWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final Color background;
  final Color foreground;

  /// Draw a dashed outline in this color.
  final Color? dashedBorder;

  /// Draw a solid 1.5pt outline in this color.
  final Color? solidBorder;
  final EdgeInsets padding;
  final Widget? leading;
  final bool expand;

  /// Set the label in Newsreader instead of Manrope.
  final bool serif;

  @override
  Widget build(BuildContext context) {
    final style = serif
        ? AppText.serif(fontSize, color: foreground)
        : AppText.sans(fontSize, weight: fontWeight, color: foreground);
    Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: height,
      constraints: BoxConstraints(minWidth: minWidth),
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(height / 2),
        border: solidBorder == null ? null : Border.all(color: solidBorder!, width: 1.5),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(label, style: style),
        ],
      ),
    );
    if (dashedBorder != null) pill = DashedBorder(color: dashedBorder!, child: pill);
    return Pressable(onTap: onPressed, child: pill);
  }
}

/// A borderless text action ("I already have an account", "Not now").
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.navy,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(
            label,
            style: AppText.sans(fontSize, weight: fontWeight, color: color),
          ),
        ),
      ),
    );
  }
}
