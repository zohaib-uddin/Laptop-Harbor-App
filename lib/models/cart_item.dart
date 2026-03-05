class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? thumbnail;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.thumbnail,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'thumbnail': thumbnail,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      thumbnail: map['thumbnail'],
    );
  }
}


