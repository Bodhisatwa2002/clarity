import 'package:flutter/material.dart';

import '../core/data/backend.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class ClarityApp extends StatefulWidget {
  const ClarityApp({super.key, this.initialRoute, this.backend});

  /// Defaults to the platform's route — the splash, or whatever
  /// `flutter run --route=/home` asks for during development.
  final String? initialRoute;

  /// Supabase in a configured build; null means the built-in demo data.
  final Backend? backend;

  @override
  State<ClarityApp> createState() => _ClarityAppState();
}

class _ClarityAppState extends State<ClarityApp> {
  late final AppState _state = AppState(backend: widget.backend);

  @override
  void initState() {
    super.initState();
    _state.restoreSession();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Clarity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: widget.initialRoute,
        onGenerateRoute: Routes.generate,
      ),
    );
  }
}
