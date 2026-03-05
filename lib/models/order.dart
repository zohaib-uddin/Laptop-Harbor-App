// models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  // Shipping Info
  final String fullName;
  final String address;
  final String? phone;
  final String? city;

  // Billing Info
  final String paymentMethod;
  final String? billingName;
  final String? billingAddress;

  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.items,
    required this.paymentMethod,
    required this.fullName,
    this.phone,
    this.city,
    this.billingName,
    this.billingAddress,
  });

  // Factory method to create Order from Firestore DocumentSnapshot
  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final ts = data['createdAt'] as Timestamp?;
    final List<dynamic> itemList = data['items'] ?? [];

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: ts?.toDate() ?? DateTime.now(),
      fullName: data['fullName'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'],
      city: data['city'],
      paymentMethod: data['paymentMethod'] ?? 'COD',
      billingName: data['billingName'],
      billingAddress: data['billingAddress'],
      items: itemList.map((e) => OrderItem.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  // Convert Order object to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'city': city,
      'paymentMethod': paymentMethod,
      'billingName': billingName,
      'billingAddress': billingAddress,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
    