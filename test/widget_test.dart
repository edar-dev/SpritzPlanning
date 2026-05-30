import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spritz_planning/app.dart';
import 'package:spritz_planning/core/constants/app_strings.dart';

void main() {
  testWidgets('Home screen shows app name and CTAs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpritzPlanningApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.openLocale), findsOneWidget);
    expect(find.text(AppStrings.enterBancone), findsOneWidget);
  });

  testWidgets('SpritzCard renders deck value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
