import '../../core/l10n/l10n_extensions.dart';

enum ConnectionStatus {
  connected,
  reconnecting,
  polling,
  disconnected,
}

extension ConnectionStatusMessage on ConnectionStatus {
  String? localizedBannerMessage(AppLocalizations l10n) => switch (this) {
        ConnectionStatus.connected => null,
        ConnectionStatus.reconnecting => l10n.reconnecting,
        ConnectionStatus.polling => l10n.pollingFallback,
        ConnectionStatus.disconnected => l10n.connectionLost,
      };

  bool get showSpinner =>
      this == ConnectionStatus.reconnecting ||
      this == ConnectionStatus.polling;
}
