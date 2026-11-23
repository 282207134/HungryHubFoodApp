class Dish {
  const Dish(
    this.name,
    this.image,
    this.category,
    this.calories, {
    this.price = 1499,
    this.minutes = 24,
    this.rating = 4.8,
  });

  final String name, image, category;
  final int calories, price, minutes;
  final double rating;
}

const dishes = [
  Dish('Cheesy cream chicken', 'chicken.jpeg', 'Chicken', 250),
  Dish('Famous Karachi biryani', 'biryani.jpeg', 'Rice', 240),
  Dish('The full extreme Chargha', 'chargha.jpeg', 'Chicken', 350),
  Dish('Zinger crunchy burger', 'burger.jpeg', 'Burgers', 210),
  Dish('Creamy pasta', 'notify-pasta.png', 'Spaghetti', 235, minutes: 22),
  Dish('Cheese pizza', 'notify-pizza.png', 'Pizza', 245, minutes: 21),
];

const categories = ['Burgers', 'Pizza', 'Spaghetti', 'Cake'];
const sortOptions = ['Recommend', 'Fast delivery', 'Most wanting'];
const paymentMethods = ['Credit Card', 'PayPal', 'Google Pay'];

class Restaurant {
  const Restaurant(
    this.name,
    this.image,
    this.street,
    this.category,
    this.distance,
  );

  final String name, image, street, category, distance;
}

const restaurants = [
  Restaurant(
    'Food Inn',
    'food-inn.jpeg',
    'St.4435 mar rd.',
    'Chicken',
    '0.6 km',
  ),
  Restaurant(
    'High Five',
    'high-five.jpeg',
    'St.4435 mar rd.',
    'Pizza',
    '0.9 km',
  ),
  Restaurant('Kolachi', 'kolachi.jpeg', 'St.4435 mar rd.', 'Rice', '1.2 km'),
  Restaurant(
    'Fast Food Strings & Burgers',
    'food-inn.jpeg',
    'St.4435 mar rd.',
    'Burgers',
    '1.4 km',
  ),
];

const addresses = {
  'Home': 'Horizonal Road Street 1178 California, USA',
  'Office': 'Parallel Road Street 897 California, USA',
};

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
