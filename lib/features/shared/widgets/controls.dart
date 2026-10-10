import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import 'pressable.dart';

/// Look of a [SegmentedTabs] track.
enum SegmentLook {
  /// Grey track, black selected segment (review status, share target).
  grey,

  /// White track inside a grey card (settings visibility).
  white,
}

/// Full-width segmented control with equal segments.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.look = SegmentLook.grey,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final SegmentLook look;

  @override
  Widget build(BuildContext context) {
    final grey = look == SegmentLook.grey;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: grey ? AppColors.segment : AppColors.white,
        borderRadius: BorderRadius.circular(grey ? 22 : 20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Pressable(
                onTap: () => onChanged(i),
                pressedOpacity: 0.8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(grey ? 18 : 16),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: AppText.sans(
                      13,
                      weight: FontWeight.w700,
                      height: 1.15,
                      color: i == selected ? AppColors.white : AppColors.slate,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One option in a [GlassTabs] control.
class GlassTab {
  const GlassTab(this.label, {this.icon});
  final String label;
  final AppIcon? icon;
}

/// The translucent, content-hugging toggle on blue headers
/// (Map / List, Friends / Requests).
class GlassTabs extends StatelessWidget {
  const GlassTabs({super.key, required this.tabs, required this.selected, required this.onChanged});

  final List<GlassTab> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.whiteA(0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.whiteA(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Pressable(
              onTap: () => onChanged(i),
              pressedOpacity: 0.8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: tabs[i].icon == null ? 18 : 20),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tabs[i].icon != null) ...[
                      AppIconView(tabs[i].icon!, size: 15, color: i == selected ? AppColors.navy : AppColors.white),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tabs[i].label,
                      style: AppText.sans(
                        14,
                        weight: FontWeight.w700,
                        color: i == selected ? AppColors.navy : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The black/grey iOS-style switch from the design.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged, this.semanticLabel});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: SizedBox(
          width: 56,
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 32,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? AppColors.ink : AppColors.disabled,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A borderless text input styled by its container — the design draws its
/// own pill fields around inputs.
class BareTextField extends StatelessWidget {
  const BareTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.style,
    this.hintStyle,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final TextStyle style;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      autofillHints: autofillHints,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: style,
      cursorColor: AppColors.blue,
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: hintStyle ?? style.copyWith(color: AppColors.subtle),
      ).copyWith(counterText: ''),
    );
  }
}

/// Visual variants of [SearchField].
enum SearchFieldLook {
  /// White pill with a soft shadow, on blue.
  raised,

  /// Grey pill on a white sheet.
  flat,
}

/// Pill-shaped search input with a leading magnifier.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.look = SearchFieldLook.raised,
    this.height = 56,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final SearchFieldLook look;
  final double height;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final raised = look == SearchFieldLook.raised;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: raised ? 18 : 16),
      decoration: BoxDecoration(
        color: raised ? AppColors.white : AppColors.segment,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: raised ? AppShadows.soft : null,
      ),
      child: Row(
        children: [
          AppIconView(AppIcon.search, size: raised ? 19 : 17, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: BareTextField(
              controller: controller,
              hint: hint,
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppText.sans(raised ? 16 : 15, weight: FontWeight.w600, color: AppColors.navyInk),
            ),
          ),
        ],
      ),
    );
  }
}
