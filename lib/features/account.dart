import 'package:flutter/material.dart';

import '../core/hub_state.dart';
import '../core/ui.dart';
import 'auth.dart';
import 'checkout.dart';
import 'discover.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.initialSelection});
  final String? initialSelection;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? selection = widget.initialSelection;

  void choose(String option) {
    setState(() => selection = option);
    switch (option) {
      case 'Preferences':
        context.open(const PreferencesPage());
      case 'Account security':
        context.open(const ResetPage(fromProfile: true));
      case 'Customer Support':
        showDialog<void>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: const Text('Customer Support'),
            content: const Text(
              'For questions about this demo, check your order updates in Notifications.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      case 'Log out':
        context.hub.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => HubPage(
    tab: HubTab.profile,
    children: [
      Padding(
        padding: pageInset,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ClipOval(child: Photo('profile.png', width: 116, height: 116)),
        ),
      ),
      const SizedBox(height: 36),
      for (final option in [
        'Preferences',
        'Account security',
        'Customer Support',
        'Log out',
      ]) ...[
        Padding(
          padding: pageInset,
          child: ChoiceRow(
            option,
            selected: selection == option,
            onTap: () => choose(option),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key, this.initialSelection});
  final String? initialSelection;
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late String? selection = widget.initialSelection;

  void choose(String option, Widget page) {
    setState(() => selection = option);
    context.open(page);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <String, Widget>{
      'Account Info': const AccountInfoPage(),
      'Password': const ResetPage(fromProfile: true),
      'Delivery Location': const DeliveryPage(),
      'Payment Method': const PaymentPage(),
    };
    return HubPage(
      tab: HubTab.profile,
      children: [
        PageTitle(
          'Preferences',
          onBell: () => openNotifications(context, HubTab.profile),
        ),
        const SizedBox(height: 24),
        for (final action in actions.entries) ...[
          Padding(
            padding: pageInset,
            child: ChoiceRow(
              action.key,
              selected: selection == action.key,
              onTap: () => choose(action.key, action.value),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: pageInset,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: Icon(
                context.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 18,
              ),
              onPressed: context.hub.toggleTheme,
              label: Text(context.isDark ? 'Light mode' : 'Dark mode'),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});
  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  late final name = TextEditingController(text: context.hub.name);
  late final email = TextEditingController(text: context.hub.email);

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HubPage(
    footer: HubButton(
      'Save Changes',
      onPressed: () {
        if (name.text.trim().isEmpty || !isValidEmail(email.text)) {
          feedback(context, 'Enter a name and a valid email.');
          return;
        }
        context.hub.updateAccount(
          name: name.text.trim(),
          email: email.text.trim(),
        );
        FocusScope.of(context).unfocus();
        feedback(context, 'Account details saved.');
      },
    ),
    children: [
      PageTitle(
        'Account Info',
        onBell: () => openNotifications(context, HubTab.profile),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: pageInset,
        child: Column(
          children: [
            HubField('Username', controller: name),
            const SizedBox(height: 16),
            HubField(
              'Email',
              controller: email,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              width: double.infinity,
              child: Material(
                color: context.soft,
                borderRadius: cardRadius,
                child: InkWell(
                  onTap: () => context.open(const ResetPage(fromProfile: true)),
                  borderRadius: cardRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Expanded(child: Label('••••••••', maxLines: 1)),
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: context.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
