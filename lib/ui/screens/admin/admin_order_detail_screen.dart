// screens/admin/admin_order_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../services/order_service.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Order order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  Future<void> _saveStatus() async {
    setState(() => _saving = true);
    try {
      await _orderService.updateOrderStatus(widget.order.id, _status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- ORDER STATUS ----------
            const Text(
              'Order Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _statusStepper(_status),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Update Status:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _saveStatus,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---------- ITEMS ----------
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Image.network(
                    item.thumbnail != null && item.thumbnail!.isNotEmpty
                        ? item.thumbnail!
                        : 'https://via.placeholder.com/50',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.price.toStringAsFixed(0)} RS x ${item.quantity}'),
                  trailing: Text((item.price * item.quantity).toStringAsFixed(0)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- SHIPPING INFO ----------
            const Text(
              'Shipping Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Name: ${order.fullName}'),
            Text('Phone: ${order.phone}'),
            Text('Address: ${order.address}'),
            Text('City: ${order.city}'),
            const SizedBox(height: 12),

            // ---------- BILLING INFO ----------
            const Text(
              'Billing Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Billing Name: ${order.billingName}'),
            Text('Billing Address: ${order.billingAddress}'),
            const SizedBox(height: 12),

            // ---------- PAYMENT ----------
            Text(
              'Payment Method: ${order.paymentMethod}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- STATUS STEPPER ----------
  Widget _statusStepper(String currentStatus) {
    final statuses = ['cancelled', 'pending', 'shipped', 'delivered'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isCurrent = status == currentStatus;
        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCurrent ? Colors.yellow : Colors.grey[300],
              child: Text(
                status[0].toUpperCase(),
                style: TextStyle(
                  color: isCurrent ? Colors.black : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.orange[800] : Colors.black,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
