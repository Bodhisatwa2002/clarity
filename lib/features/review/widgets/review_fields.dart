import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/models/place_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/glass.dart';
import '../../shared/widgets/pressable.dart';

/// Five tappable outline stars.
class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        for (var n = 1; n <= 5; n++)
          Pressable(
            semanticLabel: '$n star${n > 1 ? 's' : ''}',
            onTap: () => onChanged(n),
            pressedOpacity: 0.7,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="${n <= rating ? '#111111' : 'none'}" '
                  'stroke="#111111" stroke-width="1.4" stroke-linejoin="round">${AppIcon.star.body}</svg>',
                  width: 36,
                  height: 36,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "One thing to know *      0/90".
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label, this.counter, this.required = false});

  final String label;
  final String? counter;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            style: AppText.sans(14, weight: FontWeight.w800),
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: AppText.sans(14, weight: FontWeight.w800, color: AppColors.warning),
                ),
            ],
          ),
        ),
        if (counter != null)
          Text(
            counter!,
            style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
          ),
      ],
    );
  }
}

/// The required one-line tip, highlighted in blue.
class TipField extends StatelessWidget {
  const TipField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.blueLight,
      radius: 18,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.centerLeft,
        child: BareTextField(
          controller: controller,
          hint: 'The one tip a friend needs, e.g. go before 4pm',
          maxLength: 90,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged(),
          style: AppText.sans(15, weight: FontWeight.w600, color: AppColors.navyInk),
        ),
      ),
    );
  }
}

/// Multi-line review text set in the serif.
class ReviewTextArea extends StatelessWidget {
  const ReviewTextArea({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: BareTextField(
        controller: controller,
        hint: 'What was it like? Keep it short and honest.',
        maxLength: 280,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => onChanged(),
        style: AppText.serif(17, height: 1.4, color: AppColors.navyInk),
      ),
    );
  }
}

