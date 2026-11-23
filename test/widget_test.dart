import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hungry_hub/app.dart';
import 'package:hungry_hub/core/hub_state.dart';
import 'package:hungry_hub/features/auth.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'Black']) {
      fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    await fonts.load();
  });
  testWidgets('Login, add food and place a local order', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = HubState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      HungryHubApp(state: state, initialPage: const LoginPage()),
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Login'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField).at(0), 'demo@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'demo1234');

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await tester.pumpAndSettle();
    }

    await tester.pumpAndSettle();
    await tap(find.text('Login'));
    expect(find.text('Karachi | Pakistan'), findsOneWidget);
    await tap(find.text('See all'));
    await tap(find.byTooltip('Add Cheesy cream chicken'));
    expect(state.cartCount, 1);
    await tap(find.byTooltip('Cart'));
    await tap(find.text('Go To Cart'));
    expect(find.text(r'$18.58'), findsOneWidget);
    await tap(find.text('Review Payment'));
    await tap(find.text('PayPal'));
    await tap(find.text('Office'));
    await tap(find.text('Check Out'));
    await tap(find.text('Place order'));
    expect(state.cartCount, 0);
    expect(state.ordersPlaced, 1);
    expect(find.text('Your demo order is on the way.'), findsOneWidget);
  });

  testWidgets(
    'Recovery verifies the demo code and accepts matching passwords',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const HungryHubApp(initialPage: LoginPage()));
      Future<void> tap(String label) async {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      await tap('Forgot Password?');
      await tap('Via Email');
      await tap('Next');
      await tester.enterText(
        find.byKey(const Key('verification-code')),
        '8806',
      );
      await tap('Verify');
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'better1234');
      await tester.enterText(fields.at(1), 'better1234');
      await tester.pumpAndSettle();
      await tap('Reset Password');
      expect(find.text('Login your account'), findsOneWidget);
    },
  );
}
