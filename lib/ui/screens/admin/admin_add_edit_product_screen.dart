import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product? product;

  const AdminEditProductScreen({super.key, this.product});

  @override
  State<AdminEditProductScreen> createState() =>
      _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryIdController;
  late TextEditingController _brandIdController;
  late TextEditingController _imageUrlController;

  final ProductService _productService = ProductService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _saving = false;

  // dropdown ke selected values
  String? _selectedCategoryId;
  String? _selectedBrandId;

  // ⭐ NEW: rating value
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController =
        TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: p?.stock.toString() ?? '');
    _categoryIdController =
        TextEditingController(text: p?.categoryId ?? '');
    _brandIdController = TextEditingController(text: p?.brandId ?? '');
    _imageUrlController = TextEditingController(
      text: p != null && p.imageUrls.isNotEmpty
          ? p.imageUrls.first
          : '',
    );

    _selectedCategoryId = p?.categoryId;
    _selectedBrandId = p?.brandId;

    // ⭐ NEW: set rating if editing
    _rating = p?.rating ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryIdController.dispose();
    _brandIdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> brandDocs,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;

      final categoryId =
          categoryDocs.isNotEmpty
              ? (_selectedCategoryId ?? '')
              : _categoryIdController.text.trim();

      final brandId =
          brandDocs.isNotEmpty
              ? (_selectedBrandId ?? '')
              : _brandIdController.text.trim();

      final imageUrl = _imageUrlController.text.trim();

      if (widget.product == null) {
        // new product
        await _productService.addProduct(
          Product(
            id: '', // Firestore ID create karega
            name: name,
            description: description,
            price: price,
            categoryId: categoryId,
            brandId: brandId,
            imageUrls: imageUrl.isEmpty ? [] : [imageUrl],
            rating: _rating, // ⭐ SAVE rating
            ratingCount: 0,
            stock: stock,
          ),
        );
      } else {
        // update existing
        await _productService.updateProduct(
          Product(
            id: widget.product!.id,
            name: name,
            description: description,
            price: price,
            categoryId: categoryId,
            brandId: brandId,
            imageUrls: imageUrl.isEmpty ? [] : [imageUrl],
            rating: _rating, // ⭐ UPDATE rating
            ratingCount: widget.product!.ratingCount,
            stock: stock,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save product'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (widget.product == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text(
          'Are you sure you want to delete this product?',
        ),
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
      await _productService.deleteProduct(widget.product!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return FutureBuilder<
        Tuple2<
          List<QueryDocumentSnapshot<Map<String, dynamic>>>,
          List<QueryDocumentSnapshot<Map<String, dynamic>>>
        >>(
      future: _loadCategoriesAndBrands(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }

        final categoryDocs = snapshot.data?.item1 ?? [];
        final brandDocs = snapshot.data?.item2 ?? [];

        if (categoryDocs.isNotEmpty &&
            _selectedCategoryId != null &&
            !categoryDocs.any((d) => d.id == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }
        if (brandDocs.isNotEmpty &&
            _selectedBrandId != null &&
            !brandDocs.any((d) => d.id == _selectedBrandId)) {
          _selectedBrandId = null;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit product' : 'Add product'),
            actions: [
              if (isEditing)
                IconButton(
                  onPressed: _saving ? null : _delete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Description required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (RS)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Price required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Stock required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // CATEGORY FIELD
                  if (categoryDocs.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryDocs
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d.id,
                              child: Text(d.data()['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (categoryDocs.isNotEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    )
                  else
                    TextFormField(
                      controller: _categoryIdController,
                      decoration: const InputDecoration(
                        labelText: 'Category (no categories in DB, type id/text)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // BRAND FIELD
                  if (brandDocs.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBrandId,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                      items: brandDocs
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d.id,
                              child: Text(d.data()['name'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBrandId = value;
                        });
                      },
                      validator: (value) {
                        if (brandDocs.isNotEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'Please select a brand';
                        }
                        return null;
                      },
                    )
                  else
                    TextFormField(
                      controller: _brandIdController,
                      decoration: const InputDecoration(
                        labelText: 'Brand (no brands in DB, type id/text)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Main image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ⭐ NEW: Star rating input
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rating',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _rating = index + 1.0;
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () => _save(
                                categoryDocs: categoryDocs,
                                brandDocs: brandDocs,
                              ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<
      Tuple2<
        List<QueryDocumentSnapshot<Map<String, dynamic>>>,
        List<QueryDocumentSnapshot<Map<String, dynamic>>>
      >> _loadCategoriesAndBrands() async {
    final categoriesSnap =
        await _firestore.collection('categories').orderBy('name').get();
    final brandsSnap =
        await _firestore.collection('brands').orderBy('name').get();

    return Tuple2(categoriesSnap.docs, brandsSnap.docs);
  }
}

/// simple Tuple class
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}
