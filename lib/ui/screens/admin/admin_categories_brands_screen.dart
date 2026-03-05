import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_drawer.dart';

class AdminCategoriesBrandsScreen extends StatefulWidget {
  const AdminCategoriesBrandsScreen({super.key});

  @override
  State<AdminCategoriesBrandsScreen> createState() =>
      _AdminCategoriesBrandsScreenState();
}

class _AdminCategoriesBrandsScreenState
    extends State<AdminCategoriesBrandsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();

  bool _addingCategory = false;
  bool _addingBrand = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get _brandsRef =>
      _firestore.collection('brands');

  Future<void> _addCategory() async {
    if (_categoryController.text.trim().isEmpty) return;

    setState(() => _addingCategory = true);
    try {
      await _categoriesRef.add({
        'name': _categoryController.text.trim(),
      });
      _categoryController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add category')),
      );
    } finally {
      if (mounted) setState(() => _addingCategory = false);
    }
  }

  Future<void> _addBrand() async {
    if (_brandController.text.trim().isEmpty) return;

    setState(() => _addingBrand = true);
    try {
      await _brandsRef.add({
        'name': _brandController.text.trim(),
      });
      _brandController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add brand')),
      );
    } finally {
      if (mounted) setState(() => _addingBrand = false);
    }
  }

  Future<void> _editItem({
    required String id,
    required String oldName,
    required CollectionReference<Map<String, dynamic>> ref,
    required String itemType, // 'Category' or 'Brand'
  }) async {
    final controller = TextEditingController(text: oldName);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $itemType'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '$itemType name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await ref.doc(id).update({'name': result});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemType updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $itemType')),
      );
    }
  }

  Future<void> _deleteItem({
    required String id,
    required String name,
    required CollectionReference<Map<String, dynamic>> ref,
    required String itemType,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete $itemType'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.doc(id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemType deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete $itemType')),
      );
    }
  }

  Widget _buildCategoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'New category name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addingCategory ? null : _addCategory,
                child: _addingCategory
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _categoriesRef.orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text('No categories yet'),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final name = data['name'] ?? '';

                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(
                            id: doc.id,
                            oldName: name,
                            ref: _categoriesRef,
                            itemType: 'Category',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(
                            id: doc.id,
                            name: name,
                            ref: _categoriesRef,
                            itemType: 'Category',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'New brand name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addingBrand ? null : _addBrand,
                child: _addingBrand
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _brandsRef.orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text('No brands yet'),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final name = data['name'] ?? '';

                  return ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(
                            id: doc.id,
                            oldName: name,
                            ref: _brandsRef,
                            itemType: 'Brand',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(
                            id: doc.id,
                            name: name,
                            ref: _brandsRef,
                            itemType: 'Brand',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: const Text('Categories & Brands'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Categories'),
              Tab(text: 'Brands'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryTab(),
            _buildBrandTab(),
          ],
        ),
      ),
    );
  }
}
