/// Build-time configuration, passed with `--dart-define`.
///
/// Only public values belong here. The Supabase publishable key is designed to
/// ship inside apps; the secret key must never be passed to the app.
class Env {
  const Env({required this.supabaseUrl, required this.supabasePublishableKey});

  /// Reads the values given at build time, for example:
  /// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
  factory Env.fromBuildTime() => const Env(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  final String supabaseUrl;
  final String supabasePublishableKey;

  /// Names of the settings that are missing or invalid; empty when the
  /// configuration is usable.
  List<String> get problems => [
    if (Uri.tryParse(supabaseUrl)?.scheme != 'https') 'SUPABASE_URL',
    if (supabasePublishableKey.isEmpty) 'SUPABASE_PUBLISHABLE_KEY',
  ];

  bool get isValid => problems.isEmpty;
}
