import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _cartRef(String userId) =>
      _firestore.collection('carts').doc(userId).collection('items');

  // STREAM CART IN REAL-TIME
  Stream<List<CartItem>> streamCart(String userId) {
    return _cartRef(userId).snapshots().map(
          (snap) => snap.docs
              .map((doc) =>
                  CartItem.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // ADD TO CART WITH QUANTITY MERGE LOGIC
  Future<void> addToCart(String userId, CartItem item) async {
    final docRef = _cartRef(userId).doc(item.productId);
    final doc = await docRef.get();

    if (doc.exists) {
      final existing = doc.data() as Map<String, dynamic>;
      final newQty = (existing['quantity'] ?? 0) + item.quantity;

      await docRef.update({
        'quantity': newQty,
        'price': item.price,
        'name': item.name,
        'thumbnail': item.thumbnail,
      });
    } else {
      await docRef.set(item.toMap());
    }
  }

  // UPDATE QUANTITY (REMOVE IF ZERO)
  Future<void> updateQuantity(
      String userId, String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(userId, productId);
      return;
    }
    await _cartRef(userId).doc(productId).update({'quantity': quantity});
  }

  // REMOVE ITEM
  Future<void> removeFromCart(String userId, String productId) async {
    await _cartRef(userId).doc(productId).delete();
  }

  // CLEAR WHOLE CART
  Future<void> clearCart(String userId) async {
    final snap = await _cartRef(userId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
