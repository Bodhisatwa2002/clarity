import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import '../system/design_states_sheet.dart';

enum _Visibility { public, contacts, private }

/// 20 · Settings — account, privacy, notifications and your data.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _Visibility _visibility = _Visibility.contacts;
  final Map<String, bool> _toggles = {
    'findMe': true,
    'sync': true,
    'joins': true,
    'requests': true,
    'reactions': true,
    'nudges': false,
  };
  bool _confirmingDelete = false;

  static const _visibilityHints = {
    _Visibility.public: 'Anyone with your link can see your map and reviews.',
    _Visibility.contacts: 'Only friends and people in your contacts who are on Clarity.',
    _Visibility.private: 'Only you. Friends see nothing until you change this.',
  };

  void _flip(String key) => setState(() => _toggles[key] = !_toggles[key]!);

  void _signOut() => Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (_) => false);

  void _comingSoon(String what) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what comes with the backend.')));

  @override
  Widget build(BuildContext context) {
    final state = context.app;
    return SheetScaffold(
      sheetTop: 132,
      header: Row(
        spacing: 14,
        children: [
          GlassIconButton(
            icon: AppIcon.back,
            iconSize: 20,
            semanticLabel: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          Text('Settings', style: AppText.screenTitle()),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _Section(
            title: 'ACCOUNT',
            child: _Group(
              children: [
                _LinkRow(label: 'Name', value: state.name, onTap: () => _comingSoon('Editing your name')),
                _LinkRow(label: 'Username', value: '@${state.username}', onTap: () => _comingSoon('Changing username')),
                _LinkRow(
                  label: 'Phone',
                  value: state.phoneDisplay,
                  onTap: () => _comingSoon('Changing number'),
                  last: true,
                ),
              ],
            ),
          ),
          _Section(
            title: 'PRIVACY',
            child: _Group(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text('Who can see my map', style: AppText.sans(15, weight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                SegmentedTabs(
                  labels: const ['Public', 'Contacts only', 'Private'],
                  selected: _visibility.index,
                  look: SegmentLook.white,
                  onChanged: (i) => setState(() => _visibility = _Visibility.values[i]),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    _visibilityHints[_visibility]!,
                    style: AppText.sans(12, weight: FontWeight.w400, height: 1.45, color: AppColors.slate),
                  ),
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  label: 'Let people find me by number',
                  subtitle: 'People who have your number can see you are here',
                  value: _toggles['findMe']!,
                  onChanged: () => _flip('findMe'),
                  divider: _DividerAt.top,
                ),
                _SwitchRow(
                  label: 'Contact sync',
                  subtitle: 'Match new contacts automatically',
                  value: _toggles['sync']!,
                  onChanged: () => _flip('sync'),
                  divider: _DividerAt.top,
                ),
                _HiddenPinsRow(onTap: () => _comingSoon('Hidden pins')),
              ],
            ),
          ),
          _Section(
            title: 'NOTIFICATIONS',
            child: _Group(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _SwitchRow(
                  label: 'A contact joins Clarity',
                  value: _toggles['joins']!,
                  onChanged: () => _flip('joins'),
                ),
                _SwitchRow(label: 'Friend requests', value: _toggles['requests']!, onChanged: () => _flip('requests')),
                _SwitchRow(
                  label: 'Reactions to my reviews',
                  value: _toggles['reactions']!,
                  onChanged: () => _flip('reactions'),
                ),
                _SwitchRow(
                  label: 'Rate it while it’s fresh',
                  value: _toggles['nudges']!,
                  onChanged: () => _flip('nudges'),
                ),
              ],
            ),
          ),
          _Section(
            title: 'YOUR DATA',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                _Group(
                  children: [
                    _LinkRow(label: 'Download my data', onTap: () => _comingSoon('Data export'), chevron: false),
                    _LinkRow(
                      label: 'Privacy policy',
                      onTap: () => _comingSoon('The privacy policy page'),
                      chevron: false,
                    ),
                    _LinkRow(label: 'Log out', onTap: _signOut, chevron: false),
                    _LinkRow(
                      label: 'Delete account',
                      danger: true,
                      chevron: false,
                      last: true,
                      onTap: () => setState(() => _confirmingDelete = true),
                    ),
                  ],
                ),
                if (_confirmingDelete)
                  _DeleteConfirm(onCancel: () => setState(() => _confirmingDelete = false), onDelete: _signOut),
                GestureDetector(
                  onLongPress: () => showDesignStatesSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                    child: Text(
                      'Clarity · version 1.0',
                      textAlign: TextAlign.center,
                      style: AppText.sans(12, weight: FontWeight.w400, color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title,
              style: AppText.sans(12, weight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.slate),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.onTap,
    this.value,
    this.chevron = true,
    this.danger = false,
    this.last = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool chevron;
  final bool danger;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.sans(
                  15,
                  weight: danger ? FontWeight.w700 : FontWeight.w600,
                  color: danger ? AppColors.danger : AppColors.ink,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.muted),
              ),
            if (chevron) const AppIconView(AppIcon.chevronRight, size: 16, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

enum _DividerAt { top, bottom }

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.divider = _DividerAt.bottom,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final VoidCallback onChanged;
  final _DividerAt divider;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.line);
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: divider == _DividerAt.top ? const Border(top: side) : const Border(bottom: side),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(label, style: AppText.sans(15, weight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.sans(12, weight: FontWeight.w400, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          AppSwitch(value: value, semanticLabel: label, onChanged: (_) => onChanged()),
        ],
      ),
    );
  }
}

class _HiddenPinsRow extends StatelessWidget {
  const _HiddenPinsRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text('Hidden pins', style: AppText.sans(15, weight: FontWeight.w600)),
                  Text(
                    'Home, workplace. Only you see these.',
                    style: AppText.sans(12, weight: FontWeight.w400, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(
              '2',
              style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.muted),
            ),
            const AppIconView(AppIcon.chevronRight, size: 16, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirm extends StatelessWidget {
  const _DeleteConfirm({required this.onCancel, required this.onDelete});

  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.danger,
      radius: 22,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text('Delete your account and all data?', style: AppText.serif(19, color: AppColors.text)),
            Text(
              "Your map, reviews, photos and lists are removed within 30 days. This can't be undone.",
              style: AppText.sans(13, weight: FontWeight.w400, height: 1.45, color: AppColors.slate),
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Keep account',
                    height: 46,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    expand: true,
                    background: AppColors.white,
                    foreground: AppColors.text,
                    dashedBorder: AppColors.subtle,
                    onPressed: onCancel,
                  ),
                ),
                Expanded(
                  child: PillButton(
                    label: 'Delete',
                    height: 46,
                    fontSize: 14,
                    expand: true,
                    background: AppColors.danger,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
