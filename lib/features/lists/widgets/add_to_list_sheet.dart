import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../badges/badge_moments.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/controls.dart';
import '../../shared/widgets/dashed_border.dart';
import '../../shared/widgets/pressable.dart';

/// "Add to a list" from a place: tick the lists it should be in, or start a
/// new list with it (which then opens).
Future<void> showAddToListSheet(BuildContext context, {required String placeId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => AddToListSheet(placeId: placeId),
  );
}

class AddToListSheet extends StatefulWidget {
  const AddToListSheet({super.key, required this.placeId});

  final String placeId;

  @override
  State<AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<AddToListSheet> {
  final _title = TextEditingController();
  late bool _creating = context.appRead.lists.isEmpty;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    final result = await context.appRead.createList(_title.text, placeId: widget.placeId);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    final navigator = Navigator.of(context);
    final state = context.appRead;
    navigator
      ..pop()
      ..pushNamed(Routes.collabList, arguments: result.listId);
    // Your first list unlocks List maker.
    Timer(const Duration(milliseconds: 450), () {
      if (navigator.mounted) BadgeMoments.celebrate(navigator, state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    final place = state.place(widget.placeId);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
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
              Text('Add to a list', style: AppText.sans(22, weight: FontWeight.w700, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(place.name, style: AppText.meta(size: 14)),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final l in state.lists)
                        _ListRow(
                          title: l.title,
                          subtitle: state.listSubtitle(l),
                          added: state.isInList(l.id, widget.placeId),
                          onTap: () => context.appRead.toggleInList(l.id, widget.placeId),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_creating) ...[
                DashedBorder(
                  color: AppColors.ink,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    child: BareTextField(
                      controller: _title,
                      hint: 'List name, e.g. Goa trip 2027',
                      autofocus: true,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) {
                        if (_title.text.trim().isNotEmpty && !_saving) _create();
                      },
                      style: AppText.sans(16, weight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: _saving ? 'Creating…' : 'Create list',
                  onPressed: _title.text.trim().isEmpty || _saving ? null : _create,
                ),
              ] else ...[
                DashedButton(
                  label: 'New list',
                  icon: AppIcon.plus,
                  expand: true,
                  onPressed: () => setState(() => _creating = true),
                ),
                const SizedBox(height: 10),
                PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.title, required this.subtitle, required this.added, required this.onTap});

  final String title;
  final String subtitle;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: added ? 'Remove from $title' : 'Add to $title',
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: added ? AppColors.selectedRow : null, borderRadius: BorderRadius.circular(16)),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(15, weight: FontWeight.w700),
                  ),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.meta()),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: added ? AppColors.blue : null,
                shape: BoxShape.circle,
                border: added ? null : Border.all(color: AppColors.fieldBorder, width: 1.5),
              ),
              alignment: Alignment.center,
              child: added
                  ? const AppIconView(AppIcon.check, size: 15, color: AppColors.white, strokeWidth: 2.6)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
