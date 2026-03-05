import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _firestore.collection('productReviews');

  /// specific product ke reviews stream (live updates)
  Stream<List<Review>> streamReviewsForProduct(String productId) {
    return _reviewsRef
        .where('productId', isEqualTo: productId)
        // .orderBy('createdAt', descending: true)  // 👈 ye hata diya
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Review.fromDoc(doc))
              .toList(),
        );
  }

  /// simple: sirf review save karo
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    await _reviewsRef.add({
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
  