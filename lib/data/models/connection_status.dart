enum ConnectionStatus {
  connected,
  reconnecting,
  polling,
  disconnected,
}

extension ConnectionStatusMessage on ConnectionStatus {
  String? get bannerMessage => switch (this) {
        ConnectionStatus.connected => null,
        ConnectionStatus.reconnecting => 'Riconnessione al bancone…',
        ConnectionStatus.polling => 'Sincronizzazione in corso…',
        ConnectionStatus.disconnected => 'Connessione persa al bancone',
      };

  bool get showSpinner =>
      this == ConnectionStatus.reconnecting ||
      this == ConnectionStatus.polling;
}
