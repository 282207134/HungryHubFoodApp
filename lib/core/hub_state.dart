import 'package:flutter/material.dart';

import '../data/catalog.dart';

enum HubTab { home, search, cart, nearby, profile }

class HubState extends ChangeNotifier {
  bool dark = false;
  HubTab tab = HubTab.home;
  String name = 'William Chain';
  String email = 'william@example.com';
  String phone = '+21 568789798';
  String payment = paymentMethods.first;
  String address = addresses.keys.first;
  int ordersPlaced = 0;

  final Map<Dish, int> _cart = {};
  Map<Dish, int> get cart => Map.unmodifiable(_cart);
  int get cartCount => _cart.values.fold(0, (a, b) => a + b);
  int get subtotal =>
      _cart.entries.fold(0, (sum, item) => sum + item.key.price * item.value);
  int get deliveryFee => _cart.isEmpty ? 0 : 359;
  int get total => subtotal + deliveryFee;

  void changeQuantity(Dish dish, int by) {
    final quantity = (_cart[dish] ?? 0) + by;
    if (quantity <= 0) {
      _cart.remove(dish);
    } else {
      _cart[dish] = quantity;
    }
    notifyListeners();
  }

  void chooseTab(HubTab value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  void toggleTheme() {
    dark = !dark;
    notifyListeners();
  }

  void updateAccount({String? name, String? email, String? phone}) {
    this.name = name ?? this.name;
    this.email = email ?? this.email;
    this.phone = phone ?? this.phone;
    notifyListeners();
  }

  void selectPayment(String value) {
    payment = value;
    notifyListeners();
  }

  void selectAddress(String value) {
    address = value;
    notifyListeners();
  }

  void placeOrder() {
    if (_cart.isEmpty) return;
    ordersPlaced++;
    _cart.clear();
    notifyListeners();
  }

  void signOut() {
    _cart.clear();
    tab = HubTab.home;
    ordersPlaced = 0;
    notifyListeners();
  }
}

class HubScope extends InheritedNotifier<HubState> {
  const HubScope({super.key, required HubState state, required super.child})
    : super(notifier: state);

  static HubState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HubScope>()!.notifier!;
}

extension HubContext on BuildContext {
  HubState get hub => HubScope.of(this);
  Future<T?> open<T>(Widget page) =>
      Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  void goTab(HubTab tab) {
    hub.chooseTab(tab);
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}
