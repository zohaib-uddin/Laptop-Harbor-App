import 'package:flutter/material.dart';

import '../../models/order.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderTile({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        title: Text('Order #${order.id.substring(0, 6)}'),
        subtitle: Text(
          '${order.status.toUpperCase()} • ${order.totalAmount.toStringAsFixed(0)} RS',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
