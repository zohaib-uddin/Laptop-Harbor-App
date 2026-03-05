import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:provider/provider.dart';

import '../../../models/product.dart';
import '../../../models/cart_item.dart';
import '../../../services/product_service.dart';
import '../../../services/wishlist_service.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../user/cart_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/profile_screen.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final ProductService _productService = ProductService();

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  void _goToCart() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _goToOrders() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersListScreen()));
  }

  void _goToProfile() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String? _extractImageUrl(Product p) {
    try {
      final dyn = p as dynamic;
      final img = dyn.imageUrl ?? dyn.image ?? (dyn.imageUrls.isNotEmpty ? dyn.imageUrls.first : null);
      if (img == null) return null;
      return img is String ? img : img.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LineIcons.heart),
          ),
          IconButton(
            onPressed: _goToCart,
            icon: const Icon(LineIcons.shoppingCart),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'orders') _goToOrders();
              if (value == 'profile') _goToProfile();
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(LineIcons.shoppingBag, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('My Orders'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(LineIcons.user, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LineIcons.alternateSignOut, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _wishlistService.streamWishlistProductIds(_userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final wishlistIds = snapshot.data ?? [];
          if (wishlistIds.isEmpty) {
            return const Center(child: Text('Your wishlist is empty'));
          }

          return FutureBuilder<List<Product>>(
            future: _productService.getProductsOnce(),
            builder: (context, snapProducts) {
              if (!snapProducts.hasData) {
                if (snapProducts.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
              }

              final allProducts = snapProducts.data ?? [];
              final wishlistProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();

              if (wishlistProducts.isEmpty) {
                return const Center(child: Text('No products found in wishlist'));
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: wishlistProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68, // Card height same as ProductListScreen
                  ),
                  itemBuilder: (context, index) {
                    final p = wishlistProducts[index];
                    final imageUrl = _extractImageUrl(p);

                    return ProductCard(
                      product: p,
                      isInWishlist: true, // ❤️ red for wishlist
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: p),
                          ),
                        );
                      },
                      onAddToCart: () async {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        final cartItem = CartItem(
                          productId: p.id,
                          name: p.name,
                          price: p.price,
                          quantity: 1,
                          thumbnail: imageUrl,
                        );
                        await cartProvider.addItem(cartItem);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${p.name} added to cart"), duration: const Duration(seconds: 1)),
                        );
                      },
                      onToggleWishlist: () {
                        _wishlistService.removeFromWishlist(_userId, p.id);
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
