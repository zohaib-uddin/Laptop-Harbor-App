import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import '../user/cart_screen.dart';
import '../user/wishlist_screen.dart';
import '../user/orders_list_screen.dart';
import '../user/profile_screen.dart';
import '../../screens/auth/login_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ---------------------- NAVIGATION ----------------------
  void _goToCart() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _goToWishlist() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
  }

  void _goToOrders() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersListScreen()));
  }

  void _goToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
  // ---------------------------------------------------------

  // ---------------------- SEND CONTACT REQUEST ----------------------
  Future<void> _sendContact() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first to continue")),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      // Save in Firestore
      await FirebaseFirestore.instance.collection("contact").add({
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "message": _messageController.text.trim(),
        "userId": user.uid,
        "email": user.email ?? "",
        "status": "open",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Clear Form after successful send
      _nameController.clear();
      _phoneController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your message has been sent successfully!"),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send message. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us",
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
              if (value == "orders") _goToOrders();
              if (value == "profile") _goToProfile();
              if (value == "logout") _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "orders",
                child: Row(
                  children: [
                    Icon(LineIcons.shoppingBag, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("My Orders"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "profile",
                child: Row(
                  children: [
                    Icon(LineIcons.user, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(LineIcons.alternateSignOut, size: 20, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Get in Touch",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),
              Text(
                "Have a question or need help? Send us a message and our support team will respond shortly.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),

              // ------------ NAME ----------------
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  prefixIcon: const Icon(LineIcons.user),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Name is required";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // ------------ PHONE ----------------
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(LineIcons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Phone number is required";
                  if (value.length < 10) return "Enter a valid phone number";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // ------------ MESSAGE ----------------
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Message",
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(LineIcons.commentDots),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Message is required";
                  if (value.trim().length < 10) return "Message should be at least 10 characters";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendContact,
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Send Message',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
