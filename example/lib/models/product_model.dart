class Product {
  final int id;
  final String name;
  final int price;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });

  static const List<Product> catalog = [
    Product(id: 1, name: 'Milk Coffee', price: 35000, emoji: '☕'),
    Product(id: 2, name: 'White Coffee', price: 30000, emoji: '🥛'),
    Product(id: 3, name: 'Milk Tea', price: 40000, emoji: '🧋'),
    Product(id: 4, name: 'Mango Smoothie', price: 45000, emoji: '🥭'),
    Product(id: 5, name: 'Orange Juice', price: 25000, emoji: '🍊'),
    Product(id: 6, name: 'Black Coffee', price: 25000, emoji: '🖤'),
    Product(id: 7, name: 'Baguette', price: 20000, emoji: '🥖'),
    Product(id: 8, name: 'Croissant', price: 30000, emoji: '🥐'),
    Product(id: 9, name: 'Matcha Latte', price: 50000, emoji: '🍵'),
  ];
}
