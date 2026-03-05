import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';

import '../../../models/order.dart';
import '../user/cart_screen.dart';
import '../user/wishlist_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/profile_screen.dart';
import '../../screens/auth/login_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  // ---------------- NAVIGATION HELPERS ----------------
  void _goToCart(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _goToWishlist(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
  }

  void _goToOrders(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const OrdersListScreen()));
  }

  void _goToProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
  // ---------------------------------------------------

  final double shippingFee = 200;
  final double taxRate = 0.05; // 5% GST

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * taxRate;
    final total = subtotal + tax + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
              onPressed: () => _goToWishlist(context),
              icon: const Icon(LineIcons.heart)),
          IconButton(
              onPressed: () => _goToCart(context),
              icon: const Icon(LineIcons.shoppingCart)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'orders') _goToOrders(context);
              if (value == 'profile') _goToProfile(context);
              if (value == 'logout') _logout(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- ORDER STATUS ----------
            const Text('Order Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _statusStepper(order.status),
            const SizedBox(height: 16),

            // ---------- ITEMS ----------
            const Text('Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Image.network(
                    item.thumbnail != null && item.thumbnail!.isNotEmpty
                        ? item.thumbnail!
                        : 'https://via.placeholder.com/50',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                      '${item.price.toStringAsFixed(0)} RS x ${item.quantity}'),
                  trailing:
                      Text((item.price * item.quantity).toStringAsFixed(0)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- SHIPPING INFO ----------
            const Text('Shipping Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Name: ${order.fullName}'),
            Text('Phone: ${order.phone}'),
            Text('Address: ${order.address}'),
            Text('City: ${order.city}'),
            const SizedBox(height: 12),

            // ---------- BILLING INFO ----------
            const Text('Billing Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Billing Name: ${order.billingName}'),
            Text('Billing Address: ${order.billingAddress}'),
            const SizedBox(height: 12),

            // ---------- PAYMENT ----------
            Text('Payment Method: ${order.paymentMethod}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // ---------- SUMMARY ----------
            const Text('Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _summaryRow('Subtotal', '${subtotal.toStringAsFixed(0)} RS'),
            _summaryRow('Tax (5%)', '${tax.toStringAsFixed(0)} RS'),
            _summaryRow('Shipping Fee', '$shippingFee RS'),
            const Divider(),
            _summaryRow('Total', '${total.toStringAsFixed(0)} RS',
                isBold: true, fontSize: 18),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _summaryRow(String title, String value,
      {bool isBold = false, double fontSize = 15}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _statusStepper(String currentStatus) {
    final statuses = ['cancelled', 'pending', 'shipped', 'delivered',];

     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isCurrent = status == currentStatus;
        return Column(
          children: [
            CircleAvatar(
              radius: 14,
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
