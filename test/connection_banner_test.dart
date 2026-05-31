import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spritz_planning/l10n/app_localizations.dart';

import 'package:spritz_planning/data/models/connection_status.dart';
import 'package:spritz_planning/shared/widgets/connection_banner.dart';

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('it'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('ConnectionBanner shows reconnecting message and spinner',
      (tester) async {
    await tester.pumpWidget(
      _app(
        ConnectionBanner(
          status: ConnectionStatus.reconnecting,
          onRefresh: () {},
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
      _app(
        const ConnectionBanner(status: ConnectionStatus.disconnected),
      ),
    );

    expect(find.text('Connessione persa al bancone'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('connected status has no banner message', () {
    final l10n = lookupAppLocalizations(const Locale('it'));
    expect(
      ConnectionStatus.connected.localizedBannerMessage(l10n),
      isNull,
    );
  });
}
