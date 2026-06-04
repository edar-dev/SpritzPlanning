/// Configurazione app (URL produzione per inviti e QR).
abstract final class AppConfig {
  static const productionWebUrl = 'https://spritz-planning.vercel.app';

  static String joinUrlForCode(String code) {
    return '$productionWebUrl/app/?code=${Uri.encodeComponent(code.trim())}';
  }

  /// Short share URL for Open Graph previews (#69).
  static String shareJoinUrlForCode(String code) {
    final trimmed = code.trim();
    return '$productionWebUrl/j/${Uri.encodeComponent(trimmed)}';
  }

  static const helpUrl = '$productionWebUrl/app/help';

  static const feedbackUrl =
      'https://github.com/edar-dev/SpritzPlanning/issues/new/choose';
}
