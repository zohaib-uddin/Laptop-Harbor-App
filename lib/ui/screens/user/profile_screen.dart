import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/user/cart_screen.dart';
import 'package:laptopharbor/ui/screens/user/orders_list_screen.dart';
import 'package:laptopharbor/ui/screens/user/support_screen.dart';
import 'package:laptopharbor/ui/screens/user/wishlist_screen.dart';
import 'package:line_icons/line_icons.dart';

import '../../screens/auth/login_screen.dart';
import '../../../models/app_user.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../../widgets/custom_bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<AppUser?> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return AppUser.fromMap(doc.data()!, doc.id);
  }

  // ---------------------- NAVIGATION ----------------------
  void _goToCart() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _goToWishlist() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
  }

  void _goToOrders() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const OrdersListScreen()));
  }

  void _goToSupportTickets() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SupportScreen()),
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

  void _goToEditProfile(AppUser user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: user),
      ),
    );
    // Refresh screen after returning from edit
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile",
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
      body: FutureBuilder<AppUser?>(
        future: _loadUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text("No user data found"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user.imageUrl != null
                        ? MemoryImage(base64Decode(user.imageUrl!))
                        : null,
                    child: user.imageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(user.phone),
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _goToEditProfile(user),
              ),

              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),
    );
  }
}
