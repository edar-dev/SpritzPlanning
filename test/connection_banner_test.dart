import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spritz_planning/data/models/connection_status.dart';
import 'package:spritz_planning/shared/widgets/connection_banner.dart';

void main() {
  testWidgets('ConnectionBanner shows reconnecting message and spinner',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConnectionBanner(
            status: ConnectionStatus.reconnecting,
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.text('Riconnessione al bancone…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Aggiorna'), findsOneWidget);
  });

  testWidgets('ConnectionBanner shows disconnected without spinner',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConnectionBanner(status: ConnectionStatus.disconnected),
        ),
      ),
    );

    expect(find.text('Connessione persa al bancone'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('connected status has no banner message', () {
    expect(ConnectionStatus.connected.bannerMessage, isNull);
  });
}
