import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/hub_state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';

void openNotifications(BuildContext context, HubTab tab) =>
    context.open(NotificationsPage(tab: tab));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => HubPage(
    tab: HubTab.home,
    children: [
      LocationHeader(
        onBell: () => openNotifications(context, HubTab.home),
        onLocation: () => context.goTab(HubTab.nearby),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: pageInset,
        child: SearchBox(onTap: () => context.goTab(HubTab.search)),
      ),
      const SizedBox(height: 24),
      const _SectionTitle('Featured'),
      const SizedBox(height: 6),
      _Rail(
        height: 190,
        children: [
          _Promo(
            'Breakfast best deals to boost your morning',
            'by James Arthur',
            'james.png',
            () => context.open(const TrendingPage()),
          ),
          _Promo(
            'Healthy food with the best deals',
            'by Olivia',
            'olivia.png',
            () => context.open(const TrendingPage()),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const _SectionTitle('Category'),
      const SizedBox(height: 16),
      _Choices(
        categories,
        selected: categories.first,
        onChoose: (value) => context.open(SearchPage(initialCategory: value)),
      ),
      const SizedBox(height: 24),
      _SectionTitle(
        'Trending',
        onSeeAll: () => context.open(const TrendingPage()),
      ),
      const SizedBox(height: 16),
      _Rail(
        height: 281,
        children: [
          for (final dish in dishes.take(4))
            SizedBox(width: 233, child: _DishCard(dish, wide: true)),
        ],
      ),
      const SizedBox(height: 24),
      _SectionTitle(
        'Restaurant near me',
        onSeeAll: () => context.goTab(HubTab.nearby),
      ),
      const SizedBox(height: 16),
      _Rail(
        height: 242,
        children: [
          for (final restaurant in restaurants.take(3))
            _RestaurantCard(
              restaurant,
              onTap: () =>
                  context.open(NearbyPage(initialSelection: restaurant)),
            ),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pageInset,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Label(title, size: 16, weight: FontWeight.w500, maxLines: 1),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: const Label(
              'See all',
              color: orange,
              weight: FontWeight.w500,
            ),
          ),
      ],
    ),
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.onTap,
    this.onChanged,
    this.controller,
    this.hint = 'Search for your favorite food',
  });
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.search, size: 27, color: context.muted);
    return SizedBox(
      height: 56,
      child: Material(
        color: context.soft,
        borderRadius: cardRadius,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: cardRadius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 9),
                      Flexible(
                        child: Label(hint, color: context.muted, maxLines: 1),
                      ),
                    ],
                  ),
                ),
              )
            : TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                cursorColor: orange,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: icon,
                  prefixIconConstraints: const BoxConstraints(minWidth: 48),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  hintText: hint,
                  hintStyle: TextStyle(color: context.muted, fontSize: 14),
                ),
              ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.height, required this.children});
  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ListView.separated(
      padding: pageInset,
      scrollDirection: Axis.horizontal,
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
      separatorBuilder: (_, _) => const SizedBox(width: 12),
    ),
  );
}

