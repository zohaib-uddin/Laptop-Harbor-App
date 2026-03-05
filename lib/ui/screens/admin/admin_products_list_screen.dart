// lib/ui/screens/admin/admin_products_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/product.dart';
import '../../widgets/admin_product_card.dart';
import 'admin_add_edit_product_screen.dart';
import 'admin_drawer.dart';

class AdminProductsListScreen extends StatefulWidget {
  const AdminProductsListScreen({super.key});

  @override
  State<AdminProductsListScreen> createState() =>
      _AdminProductsListScreenState();
}

class _AdminProductsListScreenState extends State<AdminProductsListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream to fetch products
  Stream<List<Product>> _streamProducts() {
    return _firestore.collection('products').snapshots().map((snap) {
      return snap.docs.map((doc) => Product.fromDoc(doc)).toList();
    });
  }

  void _goToEditProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminEditProductScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(), // <-- same as orders screen
      appBar: AppBar(
        title: const Text('All Products'),
        // backgroundColor: Colors.blue,
        // foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Stream updates automatically
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return AdminProductCard(
                  product: product,
                  onEdit: () => _goToEditProduct(product),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminEditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
