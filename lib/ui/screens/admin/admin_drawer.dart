import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/admin/admin_contact_messages_screen.dart';

import 'admin_dashboard_screen.dart';
import 'admin_products_list_screen.dart';
import 'admin_orders_list_screen.dart';
import 'admin_users_list_screen.dart';
import 'admin_support_tickets_screen.dart';
import 'admin_categories_brands_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void go(Widget screen) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => go(const AdminDashboardScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.laptop),
            title: const Text('Products'),
            onTap: () => go(const AdminProductsListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Orders'),
            onTap: () => go(const AdminOrdersScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () => go(const AdminUsersScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories & Brands'),
            onTap: () => go(const AdminCategoriesBrandsScreen()),
          ),

          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Support tickets'),
            onTap: () => go(const AdminSupportTicketsScreen()),
          ),

          ListTile(
  leading: const Icon(Icons.message),
  title: const Text("Contact Messages"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminContactMessagesScreen()),
    );
  },
),

        ],
      ),
    );
  }
}
