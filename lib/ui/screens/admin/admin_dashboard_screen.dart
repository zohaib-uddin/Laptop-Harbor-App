import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/auth/admin_login_screen.dart';

import '../auth/login_screen.dart';
import 'admin_drawer.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, int>> _loadCounts() async {
    final firestore = FirebaseFirestore.instance;

    final productsCount = (await firestore.collection('products').get()).size;
    final ordersCount = (await firestore.collection('orders').get()).size;
    final usersCount = (await firestore.collection('users').get()).size;
    final ticketsCount =
        (await firestore.collection('supportTickets').get()).size;

    return {
      'products': productsCount,
      'orders': ordersCount,
      'users': usersCount,
      'tickets': ticketsCount,
    };
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final counts = snapshot.data ??
              {'products': 0, 'orders': 0, 'users': 0, 'tickets': 0};

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(
                label: 'Products',
                count: counts['products']!,
                icon: Icons.laptop,
                color: Colors.blue,
              ),
              _StatCard(
                label: 'Orders',
                count: counts['orders']!,
                icon: Icons.receipt,
                color: Colors.green,
              ),
              _StatCard(
                label: 'Users',
                count: counts['users']!,
                icon: Icons.people,
                color: Colors.orange,
              ),
              _StatCard(
                label: 'Tickets',
                count: counts['tickets']!,
                icon: Icons.support_agent,
                color: Colors.purple,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
