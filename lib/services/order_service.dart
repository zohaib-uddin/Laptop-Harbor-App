import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_model;
import '../models/order_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  /// Create a new order
  Future<String> createOrder({
    required String userId,
    required String address,
    required List<OrderItem> items,
    required double totalAmount,
    required String paymentMethod,
    required String fullName,
    String? userEmail,
    String? phone,
    String? city,
    String? billingName,
    String? billingAddress,
  }) async {
    final doc = await _ordersRef.add({
      'userId': userId,
      'userEmail': userEmail,
      'totalAmount': totalAmount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),

      // Shipping details
      'fullName': fullName,
      'address': address,
      'city': city ?? '',
      'phone': phone ?? '',

      // Billing details
      'billingName': billingName ?? '',
      'billingAddress': billingAddress ?? '',

      // Payment Method
      'paymentMethod': paymentMethod,

      // Items
      'items': items.map((e) => e.toMap()).toList(),
    });

    return doc.id;
  }

  /// Stream orders for a specific user (sorted by createdAt)
  Stream<List<app_model.Order>> streamUserOrders(String userId) {
    return _ordersRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders =
          snapshot.docs.map((doc) => app_model.Order.fromDoc(doc)).toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Stream all orders for admin (sorted)
  Stream<List<app_model.Order>> streamAllOrders() {
    return _ordersRef.snapshots().map((snapshot) {
      final orders =
          snapshot.docs.map((doc) => app_model.Order.fromDoc(doc)).toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersRef.doc(orderId).update({'status': status});
  }

  /// Get a single order by its ID
  Future<app_model.Order> getOrderById(String orderId) async {
    final doc = await _ordersRef.doc(orderId).get();
    if (!doc.exists) throw Exception('Order not found');
    return app_model.Order.fromDoc(doc);
  }
}