class _Promo extends StatelessWidget {
  const _Promo(this.title, this.author, this.avatar, this.onTap);
  final String title, author, avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final copy = context.isDark ? const Color(0xFF121212) : Colors.white;
    return SizedBox(
      width: 287,
      height: 190,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: 10,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: ColoredBox(
                    color: const Color(0xFFF9D0A7),
                    child: CustomPaint(painter: _PromoLines()),
                  ),
                ),
              ),
              const Positioned(
                right: 0,
                top: 0,
                width: 150,
                height: 145,
                child: Photo('promo-breakfast.png', fit: BoxFit.contain),
              ),
              Positioned(
                left: 12,
                right: 80,
                bottom: 50,
                child: Label(
                  title,
                  size: 16,
                  weight: FontWeight.w700,
                  color: copy,
                  maxLines: 2,
                ),
              ),
              Positioned(
                left: 12,
                bottom: 16,
                child: Row(
                  children: [
                    Photo(avatar, width: 26, height: 26),
                    const SizedBox(width: 6),
                    Label(
                      author,
                      size: 12,
                      weight: FontWeight.w500,
                      color: copy,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 16,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Label(
                      'Upto 40% off',
                      size: 8,
                      weight: FontWeight.w500,
                      color: copy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA34D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final curve = Path()
      ..moveTo(-10, 100)
      ..cubicTo(110, 108, 140, 0, 86, 0)
      ..cubicTo(28, 0, 62, 103, 80, 59)
      ..cubicTo(92, 22, 116, 78, 142, 104)
      ..cubicTo(193, 152, 263, 113, 315, 0);
    canvas.drawPath(curve, paint);
    canvas.drawPath(
      Path()
        ..moveTo(235, 190)
        ..cubicTo(180, 116, 268, 102, 299, 151),
      paint,
    );
    canvas.drawCircle(
      const Offset(29, 48),
      6,
      Paint()..color = const Color(0xFFFFF4D2),
    );
  }

  @override
  bool shouldRepaint(_PromoLines oldDelegate) => false;
}

class _Choices extends StatelessWidget {
  const _Choices(
    this.options, {
    required this.selected,
    required this.onChoose,
  });
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChoose;
  @override
  Widget build(BuildContext context) => _Rail(
    height: 48,
    children: [
      for (final option in options)
        HubButton(
          option,
          height: 48,
          outlined: selected != option,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => onChoose(option),
        ),
    ],
  );
}

class _DishCard extends StatelessWidget {
  const _DishCard(this.dish, {this.wide = false});
  final Dish dish;
  final bool wide;

  @override
  Widget build(BuildContext context) => Material(
    color: context.soft,
    shape: RoundedRectangleBorder(
      borderRadius: cardRadius,
      side: BorderSide(color: context.palette.outline),
    ),
    child: InkWell(
      borderRadius: cardRadius,
      onTap: () => context.open(DishPage(dish: dish)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 19, 13, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: cardRadius, child: Photo(dish.image)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: context.paper,
                      shape: const CircleBorder(),
                      child: ActionIcon(
                        Icons.shopping_bag_outlined,
                        'Add ${dish.name}',
                        size: 16,
                        onTap: () {
                          context.hub.changeQuantity(dish, 1);
                          feedback(context, 'Added to cart');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: wide ? 24 : 42,
              child: Label(
                dish.name,
                size: wide ? 16 : 14,
                weight: FontWeight.w500,
                maxLines: wide ? 1 : 2,
              ),
            ),
            _DishMeta(dish, size: wide ? 14 : 12),
            SizedBox(height: wide ? 12 : 6),
            Label(
              money(dish.price),
              size: wide ? 16 : 14,
              weight: FontWeight.w700,
            ),
          ],
        ),
      ),
    ),
  );
}

class _DishMeta extends StatelessWidget {
  const _DishMeta(this.dish, {this.size = 12});
  final Dish dish;
  final double size;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.schedule, size: size, color: context.muted),
      const SizedBox(width: 4),
      Flexible(
        child: Label(
          '${dish.minutes} min',
          size: size,
          color: context.muted,
          maxLines: 1,
        ),
      ),
      const SizedBox(width: 6),
      Label('•', size: size, color: context.palette.outline),
      const SizedBox(width: 6),
      Icon(Icons.star_rounded, size: size + 2, color: gold),
      const SizedBox(width: 4),
      Flexible(
        child: Label(
          '${dish.rating}',
          size: size,
          color: context.muted,
          maxLines: 1,
        ),
      ),
    ],
  );
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard(this.restaurant, {required this.onTap});
  final Restaurant restaurant;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 128,
    child: Material(
      color: context.soft,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: context.palette.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: cardRadius,
                child: Photo(restaurant.image, width: 104, height: 102),
              ),
              const SizedBox(height: 12),
              Label(
                restaurant.name,
                size: 16,
                weight: FontWeight.w500,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: context.muted,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Label(
                      restaurant.street,
                      color: context.muted,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const _Stars(),
            ],
          ),
        ),
      ),
    ),
  );
}

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});
  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final matches = dishes
        .take(4)
        .where((dish) => dish.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return HubPage(
      tab: HubTab.home,
      children: [
        PageTitle(
          'Trending',
          onBell: () => openNotifications(context, HubTab.home),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: pageInset,
          child: SearchBox(
            onChanged: (value) => setState(() => query = value.trim()),
          ),
        ),
        const SizedBox(height: 24),
        _DishGrid(matches),
      ],
    );
  }
}

