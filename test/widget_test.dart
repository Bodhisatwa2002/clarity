// Basic smoke test for the Clarity app shell.
//
// Verifies the app boots and the 5 bottom-navigation tabs are present.

import 'package:flutter_test/flutter_test.dart';

import 'package:clarity/main.dart';

void main() {
  testWidgets('App boots and shows the bottom navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ClarityApp());

    // The 5 tabs from the feature brief should be visible.
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
