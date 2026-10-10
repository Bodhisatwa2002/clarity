// Smoke tests for the Clarity app flow.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clarity/app/clarity_app.dart';
import 'package:clarity/app/routes.dart';

/// Renders at the iPhone size the design was drawn for.
void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Lets a page transition run to completion (pumpAndSettle would wait on the
/// splash screen's looping animation underneath).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Splash hands off to the welcome screen', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp());
    expect(find.text('Clarity'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Home shows the map with the floating nav', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Hi, Bodhi'), findsOneWidget);
    expect(find.text('34 places across 6 cities'), findsOneWidget);
    expect(find.text('Neermahal'), findsOneWidget);
    expect(find.bySemanticsLabel('Add a place'), findsOneWidget);
  });

  testWidgets('List view filters by category', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('List'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('7 places'), findsOneWidget);

    await tester.tap(find.text('Food').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2 places'), findsOneWidget);
  });

  testWidgets('New user signs up and lands on the empty map', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.welcome));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Get started'));
    await _settle(tester);
    expect(find.text("What's your number?"), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Send code'));
    await _settle(tester);

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify & continue'));
    await _settle(tester);

    await tester.enterText(find.byType(EditableText).at(0), 'Asha Debbarma');
    await tester.enterText(find.byType(EditableText).at(1), 'rahul');
    await tester.pump();
    expect(find.text('Taken'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).at(1), 'asha.d');
    await tester.pump();
    expect(find.text('Available'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    await tester.tap(find.text('Not now'));
    await _settle(tester);
    expect(find.text('Hi, Asha'), findsOneWidget);
    expect(find.text('Add your first place'), findsOneWidget);
  });
}
