import 'package:flutter/foundation.dart';

import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService;
  final String userId;

  List<String> _productIds = [];
  List<String> get productIds => _productIds;

  WishlistProvider(this._wishlistService, this.userId) {
    _wishlistService.streamWishlistProductIds(userId).listen((ids) {
      _productIds = ids;
      notifyListeners();
    });
  }

  bool isInWishlist(String productId) =>
      _productIds.contains(productId);

  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      await _wishlistService.removeFromWishlist(userId, productId);
    } else {
      await _wishlistService.addToWishlist(userId, productId);
    }
  }
}
