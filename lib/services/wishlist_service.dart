import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _wishlistRef(String userId) =>
      _firestore.collection('wishlists').doc(userId).collection('items');

  Stream<List<String>> streamWishlistProductIds(String userId) {
    return _wishlistRef(userId).snapshots().map(
          (snap) => snap.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['productId']
                  as String)
              .toList(),
        );
  }

  Future<void> addToWishlist(String userId, String productId) async {
    await _wishlistRef(userId).doc(productId).set({'productId': productId});
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _wishlistRef(userId).doc(productId).delete();
  }

    // ✅ New method: Get list of product IDs in user's wishlist
  Future<List<String>> getWishlistProductIds(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

}

  
