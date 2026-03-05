import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';

import '../../../models/cart_item.dart';
import '../../../services/cart_service.dart';
import '../../widgets/cart_item_tile.dart';
import '../user/wishlist_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/profile_screen.dart';
import '../auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ---------------------- NAVIGATION ----------------------
  void _goToWishlist() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
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
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------- APP BAR ----------------------
      appBar: AppBar(
        title: const Text("Cart",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _goToWishlist,
            icon: const Icon(LineIcons.heart),
          ),
          IconButton(
            onPressed: () {},
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
      // -----------------------------------------------------

      body: StreamBuilder<List<CartItem>>(
        stream: _cartService.streamCart(_userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text("Your cart is empty"),
            );
          }

          final total = items.fold<double>(
            0,
            (sum, item) => sum + item.total,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemTile(
                      item: item,
                      onRemove: () => _cartService.removeFromCart(
                        _userId,
                        item.productId,
                      ),
                      onQuantityChanged: (q) =>
                          _cartService.updateQuantity(
                        _userId,
                        item.productId,
                        q,
                      ),
                    );
                  },
                ),
              ),

              // BOTTOM TOTAL + CHECKOUT
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: ${total.toStringAsFixed(0)} RS",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(
                              items: items,
                              total: total,
                            ),
                          ),
                        );
                      },
                      child: const Text("Proceed to checkout"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
