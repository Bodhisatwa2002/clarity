import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place_category.dart';
import '../../core/models/visit.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
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

/// 11 · Write / edit review.
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
  static const budgets = ['₹', '₹₹', '₹₹₹', '₹₹₹₹'];
  static const maxPhotos = 5;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _tip = TextEditingController();
  final _text = TextEditingController();
  VisitStatus _status = VisitStatus.visited;
  int _rating = 0;
  int _photos = 2;
  DateTime _date = DateTime.now();
  late PlaceCategory _category;
  final Set<String> _with = {};
  final Set<String> _tags = {};
  String? _budget = '₹₹';

  @override
  void initState() {
    super.initState();
    final state = context.appRead;
    final place = state.place(widget.args.placeId);
    _category = place.category;
    final existing = state.myVisitFor(place.id);
    if (existing != null) {
      _status = existing.status;
      _rating = existing.rating.round();
      _tip.text = existing.tip;
      _text.text = existing.text;
      _photos = existing.photoCount;
      _date = existing.date;
      _with.addAll(existing.companions.where((c) => c != 'family'));
      _tags.addAll(existing.tags);
      _budget = existing.budget;
    } else {
      final firstFriend = state.friends.firstOrNull;
      _with.add(firstFriend?.firstName ?? 'solo');
    }
  }

  @override
  void dispose() {
    _tip.dispose();
    _text.dispose();
    super.dispose();
  }

  bool get _ready => _rating > 0 && _tip.text.trim().length > 3;

  void _post() {
    final state = context.appRead;
    state.saveVisit(
      Visit(
        id: 'v-${widget.args.placeId}',
        placeId: widget.args.placeId,
        authorId: MockData.meId,
        date: _date,
        status: _status,
        rating: _rating.toDouble(),
        tip: _tip.text.trim(),
        text: _text.text.trim(),
        companions: _with.toList(),
        tags: _tags.toList(),
        budget: _budget,
        photoCount: _photos,
      ),
    );
    if (widget.args.editing) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, Routes.place, arguments: widget.args.placeId);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review posted to your map')));
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
        children: [
          SegmentedTabs(
            labels: [for (final s in VisitStatus.values) s.label],
            selected: _status.index,
            onChanged: (i) => setState(() => _status = VisitStatus.values[i]),
          ),
          const SizedBox(height: 22),
          StarPicker(rating: _rating, onChanged: (r) => setState(() => _rating = r)),
          const SizedBox(height: 6),
          Text(
            WriteReviewScreen.ratingWords[_rating],
            textAlign: TextAlign.center,
            style: AppText.serif(18, italic: true, color: AppColors.slate),
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
          const FieldLabel(label: 'Quick tags'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in WriteReviewScreen.quickTags)
                ToggleTag(
                  label: t,
                  serif: true,
                  selected: _tags.contains(t),
                  onTap: () => setState(() => _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'BUDGET',
            style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 8,
            children: [
              for (final b in WriteReviewScreen.budgets)
                ToggleTag(
                  label: b,
                  height: 40,
                  minWidth: 56,
                  selected: _budget == b,
                  onTap: () => setState(() => _budget = _budget == b ? null : b),
                ),
            ],
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