class _DishGrid extends StatelessWidget {
  const _DishGrid(this.matches);
  final List<Dish> matches;
  @override
  Widget build(BuildContext context) => matches.isEmpty
      ? Padding(
          padding: pageInset,
          child: Label('No matching dishes', color: context.muted),
        )
      : GridView.builder(
          padding: pageInset,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 215,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            mainAxisExtent: 254,
          ),
          itemCount: matches.length,
          itemBuilder: (_, i) => _DishCard(matches[i]),
        );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialCategory = 'Burgers'});
  final String initialCategory;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final field = TextEditingController();
  late String? category = widget.initialCategory;
  String sort = sortOptions.first;
  RangeValues calories = const RangeValues(25, 250);
  List<Dish>? results;

  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  void search() {
    FocusScope.of(context).unfocus();
    final query = field.text.trim().toLowerCase();
    final matches = dishes
        .where(
          (dish) =>
              (category == null || dish.category == category) &&
              dish.calories >= calories.start &&
              dish.calories <= calories.end &&
              dish.name.toLowerCase().contains(query),
        )
        .toList();
    if (sort == sortOptions[1]) {
      matches.sort((a, b) => a.minutes.compareTo(b.minutes));
    } else if (sort == sortOptions[2]) {
      matches.sort((a, b) => b.rating.compareTo(a.rating));
    }
    setState(() => results = matches);
  }

  @override
  Widget build(BuildContext context) => HubPage(
    tab: HubTab.search,
    footer: Row(
      children: [
        Expanded(
          child: HubButton(
            'Clear Filter',
            outlined: true,
            onPressed: () {
              field.clear();
              setState(() {
                category = null;
                sort = sortOptions.first;
                calories = const RangeValues(0, 500);
                results = null;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: HubButton('Apply Filter', onPressed: search)),
      ],
    ),
    children: [
      PageTitle(
        'Search',
        onBell: () => openNotifications(context, HubTab.search),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: pageInset,
        child: SearchBox(controller: field),
      ),
      const SizedBox(height: 24),
      const _SectionTitle('Category'),
      const SizedBox(height: 16),
      _Choices(
        categories,
        selected: category,
        onChoose: (value) =>
            setState(() => category = value == category ? null : value),
      ),
      const SizedBox(height: 24),
      const _SectionTitle('Sort by'),
      const SizedBox(height: 16),
      _Choices(
        sortOptions,
        selected: sort,
        onChoose: (value) => setState(() => sort = value),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: pageInset,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Label('Calories Range', size: 16, weight: FontWeight.w500),
            Label(
              '${calories.start.round()}-${calories.end.round()} Kcal',
              color: context.muted,
            ),
          ],
        ),
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 8,
          activeTrackColor: orange,
          inactiveTrackColor: context.palette.outline,
          thumbColor: orange,
          rangeThumbShape: const RoundRangeSliderThumbShape(
            enabledThumbRadius: 8,
          ),
        ),
        child: RangeSlider(
          min: 0,
          max: 500,
          divisions: 100,
          values: calories,
          labels: RangeLabels(
            '${calories.start.round()} Kcal',
            '${calories.end.round()} Kcal',
          ),
          onChanged: (value) => setState(() => calories = value),
        ),
      ),
      if (results != null) ...[
        const SizedBox(height: 12),
        const _SectionTitle('Results'),
        const SizedBox(height: 12),
        _DishGrid(results!),
      ],
    ],
  );
}

class DishPage extends StatefulWidget {
  const DishPage({super.key, required this.dish, this.initialCount = 1});
  final Dish dish;
  final int initialCount;
  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  late int amount = widget.initialCount;
  bool expanded = false;