/// Photo thumbnails with remove buttons and a dashed "Add" tile.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.count, required this.max, required this.onAdd, required this.onRemove});

  final int count;
  final int max;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < count; i++)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(gradient: AppGradients.photo, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: const AppIconView(AppIcon.image, size: 20, color: AppColors.photoIcon, strokeWidth: 1.8),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: Pressable(
                  semanticLabel: 'Remove photo ${i + 1}',
                  onTap: onRemove,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const AppIconView(AppIcon.close, size: 10, color: AppColors.white, strokeWidth: 3),
                  ),
                ),
              ),
            ],
          ),
        if (count < max)
          Pressable(
            onTap: onAdd,
            child: DashedBorder(
              color: AppColors.subtle,
              radius: 16,
              child: SizedBox(
                width: 76,
                height: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    const AppIconView(AppIcon.plus, size: 18, color: AppColors.slate, strokeWidth: 2.2),
                    Text(
                      'Add',
                      style: AppText.sans(11, weight: FontWeight.w700, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A bordered "LABEL / value" button (date visited, category).
class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final Widget value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Text(
              label,
              style: AppText.sans(11, weight: FontWeight.w700, color: AppColors.muted),
            ),
            DefaultTextStyle(
              style: AppText.sans(15, weight: FontWeight.w700),
              child: value,
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable person chip with a mini avatar ("RS Rahul").
class CompanionChip extends StatelessWidget {
  const CompanionChip({
    super.key,
    required this.label,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 40,
      padding: const EdgeInsets.only(left: 6, right: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: selected ? Border.all(color: AppColors.ink, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppText.sans(11, weight: FontWeight.w800, color: avatarFg),
            ),
          ),
          Text(
            label,
            style: AppText.sans(13, weight: FontWeight.w700, color: selected ? AppColors.white : AppColors.text),
          ),
        ],
      ),
    );
    return Pressable(
      onTap: onTap,
      child: selected ? chip : DashedBorder(color: AppColors.subtle, child: chip),
    );
  }
}

/// On/off dashed chip — black when selected.
class ToggleTag extends StatelessWidget {
  const ToggleTag({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.serif = false,
    this.height = 38,
    this.minWidth = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool serif;
  final double height;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.text;
    return Pressable(
      onTap: onTap,
      child: DashedBorder(
        color: selected ? AppColors.ink : AppColors.subtle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: height,
          constraints: BoxConstraints(minWidth: minWidth),
          padding: EdgeInsets.symmetric(horizontal: serif ? 14 : 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.white,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: serif ? AppText.serif(16, color: fg) : AppText.sans(14, weight: FontWeight.w700, color: fg),
          ),
        ),
      ),
    );
  }
}

/// "₹ [350] per person" with the ₹–₹₹₹₹ level worked out as you type.
class BudgetField extends StatelessWidget {
  const BudgetField({super.key, required this.controller, required this.level, required this.onChanged});

  final TextEditingController controller;

  /// "₹₹", or null while empty.
  final String? level;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final style = AppText.sans(17, weight: FontWeight.w700, color: AppColors.navyInk);
    return Container(
      height: 54,
      padding: const EdgeInsets.only(left: 18, right: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Text('₹', style: style),
          const SizedBox(width: 6),
          Expanded(
            child: BareTextField(
              controller: controller,
              hint: '350',
              keyboardType: TextInputType.number,
              maxLength: 7,
              onChanged: (value) {
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits != value) {
                  controller.value = TextEditingValue(
                    text: digits,
                    selection: TextSelection.collapsed(offset: digits.length),
                  );
                }
                onChanged();
              },
              style: style,
            ),
          ),
          Text('per person', style: AppText.meta(size: 13)),
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: level == null ? 0 : 1,
            child: Container(
              height: 38,
              constraints: const BoxConstraints(minWidth: 56),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.tintStrong, borderRadius: BorderRadius.circular(19)),
              child: Text(
                level ?? '',
                style: AppText.sans(14, weight: FontWeight.w800, color: AppColors.navy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed "+ Add your own" chip that turns into a one-line field.
/// Submitting adds the tag and goes back to the chip.
class CustomTagInput extends StatefulWidget {
  const CustomTagInput({super.key, required this.onAdd, required this.maxLength, this.enabled = true});

  final ValueChanged<String> onAdd;
  final int maxLength;

  /// False once the visit has the maximum number of tags.
  final bool enabled;

  @override
  State<CustomTagInput> createState() => _CustomTagInputState();
}

class _CustomTagInputState extends State<CustomTagInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _submit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final tag = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (tag.isNotEmpty) widget.onAdd(tag);
    _controller.clear();
    if (mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return Opacity(
        opacity: widget.enabled ? 1 : 0.4,
        child: ToggleTag(
          label: '+ Add your own',
          selected: false,
          onTap: widget.enabled
              ? () {
                  setState(() => _editing = true);
                  _focus.requestFocus();
                }
              : () {},
        ),
      );
    }
    return DashedBorder(
      color: AppColors.ink,
      child: Container(
        height: 38,
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(19)),
        alignment: Alignment.centerLeft,
        child: BareTextField(
          controller: _controller,
          focusNode: _focus,
          hint: 'e.g. Peacocks on the lawn',
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _focus.unfocus(),
          style: AppText.serif(16, color: AppColors.text),
        ),
      ),
    );
  }
}

/// Bottom sheet listing categories.
class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({super.key, required this.selected});

  final PlaceCategory selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Category', style: AppText.sans(22, weight: FontWeight.w700, letterSpacing: -0.4)),
            const SizedBox(height: 8),
            // Scrolls on short screens instead of overflowing.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in PlaceCategory.values)
                      Pressable(
                        onTap: () => Navigator.pop(context, c),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: c == selected ? AppColors.selectedRow : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Dot(color: c.color, size: 10),
                              Expanded(
                                child: Text(c.label, style: AppText.sans(15, weight: FontWeight.w600)),
                              ),
                              if (c == selected)
                                const AppIconView(AppIcon.check, size: 18, color: AppColors.blue, strokeWidth: 2.4),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
