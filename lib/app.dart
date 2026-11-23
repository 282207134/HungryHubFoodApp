import 'package:flutter/material.dart';

import 'core/hub_state.dart';
import 'core/ui.dart';
import 'features/account.dart';
import 'features/auth.dart';
import 'features/checkout.dart';
import 'features/discover.dart';

class HungryHubApp extends StatefulWidget {
  const HungryHubApp({super.key, this.state, this.initialPage});

  final HubState? state;
  final Widget? initialPage;

  @override
  State<HungryHubApp> createState() => _HungryHubAppState();
}

class _HungryHubAppState extends State<HungryHubApp> {
  late final HubState state = widget.state ?? HubState();

  @override
  void dispose() {
    if (widget.state == null) state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HubScope(
    state: state,
    child: ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Hungry Hub',
        debugShowCheckedModeBanner: false,
        theme: hubTheme(Brightness.light),
        darkTheme: hubTheme(Brightness.dark),
        themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
        home: widget.initialPage ?? const SplashPage(),
        routes: {
          '/browse': (_) => const BrowseShell(),
          '/sign-in': (_) => const LoginPage(),
        },
      ),
    ),
  );
}

class BrowseShell extends StatelessWidget {
  const BrowseShell({super.key});

  @override
  Widget build(BuildContext context) => switch (context.hub.tab) {
    HubTab.home => const HomePage(),
    HubTab.search => const SearchPage(),
    HubTab.cart => const CartPage(),
    HubTab.nearby => const NearbyPage(),
    HubTab.profile => const ProfilePage(),
  };
}
