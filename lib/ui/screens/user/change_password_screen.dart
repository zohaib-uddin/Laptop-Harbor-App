import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';

import '../user/cart_screen.dart';
import '../user/wishlist_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/support_screen.dart';
import '../../screens/auth/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ---------------------- NAVIGATION ----------------------
  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _goToWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  void _goToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersListScreen()),
    );
  }

  void _goToSupportTickets() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SupportScreen()),
    );
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

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged in user')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await user.updatePassword(_newController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update password'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------- APP BAR ----------------------
      appBar: AppBar(
        title: const Text("Change Password",
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
              if (value == 'orders') _goToOrders();
              if (value == 'tickets') _goToSupportTickets();
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'orders',
                child: Row(
                  children: [
                    Icon(LineIcons.shoppingBag,
                        size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('My Orders'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tickets',
                child: Row(
                  children: [
                    Icon(LineIcons.headset,
                        size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Support Tickets'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LineIcons.alternateSignOut,
                        size: 20, color: Colors.black54),
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newController,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'New password is required';
                  }
                  if (value.length < 6) {
                    return 'At least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _changePassword,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change password'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),

    );
  }
}
