import 'package:flutter/material.dart';

import '../../../models/order.dart' as app_model;
import '../../../services/order_service.dart';
import '../../widgets/order_tile.dart';
import 'admin_drawer.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: StreamBuilder<List<app_model.Order>>(
        stream: orderService.streamAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? <app_model.Order>[];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              return OrderTile(
                order: o,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminOrderDetailScreen(order: o),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
