import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/icons/app_icons.dart';
import '../../core/models/place.dart';
import '../../core/models/place_category.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/drop_pin_panel.dart';
import 'widgets/here_panel.dart';
import 'widgets/place_result_card.dart';

enum AddMode { search, here, pin }

/// 09 · Add a place — search, "I'm here" (GPS) or drop a pin.
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key, this.initialMode = AddMode.search});

  final AddMode initialMode;

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  late AddMode _mode = widget.initialMode;
  final _query = TextEditingController();
  final _pinName = TextEditingController();
  String? _pickedId;
  PlaceCategory? _pinCategory;

  @override
  void dispose() {
    _query.dispose();
    _pinName.dispose();
    super.dispose();
  }

  bool get _ready => switch (_mode) {
    AddMode.pin => _pinName.text.trim().length > 1 && _pinCategory != null,
    _ => _pickedId != null,
  };

  void _continue() {
    final state = context.appRead;
    var placeId = _pickedId;
    if (_mode == AddMode.pin) {
      final template = Place(
        id: '',
        name: '',
        area: 'Agartala',
        address: 'Dropped pin, Agartala',
        category: _pinCategory!,
      );
      placeId = state.addCustomPlace(name: _pinName.text.trim(), template: template).id;
    }
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(context, Routes.review, arguments: placeId);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final q = _query.text.trim().toLowerCase();
    final results = MockData.addPlaceSearchIds
        .map(state.place)
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q) || p.address.toLowerCase().contains(q))
        .take(4)
        .toList();

    return SkyScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.blue, AppColors.blueLight, AppColors.blueSky, AppColors.blueMist],
        stops: [0, 0.40, 0.76, 1],
      ),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 34),
      scrollable: false,
      resizeToAvoidBottomInset: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add a place',
            textAlign: TextAlign.center,
            style: AppText.sans(24, weight: FontWeight.w700, letterSpacing: -0.4, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text('Pick the easiest way to log it', textAlign: TextAlign.center, style: AppText.headerSubtitle()),
          const SizedBox(height: 20),
          _ModeTabs(
            mode: _mode,
            onChanged: (m) => setState(() {
              _mode = m;
              _pickedId = null;
            }),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 18, bottom: 12),
              child: switch (_mode) {
                AddMode.search => Column(
                  spacing: 10,
                  children: [
                    SearchField(
                      controller: _query,
                      hint: 'Search cafés, treks, temples…',
                      onChanged: (_) => setState(() {}),
                    ),
                    PlaceResultCard(
                      title: q.isEmpty ? 'NEARBY' : 'RESULTS',
                      places: results,
                      pickedId: _pickedId,
                      onPick: (id) => setState(() => _pickedId = id),
                      emptyMessage: const _NoMatch(),
                    ),
                  ],
                ),
                AddMode.here => HerePanel(
                  candidates: [
                    for (final n in MockData.nearbyHere) (place: state.place(n.placeId), distance: n.distance),
                  ],
                  pickedId: _pickedId,
                  onPick: (id) => setState(() => _pickedId = id),
                ),
                AddMode.pin => DropPinPanel(
                  nameController: _pinName,
                  category: _pinCategory,
                  onNameChanged: () => setState(() {}),
                  onCategory: (c) => setState(() => _pinCategory = c),
                ),
              },
            ),
          ),
          if (_ready) ...[PrimaryButton(label: 'Continue to review', onPressed: _continue), const SizedBox(height: 14)],
          Center(
            child: Pressable(
              semanticLabel: 'Cancel',
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 1,
                  children: [
                    const AppIconView(AppIcon.close, size: 18, color: AppColors.ink),
                    Text('Cancel', style: AppText.sans(10, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});

  final AddMode mode;
  final ValueChanged<AddMode> onChanged;

  static const _labels = {AddMode.search: 'Search', AddMode.here: "I'm here", AddMode.pin: 'Drop a pin'};

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        for (final m in AddMode.values)
          PillButton(
            label: _labels[m]!,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            background: m == mode ? AppColors.white : Colors.transparent,
            foreground: m == mode ? AppColors.navy : AppColors.white,
            solidBorder: m == mode ? AppColors.white : null,
            dashedBorder: m == mode ? null : AppColors.whiteA(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            onPressed: () => onChanged(m),
            serif: true,
          ),
      ],
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text.rich(
        TextSpan(
          style: AppText.sans(14, weight: FontWeight.w400, color: AppColors.slate),
          children: const [
            TextSpan(text: 'No match. Try '),
            TextSpan(
              text: 'Drop a pin',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: ' for places without a listing.'),
          ],
        ),
      ),
    );
  }
}
