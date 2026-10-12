/// Build-time configuration, passed with
/// `flutter run --dart-define-from-file=config/staging.json`.
///
/// Only public values belong here: the Supabase URL and publishable key are
/// safe to ship because row-level security protects the data. Secrets never
/// reach the app.
///
/// When nothing is passed (tests, CI, a plain `flutter run`), [isConfigured]
/// is false and the app runs on the built-in demo data instead of Supabase.
abstract final class Env {
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'demo');
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
