/// Configurazione Sentry (opzionale).
abstract final class SentryConfig {
  static const dsn = String.fromEnvironment('SENTRY_DSN');
  static const gitSha = String.fromEnvironment('GIT_SHA');

  static bool get isConfigured => dsn.isNotEmpty;
}
