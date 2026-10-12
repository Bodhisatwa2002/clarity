import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/layout.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/pressable.dart';

/// 02 · Welcome — three swipeable value-prop slides.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i.clamp(0, _slides.length - 1));

  void _start({required bool existing}) {
    final state = context.appRead;
    existing ? state.signInExisting() : state.startNewAccount();
    Navigator.pushNamed(context, Routes.phone);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200) _go(_index + 1);
            if (v > 200) _go(_index - 1);
          },
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    SizedBox(height: Layout.y(context, 124)),
                    _Brand(),
                    const SizedBox(height: 26),
                    _Headlines(index: _index),
                    const SizedBox(height: 52),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _ChipRows(key: ValueKey('rows$_index'), rows: slide.rows),
                    ),
                    const SizedBox(height: 28),
                    _Dots(count: _slides.length, index: _index, onTap: _go),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          PrimaryButton(label: 'Get started', onPressed: () => _start(existing: false)),
                          TextLinkButton(
                            label: 'I already have an account',
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            onPressed: () => _start(existing: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        const AppIconView(AppIcon.pin, size: 16, color: AppColors.blue),
        Text(
          'CLARITY',
          style: AppText.sans(13, weight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.blue),
        ),
      ],
    );
  }
}

/// All three headlines laid out on top of each other, so the block is always as
/// tall as the tallest one ("from your contacts." wraps to two lines) and the
/// chips, dots and buttons below stay put when the slide changes.
class _Headlines extends StatelessWidget {
  const _Headlines({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        for (var i = 0; i < _slides.length; i++)
          IgnorePointer(
            ignoring: i != index,
            child: ExcludeSemantics(
              excluding: i != index,
              child: AnimatedOpacity(
                opacity: i == index ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: _Headline(slide: _slides[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final bold = AppText.sans(46, weight: FontWeight.w700, letterSpacing: -1.8, height: 0.98);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(slide.line1, textAlign: TextAlign.center, style: bold),
          Text(
            slide.line2,
            textAlign: TextAlign.center,
            style: AppText.serif(52, italic: true, letterSpacing: -1, height: 0.98),
          ),
          Text(slide.line3, textAlign: TextAlign.center, style: bold),
          const SizedBox(height: 22),
          Text(
            slide.sub,
            textAlign: TextAlign.center,
            style: AppText.sans(15, color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _ChipRows extends StatelessWidget {
  const _ChipRows({super.key, required this.rows});

  final List<_ChipRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        for (final row in rows)
          ClipRect(
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Transform.translate(
                  offset: Offset(row.offset, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [for (final chip in row.chips) _WelcomeChip(chip)],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WelcomeChip extends StatelessWidget {
  const _WelcomeChip(this.chip);

  final _Chip chip;

  @override
  Widget build(BuildContext context) {
    if (chip.icon != null) {
      return DashedBorder(
        color: const Color(0xFF8A8F98),
        shape: BoxShape.circle,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(child: AppIconView(chip.icon!, size: 22, color: chip.iconColor, strokeWidth: 1.8)),
        ),
      );
    }
    return DashedBorder(
      color: chip.filled ? AppColors.blueLight : const Color(0xFF8A8F98),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: chip.filled ? AppColors.tintStrong : null,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(chip.label!, style: AppText.serif(18, color: chip.filled ? AppColors.navy : AppColors.text)),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.onTap});

  final int count;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        for (var i = 0; i < count; i++)
          Pressable(
            onTap: () => onTap(i),
            semanticLabel: 'Show slide ${i + 1} of $count',
            child: SizedBox(
              width: 28,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.ink : const Color(0xFFB8BCC4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Slide content ─────────────────────────────────────────────────────────

class _Slide {
  const _Slide(this.line1, this.line2, this.line3, this.sub, this.rows);
  final String line1;
  final String line2;
  final String line3;
  final String sub;
  final List<_ChipRow> rows;
}

class _ChipRow {
  const _ChipRow(this.offset, this.chips);
  final double offset;
  final List<_Chip> chips;
}

class _Chip {
  const _Chip.text(String this.label, {this.filled = false}) : icon = null, iconColor = AppColors.blue;
  const _Chip.icon(AppIcon this.icon, this.iconColor) : label = null, filled = false;

  final String? label;
  final bool filled;
  final AppIcon? icon;
  final Color iconColor;
}

const _cup = _Chip.icon(AppIcon.cup, AppColors.blue);
const _peak = _Chip.icon(AppIcon.peak, Color(0xFF1F8A6A));
const _pin = _Chip.icon(AppIcon.pin, AppColors.warning);
const _user = _Chip.icon(AppIcon.user, AppColors.blue);

const _slides = [
  _Slide("Your friends'", 'honest opinions,', 'on a map.', 'No strangers. Only people you trust.', [
    _ChipRow(-46, [_Chip.text('Cafés', filled: true), _cup, _Chip.text('Hidden dhabas'), _Chip.text('Treks')]),
    _ChipRow(14, [_Chip.text('Viewpoints'), _peak, _Chip.text('Temples', filled: true), _Chip.text('Stays')]),
    _ChipRow(-70, [_Chip.text('Beaches', filled: true), _pin, _Chip.text('Roadside chai'), _Chip.text('Shops')]),
  ]),
  _Slide('Every place', "you've been,", 'in one link.', 'Your map becomes the answer to "where should I go?"', [
    _ChipRow(-30, [_Chip.text('clarity.in/you', filled: true), _pin, _Chip.text('Share to WhatsApp')]),
    _ChipRow(10, [_Chip.text('5/5 · go before 7am'), _peak, _Chip.text('Worth it', filled: true)]),
    _ChipRow(-60, [_Chip.text('Goa trip 2027', filled: true), _cup, _Chip.text('Want to go'), _Chip.text('Visited')]),
  ]),
  _Slide("See who's", 'already here', 'from your contacts.', 'Sync contacts, open their maps, trust their picks.', [
    _ChipRow(-40, [_Chip.text('12 friends are here', filled: true), _user, _Chip.text('Invite Rahul')]),
    _ChipRow(18, [_Chip.text('Who’s been here?'), _pin, _Chip.text('Friend rating 4.6', filled: true)]),
    _ChipRow(-66, [_Chip.text('Asha visited Neermahal'), _peak, _Chip.text('Save to list', filled: true)]),
  ]),
];
