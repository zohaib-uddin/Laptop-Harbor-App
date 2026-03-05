import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/app_user.dart';
import 'admin_drawer.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  Stream<List<AppUser>> _streamUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
      (snap) {
        return snap.docs
            .map(
              (d) => AppUser.fromMap(d.data(), d.id),
            )
            .toList();
      },
    );
  }

  Future<void> _changeRole(
    BuildContext context,
    AppUser user,
    String role,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': role});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to $role')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update role')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _streamUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: u.imageUrl != null && u.imageUrl!.isNotEmpty
                      ? MemoryImage(base64Decode(u.imageUrl!))
                      : null,
                  child: u.imageUrl == null || u.imageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 25)
                      : null,
                ),
                title: Text(u.name),
                subtitle: Text('${u.email}\nRole: ${u.role}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _changeRole(context, u, value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'user',
                      child: Text('Set as user'),
                    ),
                    PopupMenuItem(
                      value: 'admin',
                      child: Text('Set as admin'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
