import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptopharbor/ui/screens/user/cart_screen.dart';
import 'package:laptopharbor/ui/screens/user/wishlist_screen.dart';
import 'package:laptopharbor/ui/screens/user/orders_list_screen.dart';
import 'package:laptopharbor/ui/screens/user/support_screen.dart';
import 'package:laptopharbor/ui/widgets/custom_bottom_navbar.dart';
import 'package:line_icons/line_icons.dart';

import '../../../models/app_user.dart';
import '../../screens/auth/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _saving = false;
  String? _imageBase64;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
  _imageBase64 = widget.user.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
  setState(() => _saving = true);

  try {
    // Prepare map to update
    Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    // Include image if selected
    if (_imageBase64 != null) {
      updatedData['imageUrl'] = _imageBase64;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update(updatedData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );

    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;
    print("Error updating profile: $e"); // for debug
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update profile')),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(onPressed: _goToWishlist, icon: const Icon(LineIcons.heart)),
          IconButton(onPressed: _goToCart, icon: const Icon(LineIcons.shoppingCart)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageBase64 != null
                    ? MemoryImage(base64Decode(_imageBase64!))
                    : null,
                child: _imageBase64 == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickImage,
              child: const Text("Choose Image"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),
    );
  }
}
