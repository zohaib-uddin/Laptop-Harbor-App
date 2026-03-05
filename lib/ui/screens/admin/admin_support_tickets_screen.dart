import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_drawer.dart';

class AdminSupportTicketsScreen extends StatelessWidget {
  const AdminSupportTicketsScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamTickets() {
    return FirebaseFirestore.instance
        .collection('supportTickets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _updateStatus(
      BuildContext context, String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('supportTickets')
          .doc(id)
          .update({'status': status});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket status updated')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update ticket')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Support Tickets'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _streamTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No tickets'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final status = data['status'] ?? 'open';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(data['subject'] ?? ''),
                  subtitle: Text(
                    'Email: ${data['email'] ?? ''}\n'
                    'Status: $status\n'
                    'Message: ${data['message'] ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _updateStatus(context, doc.id, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'open',
                        child: Text('Open'),
                      ),
                      PopupMenuItem(
                        value: 'in_progress',
                        child: Text('In progress'),
                      ),
                      PopupMenuItem(
                        value: 'closed',
                        child: Text('Closed'),
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
