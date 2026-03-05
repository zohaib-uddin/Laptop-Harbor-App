import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;
  final String userId;

  List<Order> _myOrders = [];
  List<Order> get myOrders => _myOrders;

  OrderProvider(this._orderService, this.userId) {
    _orderService.streamUserOrders(userId).listen((ordersList) {
      _myOrders = ordersList;
      notifyListeners();
    });
  }

  Future<String> placeOrder({
    required String address,
    // required String email,
    required List<OrderItem> items,
    required double total,

    // NEW FIELDS
    required String paymentMethod,
      required String fullName,
  String? userEmail,   // <-- ADD THIS

    String? phone,
    String? city,
    String? billingName,
    String? billingAddress,
  }) async {
    return _orderService.createOrder(
      userId: userId,
      // email: email,
      address: address,
      items: items,
      totalAmount: total,

      // NEW FIELDS
      paymentMethod: paymentMethod,
          fullName: fullName,

      phone: phone,
      city: city,
      billingName: billingName,
      billingAddress: billingAddress,
          userEmail: userEmail,  // <-- PASS HERE

    );
  }
}
