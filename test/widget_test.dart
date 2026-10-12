// Smoke tests for the Clarity app flow.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clarity/app/clarity_app.dart';
import 'package:clarity/app/routes.dart';
import 'package:clarity/core/models/visit.dart';
import 'package:clarity/core/state/app_state.dart';
import 'package:clarity/features/review/widgets/review_fields.dart';
import 'package:clarity/features/review/write_review_screen.dart';
import 'package:clarity/core/utils/share_links.dart';
import 'package:clarity/features/share/share_sheet.dart';

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

  testWidgets('Welcome slides keep chips, dots and buttons in the same place', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.welcome));
    await tester.pump(const Duration(milliseconds: 500));

    final firstChips = ['Cafés', 'clarity.in/you', '12 friends are here'];
    double? chipsY, buttonY, dotsY;
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.bySemanticsLabel('Show slide ${i + 1} of 3'));
      await tester.pump(const Duration(milliseconds: 500));
      final chips = tester.getTopLeft(find.text(firstChips[i])).dy;
      final button = tester.getTopLeft(find.text('Get started')).dy;
      final dots = tester.getTopLeft(find.bySemanticsLabel('Show slide 1 of 3')).dy;
      expect(chips, chipsY ?? chips, reason: 'chips moved on slide ${i + 1}');
      expect(button, buttonY ?? button, reason: 'button moved on slide ${i + 1}');
      expect(dots, dotsY ?? dots, reason: 'dots moved on slide ${i + 1}');
      (chipsY, buttonY, dotsY) = (chips, button, dots);
    }
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

  testWidgets('Log in and sign up are labelled, and you can switch between them', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.welcome));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('I already have an account'));
    await _settle(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pump();
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Sign up · Step 1 of 3'), findsOneWidget);

    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pump();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Terms and Privacy Policy open from the phone screen', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.welcome));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Get started'));
    await _settle(tester);

    await tester.tapOnText(find.textRange.ofSubstring('Terms'));
    await _settle(tester);
    expect(find.text('Terms of use'), findsOneWidget);
    expect(find.text('1. Who can use it'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await _settle(tester);

    await tester.tapOnText(find.textRange.ofSubstring('Privacy Policy'));
    await _settle(tester);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('1. Who we are'), findsOneWidget);
  });

  testWidgets('Create profile copies the map link', (tester) async {
    _usePhoneSize(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.createProfile));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(EditableText).at(1), 'bodhi.c');
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(copied, 'https://clarity.in/bodhi.c');
    expect(find.text('Copied'), findsOneWidget);
    expect(find.text('Link copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('New user signs up and lands on the empty map', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.welcome));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Get started'));
    await _settle(tester);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Sign up · Step 1 of 3'), findsOneWidget);
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

  testWidgets('Send code stays above the keyboard and the number pad can be closed', (tester) async {
    _usePhoneSize(tester);
    // An iPhone number pad is about 291pt tall.
    tester.view.viewInsets = const FakeViewPadding(bottom: 291 * 3);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.phone));
    await _settle(tester);
    await tester.showKeyboard(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), '98765');
    await tester.pump();

    final button = tester.getRect(find.text('Send code'));
    expect(button.bottom, lessThanOrEqualTo(844 - 291), reason: 'Send code must not sit under the keyboard');

    // Tapping outside the field closes the keyboard.
    await tester.tapAt(const Offset(195, 300));
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));

    // Typing the full number closes it too.
    await tester.showKeyboard(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), '9876543210');
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));
  });

  testWidgets('The category sheet fits on screen and picks a category', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(Routes.review, arguments: const ReviewArgs('ujjayanta'));
    await _settle(tester);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await _settle(tester);
    await tester.tap(find.text('CATEGORY'));
    await _settle(tester);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);

    await tester.tap(find.text('Beach'));
    await _settle(tester);
    expect(find.text('Category'), findsNothing);
    expect(find.text('Beach'), findsOneWidget);
  });

  // Web and larger text sizes measure fonts a little taller; the preview card
  // has a fixed height, so check it at 1.1x text too.
  for (final scale in [1.0, 1.1]) {
    testWidgets('The share card fits for map, place and list (text ${scale}x)', (tester) async {
      _usePhoneSize(tester);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
      await _settle(tester);

      final context = tester.element(find.byType(Navigator).first);
      showShareSheet(context, target: ShareTarget.place, placeId: 'neermahal');
      await _settle(tester);
      for (final tab in ['My map', 'This place', 'A list']) {
        await tester.tap(find.text(tab));
        await _settle(tester);
      }
    });
  }

  test('Share links all follow clarity.in/<username>/…', () {
    expect(ShareLinks.map('bodhi'), 'clarity.in/bodhi');
    expect(ShareLinks.place('bodhi', 'Neermahal Palace'), 'clarity.in/bodhi/neermahal-palace');
    expect(ShareLinks.list('bodhi', 'Goa trip 2027!'), 'clarity.in/bodhi/list/goa-trip-2027');
    expect(ShareLinks.https('clarity.in/bodhi'), 'https://clarity.in/bodhi');
  });

  testWidgets('Sharing a list uses your username and the list name', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    final context = tester.element(find.byType(Navigator).first);
    final state = AppScope.read(context);
    final list = state.list(null)!;

    showShareSheet(context, target: ShareTarget.list);
    await _settle(tester);
    expect(find.text(ShareLinks.list(state.username, list.title)), findsWidgets);
  });

  testWidgets('"A list" is hidden until you have a list', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    final context = tester.element(find.byType(Navigator).first);
    final state = AppScope.read(context)..startNewAccount();
    expect(state.lists, isEmpty);

    showShareSheet(context, target: ShareTarget.list);
    await _settle(tester);
    expect(find.text('A list'), findsNothing);
    expect(find.text('My map'), findsOneWidget);
    expect(find.textContaining('my-list'), findsNothing);
  });

  testWidgets('Add to a list ticks a place into an existing list', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    final state = AppScope.read(tester.element(find.byType(Navigator)));
    final list = state.lists.firstWhere((l) => !state.isInList(l.id, 'neermahal'));

    nav.pushNamed(Routes.place, arguments: 'neermahal');
    await _settle(tester);
    await tester.tap(find.text('Add to a list'));
    await _settle(tester);
    await tester.tap(find.text(list.title).last);
    await tester.pump();
    expect(state.isInList(list.id, 'neermahal'), isTrue);
    await tester.tap(find.text('Done'));
    await _settle(tester);
    expect(find.text('Add to a list'), findsOneWidget, reason: 'back on the place page');
  });

  testWidgets('A new account creates its first list from a place', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    final state = AppScope.read(tester.element(find.byType(Navigator)))..startNewAccount();
    expect(state.lists, isEmpty);

    nav.pushNamed(Routes.collabList);
    await _settle(tester);
    expect(find.text('No lists yet'), findsOneWidget, reason: 'not a blank screen');
    nav.pop();
    await _settle(tester);

    // You reviewed it, so the place page offers "Add to a list".
    state.saveVisit(
      Visit(
        id: state.newVisitId('neermahal'),
        placeId: 'neermahal',
        authorId: state.me.id,
        date: DateTime(2026, 10, 1),
        rating: 5,
        tip: 'Go at sunset.',
      ),
    );
    nav.pushNamed(Routes.place, arguments: 'neermahal');
    await _settle(tester);
    await tester.tap(find.text('Add to a list'));
    await _settle(tester);
    await tester.enterText(find.byType(EditableText), 'Tripura weekend');
    await tester.pump();
    await tester.tap(find.text('Create list'));
    await _settle(tester);

    expect(state.lists.single.title, 'Tripura weekend');
    expect(state.isInList(state.lists.single.id, 'neermahal'), isTrue);
    expect(find.text('Tripura weekend'), findsOneWidget, reason: 'the new list opens');
    expect(find.text('Your list'), findsOneWidget);
  });

  testWidgets('A review records recommend, custom tags and budget per person', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const ClarityApp(initialRoute: Routes.home));
    await _settle(tester);
    final state = AppScope.read(tester.element(find.byType(Navigator)));
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(Routes.review, arguments: const ReviewArgs('ujjayanta'));
    await _settle(tester);

    expect(find.text('Want to go'), findsNothing, reason: 'reviews are only for places you visited');
    await tester.tap(find.bySemanticsLabel('4 stars'));
    await tester.enterText(find.byType(EditableText).first, 'Museum closes at 5pm.');
    await tester.pump();

    await tester.scrollUntilVisible(find.text('No'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('No'));
    // Scroll past the tags so they sit clear of the floating Post button.
    await tester.scrollUntilVisible(find.text('per person'), 300, scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pump();
    await tester.tap(find.text('+ Add your own'));
    await tester.pump();
    await tester.enterText(
      find.descendant(of: find.byType(CustomTagInput), matching: find.byType(EditableText)),
      'Peacocks on the lawn',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Peacocks on the lawn'), findsOneWidget);

    await tester.enterText(find.descendant(of: find.byType(BudgetField), matching: find.byType(EditableText)), '₹350');
    await tester.pump();
    expect(find.text('₹₹'), findsOneWidget, reason: 'level is worked out from the amount');

    await tester.tap(find.text('Post review'));
    await _settle(tester);
    final visit = state.myVisitFor('ujjayanta')!;
    expect(visit.recommended, isFalse);
    expect(visit.statusLabel, 'Not recommended');
    expect(visit.tags, contains('Peacocks on the lawn'));
    expect(visit.budgetPerPerson, 350);
    expect(visit.budgetLabel, '₹₹ · ₹350 per person');
  });
}
