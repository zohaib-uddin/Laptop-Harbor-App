import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';


class CartProvider extends ChangeNotifier {
  final CartService _cartService;
  final String userId;

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  CartProvider(this._cartService, this.userId) {
    _cartService.streamCart(userId).listen((list) {
      _items = list;
      notifyListeners();
    });
  }

  double get total =>
      _items.fold(0, (sum, item) => sum + item.total);

  Future<void> addItem(CartItem item) async {
    await _cartService.addToCart(userId, item);
    notifyListeners(); // <-- Added
  }

  Future<void> removeItem(String productId) async {
    await _cartService.removeFromCart(userId, productId);
    notifyListeners(); // <-- Added
  }

  Future<void> clear() async {
    await _cartService.clearCart(userId);
    notifyListeners(); // <-- Added
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _cartService.updateQuantity(userId, productId, quantity);
    notifyListeners(); // <-- Added
  }
}
