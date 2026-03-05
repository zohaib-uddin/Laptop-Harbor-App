import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_drawer.dart';

class AdminContactMessagesScreen extends StatelessWidget {
  const AdminContactMessagesScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamMessages() {
    return FirebaseFirestore.instance
        .collection('contact')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _updateStatus(
      BuildContext context, String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('contact')
          .doc(id)
          .update({'status': status});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Contact Messages'),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _streamMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No contact messages found'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final name = data['name'] ?? '';
              final email = data['email'] ?? '';
              final phone = data['phone'] ?? '';
              final message = data['message'] ?? '';
              final status = data['status'] ?? 'open';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text("$name  •  $phone"),
                  subtitle: Text(
                    "Email: $email\n"
                    "Status: $status\n"
                    "Message: $message",
                  ),
                  isThreeLine: true,

                  // ---------- STATUS UPDATE MENU ----------
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _updateStatus(context, doc.id, value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'open',
                        child: Text("Open"),
                      ),
                      PopupMenuItem(
                        value: 'in_progress',
                        child: Text("In Progress"),
                      ),
                      PopupMenuItem(
                        value: 'closed',
                        child: Text("Closed"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
