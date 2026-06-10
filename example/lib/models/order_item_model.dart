import 'product_model.dart';

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'quantity': quantity,
        'subtotal': subtotal,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        emoji: '',
      ),
      quantity: json['quantity'] as int,
    );
  }
}
