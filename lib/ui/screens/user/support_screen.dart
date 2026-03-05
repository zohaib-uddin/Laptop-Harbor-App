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

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _subjectController.dispose();
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
  // -------------------------------------------------------

  Future<void> _sendTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance.collection("supportTickets").add({
        "userId": user.uid,
        "email": user.email ?? "",
        "subject": _subjectController.text.trim(),
        "message": _messageController.text.trim(),
        "status": "open",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Clear inputs
      _subjectController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your support request has been submitted!"),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send request. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------- APP BAR ----------------------
      appBar: AppBar(
        title: const Text("Customer Support",
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

      // ---------------------- BODY ----------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- TITLE ----------
              const Text(
                "Need Help?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),
              Text(
                "If you're facing an issue with your order or need support, simply submit a ticket below and our team will assist you shortly.",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 20),

              // ------------ SUBJECT FIELD -------------
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: "Subject",
                  prefixIcon: const Icon(LineIcons.exclamationCircle),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Subject is required";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ------------ MESSAGE FIELD -------------
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: "Describe your issue",
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(LineIcons.commentDots),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Message is required";
                  if (value.trim().length < 10) return "Message must be at least 10 characters";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ------------ BUTTON -------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendTicket,
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Submit Ticket", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
