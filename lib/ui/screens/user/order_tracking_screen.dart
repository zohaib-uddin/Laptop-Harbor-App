import 'package:flutter/material.dart';
import '../../../services/order_service.dart';
import '../../../models/order.dart' as app_model;

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderService _orderService = OrderService();
  late Future<app_model.Order> _orderFuture;

  final double shippingFee = 200;
  final double taxRate = 0.05; // 5%

  @override
  void initState() {
    super.initState();
    _orderFuture = _orderService.getOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
),
      ),
      body: FutureBuilder<app_model.Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data!;
          final subtotal = order.items.fold<double>(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );
          final tax = subtotal * taxRate;
          final total = subtotal + tax + shippingFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- ORDER ITEMS ----------
                const Text('Items',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => ListTile(
                  leading: Image.network(
  item.thumbnail != null && item.thumbnail!.isNotEmpty
      ? item.thumbnail!
      : 'https://via.placeholder.com/50', // fallback placeholder
  width: 50,
  height: 50,
  fit: BoxFit.cover,
),

                    title: Text(item.name),
                    subtitle:
                        Text('${item.price.toStringAsFixed(0)} RS x ${item.quantity}'),
                    trailing:
                        Text((item.price * item.quantity).toStringAsFixed(0)),
                  ),
                ),
                const Divider(),
                // ---------- SHIPPING INFO ----------
                const SizedBox(height: 12),
                const Text('Shipping Information',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Name: ${order.fullName}'),
                Text('Phone: ${order.phone}'),
                Text('Address: ${order.address}'),
                Text('City: ${order.city}'),
                const SizedBox(height: 12),
                Text('Payment Method: ${order.paymentMethod}'),
                const Divider(),
                const SizedBox(height: 8),
                // ---------- ORDER SUMMARY ----------
                const Text('Order Summary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _summaryRow('Subtotal', '${subtotal.toStringAsFixed(0)} RS'),
                _summaryRow('Tax (5%)', '${tax.toStringAsFixed(0)} RS'),
                _summaryRow('Shipping Fee', '$shippingFee RS'),
                const Divider(),
                _summaryRow('Total', '${total.toStringAsFixed(0)} RS',
                    isBold: true, fontSize: 18),
                const SizedBox(height: 16),
                // ---------- ORDER STATUS ----------
                const Text('Order Status',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _statusStepper(order.status),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String title, String value,
      {bool isBold = false, double fontSize = 15}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _statusStepper(String currentStatus) {
    final statuses = ['cancelled', 'pending', 'shipped', 'delivered'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isCurrent = status == currentStatus;
        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCurrent ? Colors.yellow : Colors.grey[300],
              child: Text(
                (status[0].toUpperCase()),
                style: TextStyle(
                    color: isCurrent ? Colors.black : Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.orange[800] : Colors.black),
            ),
          ],
        );
      }).toList(),
    );
  }
}
