import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/content.dart';

/// A hidden developer menu (long-press the version in Settings) to jump to
/// the edge-case screens from the design: offline, loading, errors, empty.
Future<void> showDesignStatesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) {
      final state = sheetContext.appRead;

      void goHome(AppTab tab) {
        state.selectTab(tab);
        Navigator.popUntil(sheetContext, (r) => r.settings.name == Routes.home || r.isFirst);
      }

      final items = <(String, String, VoidCallback)>[
        (
          'Offline',
          '24a · No connection',
          () {
            Navigator.pop(sheetContext);
            Navigator.pushNamed(context, Routes.offline);
          },
        ),
        (
          'Feed loading',
          '24c · Skeleton cards',
          () {
            state.loadFeed(delay: const Duration(seconds: 4));
            goHome(AppTab.feed);
          },
        ),
        (
          'Feed failed to load',
          '24b · Error with retry',
          () {
            state.loadFeed(fail: true, delay: Duration.zero);
            goHome(AppTab.feed);
          },
        ),
        (
          'Place with no reviews',
          '23c · Ujjayanta Palace',
          () {
            Navigator.pop(sheetContext);
            Navigator.pushNamed(context, Routes.place, arguments: 'ujjayanta');
          },
        ),
        (
          'Start as a new user',
          '23a / 23b · Empty map and friends',
          () {
            state.startNewAccount();
            state.completeProfile(name: 'Bodhi Chakraborty', username: 'bodhi');
            goHome(AppTab.map);
          },
        ),
        (
          'Reset demo account',
          'Back to the populated map',
          () {
            state.signInExisting();
            goHome(AppTab.map);
          },
        ),
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                child: Text('Design states', style: AppText.sans(22, weight: FontWeight.w700, letterSpacing: -0.4)),
              ),
              for (final (title, subtitle, onTap) in items) ChevronRow(title: title, subtitle: subtitle, onTap: onTap),
            ],
          ),
        ),
      );
    },
  );
}
