import 'package:flutter/material.dart';

import '../core/hub_state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import 'discover.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, this.review = false});
  final bool review;

  @override
  Widget build(BuildContext context) {
    final state = context.hub;
    final empty = state.cart.isEmpty;
    return HubPage(
      tab: HubTab.cart,
      footer: HubButton(
        empty
            ? 'Browse food'
            : review
            ? 'Review Payment'
            : 'Go To Cart',
        onPressed: empty
            ? () => context.goTab(HubTab.home)
            : () {
                if (review) {
                  context.open(const PaymentPage(checkout: true));
                } else {
                  context.open(const CartPage(review: true));
                }
              },
      ),
      children: [
        LocationHeader(
          onBell: () => openNotifications(context, HubTab.cart),
          onLocation: () => context.goTab(HubTab.nearby),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: pageInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Label('Added Items', size: 16, weight: FontWeight.w500),
              const SizedBox(height: 24),
              if (empty)
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: context.muted,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      Label('Your cart is empty', color: context.muted),
                    ],
                  ),
                ),
              for (final entry in state.cart.entries) ...[
                _CartItem(entry.key, entry.value),
                const SizedBox(height: 16),
              ],
              if (review && !empty) ...[
                const SizedBox(height: 40),
                const _Totals(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem(this.dish, this.amount);
  final Dish dish;
  final int amount;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: cardRadius,
        child: Photo(dish.image, width: 60, height: 79),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(dish.name, color: context.muted),
            Label(money(dish.price), weight: FontWeight.w700),
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                color: context.soft,
                border: Border.all(color: context.palette.outline),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _adjust(context, Icons.remove, 'Remove one ${dish.name}', -1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Label('$amount', size: 12, color: orange),
                  ),
                  _adjust(context, Icons.add, 'Add one ${dish.name}', 1),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _adjust(BuildContext context, IconData icon, String label, int by) =>
      SizedBox(
        width: 28,
        height: 27,
        child: ActionIcon(
          icon,
          label,
          size: 13,
          onTap: () => context.hub.changeQuantity(dish, by),
          color: context.muted,
        ),
      );
}

class _Totals extends StatelessWidget {
  const _Totals();

  @override
  Widget build(BuildContext context) {
    final state = context.hub;
    return Column(
      children: [
        _amount(context, 'Subtotal', state.subtotal),
        const SizedBox(height: 8),
        _DottedRule(color: context.palette.outline),
        const SizedBox(height: 18),
        _amount(context, 'Delivery', state.deliveryFee),
        const SizedBox(height: 8),
        _DottedRule(color: context.palette.outline),
        const SizedBox(height: 18),
        _amount(context, 'Total', state.total, emphasized: true),
      ],
    );
  }

  Widget _amount(
    BuildContext context,
    String title,
    int cents, {
    bool emphasized = false,
  }) {
    final size = emphasized ? 20.0 : 16.0;
    final color = emphasized ? context.ink : context.muted;
    final weight = emphasized ? FontWeight.w500 : FontWeight.w400;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Label(title, size: size, color: color, weight: weight),
        Label(money(cents), size: size, color: color, weight: weight),
      ],
    );
  }
}

class _DottedRule extends StatelessWidget {
  const _DottedRule({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 3,
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          (constraints.maxWidth / 7).floor(),
          (_) => Container(width: 3, height: 1, color: color),
        ),
      ),
    ),
  );
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, this.checkout = false});
  final bool checkout;

  @override
  Widget build(BuildContext context) => HubPage(
    children: [
      PageTitle(
        'Choose Payment Method',
        onBell: () =>
            openNotifications(context, checkout ? HubTab.cart : HubTab.profile),
      ),
      const SizedBox(height: 24),
      for (final method in paymentMethods) ...[
        Padding(
          padding: pageInset,
          child: ChoiceRow(
            method,
            selected: method == context.hub.payment,
            onTap: () {
              context.hub.selectPayment(method);
              if (checkout) context.open(const DeliveryPage(checkout: true));
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key, this.checkout = false});
  final bool checkout;

  @override
  Widget build(BuildContext context) => HubPage(
    children: [
      PageTitle(
        'Deliver to',
        onBell: () =>
            openNotifications(context, checkout ? HubTab.cart : HubTab.profile),
      ),
      const SizedBox(height: 24),
      for (final address in addresses.entries) ...[
        Padding(
          padding: pageInset,
          child: ChoiceRow(
            address.key,
            detail: address.value,
            selected: address.key == context.hub.address,
            onTap: () {
              context.hub.selectAddress(address.key);
              if (checkout) context.open(const CheckoutPage());
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.hub;
    return HubPage(
      footer: HubButton(
        'Check Out',
        onPressed: state.cart.isEmpty
            ? null
            : () async {
                final approved = await showDialog<bool>(
                  context: context,
                  builder: (dialog) => AlertDialog(
                    title: const Text('Place demo order?'),
                    content: Text(
                      '${money(state.total)} · ${state.payment}\nDeliver to ${state.address}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialog, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialog, true),
                        child: const Text('Place order'),
                      ),
                    ],
                  ),
                );
                if (approved != true || !context.mounted) return;
                state.placeOrder();
                final navigator = Navigator.of(context);
                state.chooseTab(HubTab.home);
                navigator.popUntil((route) => route.isFirst);
                navigator.push(
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
      ),
      children: [
        PageTitle(
          'Check out',
          onBell: () => openNotifications(context, HubTab.cart),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: pageInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: state.payment == paymentMethods.first
                    ? const AspectRatio(
                        aspectRatio: 358 / 224,
                        child: Photo('checkout.jpeg'),
                      )
                    : Container(
                        height: 224,
                        color: orange,
                        alignment: Alignment.center,
                        child: Label(
                          state.payment,
                          size: 28,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 48),
              const _Totals(),
            ],
          ),
        ),
      ],
    );
  }
}
