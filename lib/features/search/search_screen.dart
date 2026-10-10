import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/person.dart';
import '../../core/models/place.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/avatar.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/chips.dart';
import '../shared/widgets/content.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';

enum _Scope { all, people, places }

/// 16 · Search people, places, or ask friends' reviews in plain words.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  _Scope _scope = _Scope.all;

  /// Extra words that make "ask anything" queries find the right places.
  static const _keywords = {
    'neermahal': 'palace lake viewpoint sunset melaghar',
    'dzukou': 'dzukou valley trek nagaland',
    'lakeside-cafe': 'cafe café quiet coffee reading agartala work',
    'momo': 'momo food agartala cheap',
    'ward-lake': 'ward lake shillong viewpoint',
    'ujjayanta': 'palace museum agartala',
  };

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _set(String q) {
    _query.text = q;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final q = _query.text.trim().toLowerCase();
    final words = q.split(RegExp(r'\s+')).where((w) => w.length > 2);
    bool hit(String haystack) => haystack.contains(q) || words.any(haystack.contains);

    final people = q.isEmpty
        ? <Person>[]
        : [...state.friends, MockData.rahulDey].where((p) => hit(p.name.toLowerCase())).toList();
    final places = q.isEmpty
        ? <Place>[]
        : _keywords.keys.map(state.place).where((p) => hit('${p.name.toLowerCase()} ${_keywords[p.id]}')).toList();
    final showPeople = _scope != _Scope.places && people.isNotEmpty;
    final showPlaces = _scope != _Scope.people && places.isNotEmpty;

    return SheetScaffold(
      sheetTop: 182,
      resizeToAvoidBottomInset: true,
      headerPadding: const EdgeInsets.symmetric(horizontal: 16),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: SearchField(
                  controller: _query,
                  hint: 'People, places, or ask anything',
                  height: 52,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              TextLinkButton(
                label: 'Cancel',
                color: AppColors.white,
                height: 44,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 8,
            children: [
              for (final s in _Scope.values)
                PillButton(
                  label: switch (s) {
                    _Scope.all => 'All',
                    _Scope.people => 'People',
                    _Scope.places => 'Places',
                  },
                  height: 38,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  background: s == _scope ? AppColors.white : Colors.transparent,
                  foreground: s == _scope ? AppColors.navy : AppColors.white,
                  solidBorder: s == _scope ? AppColors.white : null,
                  dashedBorder: s == _scope ? null : AppColors.white,
                  onPressed: () => setState(() => _scope = s),
                ),
            ],
          ),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (q.isEmpty) ..._suggestions(),
          if (showPeople) ...[
            const SectionLabel('PEOPLE'),
            const SizedBox(height: 6),
            for (final p in people) ...[_PersonResult(person: p), const SizedBox(height: 6)],
            const SizedBox(height: 12),
          ],
          if (showPlaces) ...[
            const SectionLabel('PLACES'),
            const SizedBox(height: 6),
            for (final p in places) ...[_PlaceResult(place: p), const SizedBox(height: 6)],
          ],
          if (q.isNotEmpty && !showPeople && !showPlaces)
            const DashedMessageCard(
              title: 'None of your friends have been here',
              message: 'Be the first. Add it after your visit.',
            ),
        ],
      ),
    );
  }

  List<Widget> _suggestions() => [
    const SectionLabel('RECENT'),
    const SizedBox(height: 12),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in MockData.recentSearches)
          TagChip(label: r, serif: true, height: 40, fontSize: 13, onTap: () => _set(r)),
      ],
    ),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppGradients.askCard, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              const AppIconView(AppIcon.sparkle, size: 16, color: AppColors.blue),
              Text(
                "Ask your friends' reviews",
                style: AppText.sans(13, weight: FontWeight.w800, color: AppColors.navy),
              ),
            ],
          ),
          for (final a in MockData.askSuggestions)
            Pressable(
              onTap: () => _set(a),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.centerLeft,
                child: Text('“$a”', style: AppText.serif(16, italic: true, color: AppColors.navy)),
              ),
            ),
        ],
      ),
    ),
  ];
}

class _PersonResult extends StatelessWidget {
  const _PersonResult({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final meta = state.isFriend(person.id)
        ? '${person.handle} · Friend · ${person.placesCount} places'
        : '${person.handle} · ${person.note ?? ''}';
    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.friend, arguments: person.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: Row(
          spacing: 12,
          children: [
            InitialsAvatar.person(person, size: 42, fontSize: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(person.name, style: AppText.sans(15, weight: FontWeight.w700)),
                  Text(meta, style: AppText.meta()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceResult extends StatelessWidget {
  const _PlaceResult({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final friends = state.friendVisitsFor(place.id);
    final mine = state.myVisitFor(place.id);
    final rating = state.friendsRating(place.id) ?? mine?.rating;
    final who = switch ((mine != null, friends.length)) {
      (true, 0) => 'you visited',
      (true, 1) => 'you and ${state.person(friends.first.authorId).firstName}',
      (true, final n) when n >= 3 => '$n friends · you visited',
      (true, final n) => 'you and $n friends',
      (false, 0) => 'no friends yet',
      (false, 1) => '${state.person(friends.first.authorId).firstName} visited · ${place.area}',
      (false, final n) => '$n friends · ${place.area}',
    };

    return Pressable(
      onTap: () => Navigator.pushNamed(context, Routes.place, arguments: place.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: AppIconView(AppIcon.pin, size: 18, color: place.category.color),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(place.name, style: AppText.serif(18)),
                  Text(
                    '${place.category.label} · $who',
                    style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(rating == null ? '–' : Fmt.rating(rating), style: AppText.sans(14, weight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
