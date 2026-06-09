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
    Product(id: 1, name: 'Cà phê sữa', price: 35000, emoji: '☕'),
    Product(id: 2, name: 'Bạc xỉu', price: 30000, emoji: '🥛'),
    Product(id: 3, name: 'Trà sữa', price: 40000, emoji: '🧋'),
    Product(id: 4, name: 'Sinh tố xoài', price: 45000, emoji: '🥭'),
    Product(id: 5, name: 'Nước cam', price: 25000, emoji: '🍊'),
    Product(id: 6, name: 'Cà phê đen', price: 25000, emoji: '🖤'),
    Product(id: 7, name: 'Bánh mì', price: 20000, emoji: '🥖'),
    Product(id: 8, name: 'Bánh croissant', price: 30000, emoji: '🥐'),
    Product(id: 9, name: 'Matcha latte', price: 50000, emoji: '🍵'),
  ];
}
