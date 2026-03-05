import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String brandId;
  final List<String> imageUrls;
  final double rating;
  final int ratingCount;
  final int stock;
  final DateTime? creationDate;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.brandId,
    required this.imageUrls,
    required this.rating,
    required this.ratingCount,
    required this.stock,
    this.creationDate,
  });

  /// Create a Product instance from Firestore document
  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      brandId: data['brandId'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      stock: data['stock'] ?? 0,
      creationDate: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Product instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'brandId': brandId,
      'imageUrls': imageUrls,
      'rating': rating,
      'ratingCount': ratingCount,
      'stock': stock,
      'createdAt': creationDate != null ? Timestamp.fromDate(creationDate!) : FieldValue.serverTimestamp(),
    };
  }
}
