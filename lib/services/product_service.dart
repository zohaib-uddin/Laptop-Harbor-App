import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _productsRef =>
      _firestore.collection('products');

  Stream<List<Product>> streamProducts() {
    return _productsRef.snapshots().map(
          (snap) => snap.docs.map(Product.fromDoc).toList(),
        );
  }

  Future<List<Product>> getProductsOnce() async {
    final snap = await _productsRef.get();
    return snap.docs.map(Product.fromDoc).toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromDoc(doc);
  }

  Future<String> addProduct(Product product) async {
    final doc = await _productsRef.add(product.toMap());
    return doc.id;
  }

  Future<void> updateProduct(Product product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }
}
