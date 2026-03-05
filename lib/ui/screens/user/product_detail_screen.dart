import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/user/checkout_screen.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';

import '../../../models/cart_item.dart';
import '../../../models/product.dart';
import '../../../models/review.dart';
import '../../../services/cart_service.dart';
import '../../../services/wishlist_service.dart';
import '../../../services/review_service.dart';
import '../../widgets/rating_stars.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  final ReviewService _reviewService = ReviewService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInWishlist = false;
  bool _loadingWishlist = true;

  String? _categoryName;
  String? _brandName;
  bool _loadingMeta = true;

  final _reviewController = TextEditingController();
  int _selectedRating = 5;
  bool _submittingReview = false;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initWishlistState();
    _loadCategoryBrandNames();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }


void _buyNow() {
  final item = CartItem(
    productId: widget.product.id,
    name: widget.product.name,
    price: widget.product.price,
    quantity: 1,
    thumbnail: widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls.first
        : null,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CheckoutScreen(
        items: [item],   // 🔥 1 single item only
        total: widget.product.price,  // 🔥 direct total
      ),
    ),
  );
}




  Future<void> _initWishlistState() async {
    _wishlistService.streamWishlistProductIds(_userId).listen((ids) {
      if (!mounted) return;
      setState(() {
        _isInWishlist = ids.contains(widget.product.id);
        _loadingWishlist = false;
      });
    });
  }

  Future<void> _loadCategoryBrandNames() async {
    String? catName;
    String? brName;

    try {
      if (widget.product.categoryId.isNotEmpty) {
        final catDoc = await _firestore
            .collection('categories')
            .doc(widget.product.categoryId)
            .get();
        if (catDoc.exists) {
          catName = (catDoc.data() ?? {})['name'] as String?;
        }
      }

      if (widget.product.brandId.isNotEmpty) {
        final brDoc = await _firestore
            .collection('brands')
            .doc(widget.product.brandId)
            .get();
        if (brDoc.exists) {
          brName = (brDoc.data() ?? {})['name'] as String?;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _categoryName = catName;
      _brandName = brName;
      _loadingMeta = false;
    });
  }

  Future<void> _addToCart() async {
    final cartItem = CartItem(
      productId: widget.product.id,
      name: widget.product.name,
      price: widget.product.price,
      quantity: 1,
      thumbnail: widget.product.imageUrls.isNotEmpty
          ? widget.product.imageUrls.first
          : null,
    );
    await _cartService.addToCart(_userId, cartItem);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  Future<void> _toggleWishlist() async {
    if (_isInWishlist) {
      await _wishlistService.removeFromWishlist(
        _userId,
        widget.product.id,
      );
    } else {
      await _wishlistService.addToWishlist(
        _userId,
        widget.product.id,
      );
    }
  }

  /// ⭐⭐⭐ This is the updated function
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review comment')),
      );
      return;
    }

    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in')),
      );
      return;
    }

    setState(() => _submittingReview = true);

    try {
      // ⭐ User name Firestore ke users collection se fetch karna
      String userName = "";

      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists && userDoc.data()!.containsKey('name')) {
        userName = userDoc['name'] ?? "";
      }

      // Safety: name empty hua to bhi "" jayega (no email, no "User")
      await _reviewService.addReview(
        productId: widget.product.id,
        userId: _userId,
        userName: userName,
        rating: _selectedRating.toDouble(),
        comment: _reviewController.text.trim(),
      );

      _reviewController.clear();
      setState(() {
        _selectedRating = 5;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingReview = false);
      }
    }
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _selectedRating;
        return IconButton(
          onPressed: () {
            setState(() {
              _selectedRating = starIndex;
            });
          },
          icon: Icon(
            Icons.star,
            color: isSelected ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.streamReviewsForProduct(widget.product.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Error loading reviews: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reviews = snapshot.data ?? [];

        // ⭐ rating count update
        _firestore
            .collection('products')
            .doc(widget.product.id)
            .update({'ratingCount': reviews.length});

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No reviews yet.'),
          );
        }

        return Column(
          children: reviews.map((r) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(r.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingStars(rating: r.rating),
                        const SizedBox(width: 8),
                        Text(r.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.comment),
                    const SizedBox(height: 4),
                    Text(
                      r.createdAt.toLocal().toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imageUrl = p.imageUrls.isNotEmpty ? p.imageUrls.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        actions: [
          IconButton(
            onPressed: _loadingWishlist ? null : _toggleWishlist,
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? Colors.red : null,
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(child: Icon(Icons.laptop, size: 64)),
            ),

          const SizedBox(height: 16),
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              RatingStars(rating: p.rating),
              const SizedBox(width: 8),
              Text('(${p.ratingCount} reviews)'),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            '${p.price.toStringAsFixed(0)} RS',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Category / Brand
          if (!_loadingMeta &&
              (_categoryName != null || _brandName != null))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_categoryName != null)
                  Text('Category: $_categoryName'),
                if (_brandName != null) Text('Brand: $_brandName'),
                const SizedBox(height: 12),
              ],
            ),

          Text(p.description),
          const SizedBox(height: 16),

          Text('Stock: ${p.stock}'),
          const SizedBox(height: 16),

          const Divider(),

          const Text(
            'Write a review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          _buildRatingSelector(),

          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Your review',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submittingReview ? null : _submitReview,
              child: _submittingReview
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit review'),
            ),
          ),

          const Divider(),

          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),
          _buildReviewsList(),
          const SizedBox(height: 80),
        ],
      ),

      bottomNavigationBar: SafeArea(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ADD TO CART
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to cart'),
              ),
            ),

            const SizedBox(width: 12),

            // BUY NOW ⭐⭐
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 206, 248, 20),
                ),
                onPressed: _buyNow,
                icon: const Icon(Icons.flash_on),
                label: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),

      const CustomBottomNavBar(currentIndex: 1),
    ],
  ),
),

      
    );
  }
}
