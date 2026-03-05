import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/auth/login_screen.dart';
import 'package:laptopharbor/ui/screens/user/cart_screen.dart';
import 'package:laptopharbor/ui/screens/user/profile_screen.dart';
import 'package:laptopharbor/ui/screens/user/wishlist_screen.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';

import '../../../models/order.dart' as app_model;
import '../../../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final OrderService _orderService = OrderService();
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // ----------- Navigation Methods -------------
  void _goToCart() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));

  void _goToWishlist() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));

  void _goToProfile() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));

  void _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
  // --------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Orders",
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
            onPressed: _goToCart,
            icon: const Icon(LineIcons.shoppingCart),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') _goToProfile();
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
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
      body: StreamBuilder<List<app_model.Order>>(
        stream: _orderService.streamUserOrders(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 6)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order.createdAt != null
                                  ? order.createdAt.toLocal().toString().split(' ')[0]
                                  : '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Status Stepper
                        _statusStepper(order.status),
                        const SizedBox(height: 8),

                        // Total
                        Text(
                          'Total: ${order.totalAmount.toStringAsFixed(0)} RS',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _statusStepper(String currentStatus) {
    final statuses = ['cancelled', 'pending', 'shipped', 'delivered'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isCurrent = status == currentStatus;
        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCurrent ? Colors.yellow : Colors.grey[300],
              child: Text(
                status[0].toUpperCase(),
                style: TextStyle(
                    color: isCurrent ? Colors.black : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.orange[800] : Colors.black),
            ),
          ],
        );
      }).toList(),
    );
  }
}
