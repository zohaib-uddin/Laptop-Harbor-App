import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService;
  final String productId;

  ReviewProvider(this._reviewService, this.productId) {
    _listenToReviews();
  }

  final List<Review> _reviews = [];
  List<Review> get reviews => List.unmodifiable(_reviews);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<List<Review>>? _subscription;

  void _listenToReviews() {
    _subscription = _reviewService
        .streamReviewsForProduct(productId)
        .listen((list) {
      _reviews
        ..clear()
        ..addAll(list);
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addReview({
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    await _reviewService.addReview(
      productId: productId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
    );
    // stream khud hi updated list de dega, yahan manual notify ki zarurat nahi
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
