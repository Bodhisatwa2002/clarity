import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place_category.dart';
import '../../core/models/visit.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../badges/badge_moments.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'widgets/review_fields.dart';

/// Arguments for [Routes.review].
class ReviewArgs {
  const ReviewArgs(this.placeId, {this.editing = false});

  final String placeId;

  /// True when opened from the place screen: posting just closes the form.
  final bool editing;
}

/// 11 · Write / edit review — only for places you've been. "Want to go" is a
/// save on the place screen, not a review.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, required this.args});

  final ReviewArgs args;

  static const ratingWords = ['Tap to rate', 'Not for me', 'It was okay', 'Good', 'Really good', 'Loved it'];
  static const quickTags = [
    'Worth it',
    'Skip it',
    'Best at sunset',
    'Go early',
    'Good for groups',
    'Solo-friendly',
    'Bike parking',
    'Washroom',
  ];
  static const maxPhotos = 5;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _tip = TextEditingController();
  final _text = TextEditingController();
  final _budget = TextEditingController();
  bool _recommended = true;
  int _rating = 0;
  int _photos = 2;
  DateTime _date = DateTime.now();
  late PlaceCategory _category;
  final Set<String> _with = {};
  final Set<String> _tags = {};

  @override
  void initState() {
    super.initState();
    final state = context.appRead;
    final place = state.place(widget.args.placeId);
    _category = place.category;
    final existing = state.myVisitFor(place.id);
    if (existing != null) {
      _recommended = existing.recommended;
      _rating = existing.rating.round();
      _tip.text = existing.tip;
      _text.text = existing.text;
      _photos = existing.photoCount;
      _date = existing.date;
      _with.addAll(existing.companions.where((c) => c != 'family'));
      _tags.addAll(existing.tags);
      _budget.text = existing.budgetPerPerson?.toString() ?? '';
    } else {
      final firstFriend = state.friends.firstOrNull;
      _with.add(firstFriend?.firstName ?? 'solo');
    }
  }

  @override
  void dispose() {
    _tip.dispose();
    _text.dispose();
    _budget.dispose();
    super.dispose();
  }

  bool get _ready => _rating > 0 && _tip.text.trim().length > 3;

  void _post() {
    final state = context.appRead;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final before = BadgeMoments.snapshot(state);
    state.saveVisit(
      Visit(
        id: state.myVisitFor(widget.args.placeId)?.id ?? state.newVisitId(widget.args.placeId),
        placeId: widget.args.placeId,
        authorId: state.me.id,
        date: _date,
        recommended: _recommended,
        rating: _rating.toDouble(),
        tip: _tip.text.trim(),
        text: _text.text.trim(),
        companions: _with.toList(),
        tags: _tags.toList(),
        budgetPerPerson: int.tryParse(_budget.text),
        photoCount: _photos,
      ),
    );
    if (widget.args.editing) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(Routes.place, arguments: widget.args.placeId);
    }
    BadgeMoments.afterReview(
      navigator: navigator,
      messenger: messenger,
      state: state,
      before: before,
      placeId: widget.args.placeId,
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (!_tags.remove(tag) && _tags.length < Visit.maxTags) _tags.add(tag);
    });
  }

  /// Adds a custom tag, matching a built-in one if it's the same words.
  void _addTag(String tag) {
    final builtIn = WriteReviewScreen.quickTags.where((t) => t.toLowerCase() == tag.toLowerCase()).firstOrNull;
    final exists = _tags.any((t) => t.toLowerCase() == tag.toLowerCase());
    if (exists || _tags.length >= Visit.maxTags) return;
    setState(() => _tags.add(builtIn ?? tag));
  }

  Future<void> _pickDate() async {
    var picked = _date;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppColors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: Text(
                    'Done',
                    style: AppText.sans(16, weight: FontWeight.w700, color: AppColors.blue),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _date,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (d) => picked = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    setState(() => _date = picked);
  }

  Future<void> _pickCategory() async {
    final picked = await showModalBottomSheet<PlaceCategory>(
      context: context,
      // The list is taller than the default 9/16-of-the-screen cap.
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => CategoryPickerSheet(selected: _category),
    );
    if (picked != null) setState(() => _category = picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final place = state.place(widget.args.placeId);
    final people = [
      for (final f in state.friends.take(3))
        (id: f.firstName, label: f.firstName, initials: f.initials, bg: f.avatarBg, fg: f.avatarFg),
      (id: 'solo', label: 'Solo', initials: '1', bg: const Color(0xFFEEF0F4), fg: AppColors.slate),
    ];

    return SheetScaffold(
      sheetTop: 136,
      resizeToAvoidBottomInset: true,
      header: HeaderBar(
        leading: GlassIconButton(
          icon: AppIcon.close,
          iconSize: 18,
          semanticLabel: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'YOUR REVIEW',
              style: AppText.sans(12, weight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.onBlueSoft),
            ),
            Text(
              place.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.serif(24, height: 1.2, color: AppColors.white),
            ),
          ],
        ),
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 120),
        // The number pad has no Done key; scrolling puts it away.
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          StarPicker(rating: _rating, onChanged: (r) => setState(() => _rating = r)),
          const SizedBox(height: 6),
          Text(
            WriteReviewScreen.ratingWords[_rating],
            textAlign: TextAlign.center,
            style: AppText.serif(18, italic: true, color: AppColors.slate),
          ),
          const SizedBox(height: 22),
          const FieldLabel(label: 'Would you recommend it?'),
          const SizedBox(height: 8),
          SegmentedTabs(
            labels: const ['Yes', 'No'],
            selected: _recommended ? 0 : 1,
            onChanged: (i) => setState(() => _recommended = i == 0),
          ),
          const SizedBox(height: 22),
          FieldLabel(label: 'One thing to know', required: true, counter: '${_tip.text.length}/90'),
          const SizedBox(height: 8),
          TipField(controller: _tip, onChanged: () => setState(() {})),
          const SizedBox(height: 22),
          FieldLabel(label: 'Your review', counter: '${_text.text.length}/280'),
          const SizedBox(height: 8),
          ReviewTextArea(controller: _text, onChanged: () => setState(() {})),
          const SizedBox(height: 22),
          FieldLabel(label: 'Photos', counter: '$_photos/${WriteReviewScreen.maxPhotos}'),
          const SizedBox(height: 8),
          PhotoStrip(
            count: _photos,
            max: WriteReviewScreen.maxPhotos,
            onAdd: () => setState(() => _photos++),
            onRemove: () => setState(() => _photos--),
          ),
          const SizedBox(height: 22),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: InfoTile(label: 'DATE VISITED', value: Text(Fmt.dayMonthYear(_date)), onTap: _pickDate),
              ),
              Expanded(
                child: InfoTile(
                  label: 'CATEGORY',
                  value: Row(
                    spacing: 6,
                    children: [
                      Dot(color: _category.color),
                      Text(_category.label),
                    ],
                  ),
                  onTap: _pickCategory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const FieldLabel(label: 'Who you went with'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in people)
                CompanionChip(
                  label: p.label,
                  initials: p.initials,
                  avatarBg: p.bg,
                  avatarFg: p.fg,
                  selected: _with.contains(p.id),
                  onTap: () => setState(() => _with.contains(p.id) ? _with.remove(p.id) : _with.add(p.id)),
                ),
            ],
          ),
          const SizedBox(height: 22),
          FieldLabel(label: 'Quick tags', counter: '${_tags.length}/${Visit.maxTags}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in [
                ...WriteReviewScreen.quickTags,
                ..._tags.where((t) => !WriteReviewScreen.quickTags.contains(t)),
              ])
                ToggleTag(label: t, serif: true, selected: _tags.contains(t), onTap: () => _toggleTag(t)),
              CustomTagInput(maxLength: Visit.maxTagLength, enabled: _tags.length < Visit.maxTags, onAdd: _addTag),
            ],
          ),
          const SizedBox(height: 22),
          const FieldLabel(label: 'Budget per person'),
          const SizedBox(height: 8),
          BudgetField(
            controller: _budget,
            level: Visit.budgetLevelFor(int.tryParse(_budget.text)),
            onChanged: () => setState(() {}),
          ),
        ],
      ),
      sheetOverlays: [
        BottomFadeBar(
          child: PrimaryButton(
            label: 'Post review',
            disabledLabel: 'Add a rating and one tip to post',
            disabledLook: DisabledLook.onWhite,
            onPressed: _ready ? _post : null,
          ),
        ),
      ],
    );
  }
}