  static const _description =
      'Karahi is named after the pan in which it was originally cooked – a heavy, often cast-iron pan that’s similar to a wok, but rounder with a flatter base. Traditionally, meat would be simmered and stir-fried in this karahi in an open fire.\nThe dish originated in the Khyber Pakhtunkhwa province of Pakistan, which is known for its use of meat and black pepper.';

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final feature = dish == dishes.first;
    final ink = context.isDark ? Brightness.light : Brightness.dark;
    return HubScaffold(
      background: orange,
      overlay: SystemUiOverlayStyle(
        statusBarIconBrightness: ink,
        statusBarBrightness: context.isDark
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: ColoredBox(
                color: context.paper,
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: math.max(
                        0,
                        70 - MediaQuery.viewPaddingOf(context).top,
                      ),
                      bottom: 30,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ActionIcon(
                            Icons.arrow_back_ios_new_rounded,
                            'Back',
                            onTap: () => Navigator.maybePop(context),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        clipBehavior: Clip.antiAlias,
                        children: [
                          Positioned(
                            right: 6,
                            top: 56,
                            bottom: 0,
                            width: math.min(
                              MediaQuery.sizeOf(context).width * .65,
                              300,
                            ),
                            child: feature
                                ? const Photo(
                                    'detail-chicken.png',
                                    fit: BoxFit.contain,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipOval(child: Photo(dish.image)),
                                  ),
                          ),
                          Padding(
                            padding: pageInset,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: Label(
                                    feature
                                        ? 'Cheesy cream chicken\nwith extra spice'
                                        : dish.name,
                                    size: 20,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Label(
                                  'By Resto Food Inn',
                                  color: context.muted,
                                ),
                                const SizedBox(height: 34),
                                _Badge(
                                  Icons.star_rounded,
                                  '${dish.rating}',
                                  gold,
                                ),
                                const SizedBox(height: 12),
                                _Badge(
                                  Icons.delivery_dining,
                                  '${dish.minutes} min',
                                  orange,
                                ),
                                const SizedBox(height: 36),
                                SizedBox(
                                  width: 40,
                                  height: 90,
                                  child: Material(
                                    color: const Color(0xFF282A32),
                                    borderRadius: BorderRadius.circular(24),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ActionIcon(
                                            Icons.add,
                                            'Increase quantity',
                                            size: 18,
                                            color: Colors.white,
                                            onTap: () =>
                                                setState(() => amount++),
                                          ),
                                        ),
                                        Expanded(
                                          child: ActionIcon(
                                            Icons.remove,
                                            'Decrease quantity',
                                            size: 18,
                                            color: Colors.white,
                                            onTap: () => setState(
                                              () => amount = math.max(
                                                1,
                                                amount - 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: pageInset,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Label(
                              'Description',
                              size: 16,
                              weight: FontWeight.w500,
                            ),
                            const SizedBox(height: 12),
                            Label(
                              feature
                                  ? _description
                                  : 'Freshly prepared ${dish.name.toLowerCase()} from our local kitchen.',
                              size: 12,
                              color: context.muted,
                              maxLines: expanded ? null : 7,
                            ),
                            if (feature)
                              InkWell(
                                onTap: () =>
                                    setState(() => expanded = !expanded),
                                child: Label(
                                  expanded ? 'Read less' : 'Read more',
                                  size: 12,
                                  color: orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 18, 16, 64),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(child: Label('$amount items', color: Colors.white)),
                  Label(
                    money(dish.price * amount),
                    color: Colors.white,
                    size: 24,
                    weight: FontWeight.w600,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: const Color(0xFF030303),
                        shape: const CircleBorder(),
                        child: ActionIcon(
                          Icons.shopping_bag_outlined,
                          'Add to cart',
                          size: 20,
                          color: Colors.white,
                          onTap: () {
                            context.hub.changeQuantity(dish, amount);
                            feedback(context, 'Added to cart');
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: context.paper,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.palette.outline),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Label(label, size: 10, color: context.muted),
      ],
    ),
  );
}

const _mapMarkers = [
  (.25, .065, 'map-icon3.png', 0),
  (.67, .15, 'map-icon1.png', 1),
  (.45, .39, 'map-center.png', 0),
  (.105, .407, 'map-taco.png', 2),
  (.89, .428, 'map-icon2.png', 1),
  (.265, .705, 'map-burger.png', 3),
  (.71, .825, 'map-icon4.png', 2),
];

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key, this.initialSelection});
  final Restaurant? initialSelection;
  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  late Restaurant? selection = widget.initialSelection;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final map = context.isDark ? 'map-dark.jpeg' : 'map-light.jpeg';
    final selected = selection;
    if (selected != null) {
      return HubScaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    bottom: 186,
                    child: _map(map, selected: selected),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: context.paper,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Semantics(
                                button: true,
                                label: 'Close restaurant',
                                child: InkWell(
                                  borderRadius: cardRadius,
                                  onTap: () => setState(() => selection = null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      width: 54,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: context.palette.outline,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const _Stars(),
                                          const SizedBox(width: 6),
                                          Label('(245)', color: context.muted),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Label(
                                        selected.name,
                                        size: 21,
                                        weight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ClipRRect(
                                  borderRadius: cardRadius,
                                  child: Photo(
                                    selected.image,
                                    width: 64,
                                    height: 64,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                _PlaceTag(
                                  Icons.grid_view_outlined,
                                  'Category | ${selected.category}',
                                ),
                                _PlaceTag(
                                  Icons.location_on_outlined,
                                  'Distance | ${selected.distance}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const HubNav(active: HubTab.nearby),
          ],
        ),
      );
    }
    return HubPage(
      tab: HubTab.nearby,
      children: [
        PageTitle(
          'Restaurant near me',
          onBell: () => openNotifications(context, HubTab.nearby),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: pageInset,
          child: SearchBox(
            hint: 'Search for nearby restaurant',
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
          ),
        ),
        const SizedBox(height: 24),
        if (query.isNotEmpty)
          Padding(
            padding: pageInset,
            child: Column(
              children: [
                for (final place in restaurants.where(
                  (r) => r.name.toLowerCase().contains(query),
                )) ...[
                  ChoiceRow(
                    place.name,
                    detail: place.distance,
                    onTap: () => setState(() => selection = place),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!restaurants.any(
                  (r) => r.name.toLowerCase().contains(query),
                ))
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Label('No matching restaurants'),
                  ),
              ],
            ),
          ),
        Padding(
          padding: pageInset,
          child: SizedBox(height: 565, child: _map(map)),
        ),
      ],
    );
  }

  Widget _map(String file, {Restaurant? selected}) => LayoutBuilder(
    builder: (context, bounds) => Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(child: Photo(file, fit: BoxFit.fill)),
        for (final (index, (x, y, image, place)) in _mapMarkers.indexed)
          Positioned(
            left: x * bounds.maxWidth - 22,
            top: y * bounds.maxHeight - 22,
            child: Material(
              color: selected == restaurants[place]
                  ? orange
                  : const Color(0xFFFFF8EF),
              elevation: index == 2 ? 3 : 0,
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 3),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => selection = restaurants[place]),
                child: Tooltip(
                  message: restaurants[place].name,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Photo(
                      image,
                      fit: BoxFit.contain,
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _PlaceTag extends StatelessWidget {
  const _PlaceTag(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: orange),
      const SizedBox(width: 4),
      Label(text, size: 12, color: context.muted),
    ],
  );
}

class _Stars extends StatelessWidget {
  const _Stars();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.filled(
      3,
      const Padding(
        padding: EdgeInsets.only(right: 3),
        child: Icon(Icons.star_rounded, color: gold, size: 16),
      ),
    ),
  );
}

const _deliveries = [
  ('Creamy Chicken', 'chicken.jpeg', false),
  ('Pasta', 'notify-pasta.png', true),
  ('Bread Chicken Rolls', 'notify-roll.png', false),
  ('Pizza', 'notify-pizza.png', true),
  ('Biryani', 'biryani.jpeg', true),
];

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, this.tab = HubTab.home});
  final HubTab tab;
  @override
  Widget build(BuildContext context) => HubPage(
    tab: tab,
    children: [
      LocationHeader(onBell: () => Navigator.maybePop(context)),
      const SizedBox(height: 24),
      Padding(
        padding: pageInset,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NoticeHeading('News & Updates', 2),
            const SizedBox(height: 12),
            for (var i = 0; i < 2; i++) ...[
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: orange),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 18,
                      color: orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Label(
                      'Earn 80 Points And Get 20% Off Under \$80 Items.',
                      size: 12,
                      color: context.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            _NoticeHeading('Delivery', 5 + context.hub.ordersPlaced),
            const SizedBox(height: 12),
            if (context.hub.ordersPlaced > 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Label('Your demo order is on the way.', color: orange),
              ),
            for (final (title, image, delivered) in _deliveries) ...[
              Row(
                children: [
                  ClipOval(child: Photo(image, width: 36, height: 36)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Label(title, size: 12, color: context.muted),
                      Label(
                        delivered ? 'Delivered' : 'On the way...',
                        italic: true,
                        size: 10,
                        color: delivered ? orange : context.muted,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    ],
  );
}

class _NoticeHeading extends StatelessWidget {
  const _NoticeHeading(this.text, this.count);
  final String text;
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Label(text, size: 16, weight: FontWeight.w500),
      const SizedBox(width: 12),
      const Expanded(child: Divider()),
      const SizedBox(width: 12),
      CircleAvatar(
        radius: 10,
        backgroundColor: orange,
        child: Label('$count', size: 10, color: Colors.white),
      ),
    ],
  );
}
