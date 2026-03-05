import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'name': user.name,
      'phone': user.phone,
      'role': user.role,
    });
  }

  Stream<List<AppUser>> streamAllUsers() {
    return _firestore.collection('users').snapshots().map(
      (snap) {
        return snap.docs
            .map((doc) => AppUser.fromMap(doc.data(), doc.id))
            .toList();
      },
    );
  }
}
