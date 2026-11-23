import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hungry_hub/app.dart';
import 'package:hungry_hub/core/hub_state.dart';
import 'package:hungry_hub/data/catalog.dart';
import 'package:hungry_hub/features/account.dart';
import 'package:hungry_hub/features/auth.dart';
import 'package:hungry_hub/features/checkout.dart';
import 'package:hungry_hub/features/discover.dart';
import 'package:integration_test/integration_test.dart';

import '../test/widget_test.dart' as smoke;

typedef Screen = (String, Widget Function());

final screens = <Screen>[
  ('splash', () => const SplashPage()),
  ('onboarding-order', () => const OnboardingPage()),
  ('onboarding-safe', () => const OnboardingPage(initialIndex: 1)),
  ('onboarding-fast', () => const OnboardingPage(initialIndex: 2)),
  ('signup', () => const SignUpPage()),
  ('signup-typing', () => const SignUpPage(sample: 1)),
  ('signup-ready', () => const SignUpPage(sample: 2)),
  ('phone', () => const PhonePage()),
  ('phone-typing', () => const PhonePage(sample: 1)),
  ('phone-ready', () => const PhonePage(sample: 2)),
  (
    'verify-phone',
    () => const VerifyPage(contact: '+21 568789798', phone: true, signUp: true),
  ),
  (
    'verify-phone-ready',
    () => const VerifyPage(
      contact: '+21 568789798',
      phone: true,
      signUp: true,
      filled: true,
    ),
  ),
  ('login', () => const LoginPage()),
  ('login-typing', () => const LoginPage(sample: 1)),
  ('login-ready', () => const LoginPage(sample: 2)),
  ('recovery', () => const RecoveryPage(email: 'william@example.com')),
  (
    'recovery-selected',
    () =>
        const RecoveryPage(email: 'william@example.com', selected: 'Via Email'),
  ),
  ('verify-email', () => const VerifyPage(contact: 'william@example.com')),
  (
    'verify-email-ready',
    () => const VerifyPage(contact: 'william@example.com', filled: true),
  ),
  ('reset', () => const ResetPage()),
  ('reset-typing', () => const ResetPage(sample: 1)),
  ('reset-ready', () => const ResetPage(sample: 2)),
  ('home', () => const HomePage()),
  ('nearby', () => const NearbyPage()),
  ('nearby-selected', () => NearbyPage(initialSelection: restaurants.last)),
  ('search', () => const SearchPage()),
  ('notifications', () => const NotificationsPage()),
  ('trending', () => const TrendingPage()),
  ('dish', () => DishPage(dish: dishes.first, initialCount: 2)),
  ('profile', () => const ProfilePage()),
  (
    'profile-selected',
    () => const ProfilePage(initialSelection: 'Preferences'),
  ),
  ('preferences', () => const PreferencesPage()),
  (
    'preferences-selected',
    () => const PreferencesPage(initialSelection: 'Account Info'),
  ),
  ('account', () => const AccountInfoPage()),
  ('cart', () => const CartPage()),
  ('cart-review', () => const CartPage(review: true)),
  ('payment', () => const PaymentPage()),
  ('delivery', () => const DeliveryPage()),
  ('checkout', () => const CheckoutPage()),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture each Pixso state in both themes', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    final captures = <String, String>{};
    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      for (final (id, build) in screens) {
        final name = '$theme/$id';
        final state = HubState()..dark = dark;
        if (id.startsWith('cart') || id == 'checkout') {
          state.changeQuantity(dishes.first, 1);
          state.changeQuantity(dishes[1], 1);
        }
        await tester.pumpWidget(
          HungryHubApp(key: ValueKey(name), state: state, initialPage: build()),
        );
        await tester.pumpAndSettle();
        if (id == 'splash') {
          final images = find.byType(Image);
          final context = tester.element(images.first);
          final providers = tester
              .widgetList<Image>(images)
              .map((image) => image.image)
              .toSet();
          await tester.runAsync(
            () => Future.wait(
              providers.map((provider) => precacheImage(provider, context)),
            ),
          );
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: name);
        final bytes = await binding.takeScreenshot(name);
        captures[name] = base64Encode(bytes);
        binding.reportData!.remove('screenshots');
        await tester.pumpWidget(const SizedBox.shrink());
        state.dispose();
      }
    }
    binding.reportData = {'captures': captures};
  }, timeout: const Timeout(Duration(minutes: 10)));
  smoke.main();
}
