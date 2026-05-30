/// Configurazione app (URL produzione per inviti e QR).
abstract final class AppConfig {
  static const productionWebUrl = 'https://spritz-planning.vercel.app';

  static String joinUrlForCode(String code) {
    return '$productionWebUrl/?code=${Uri.encodeComponent(code.trim())}';
  }
}
