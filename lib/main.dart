import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/clarity_app.dart';
import 'core/config/env.dart';
import 'core/data/backend.dart';
import 'core/data/supabase_backend.dart';

/// Runs on Supabase when built with `--dart-define-from-file=config/<env>.json`,
/// otherwise on the built-in demo data.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Backend? backend;
  if (Env.isConfigured) {
    await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
    backend = SupabaseBackend(Supabase.instance.client);
  }
  runApp(ClarityApp(backend: backend));
}
