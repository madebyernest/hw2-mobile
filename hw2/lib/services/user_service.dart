import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingProfile {
  final String firstName, lastName, role;
  const PendingProfile(this.firstName, this.lastName, this.role);
}

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  PendingProfile? pending;

  static const _fields = [
    'uid',
    'firstName',
    'lastName',
    'role',
    'registrationDateTime'
  ];

  Future<Map<String, dynamic>> ensureProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    var snap = await ref.get();
    if (!snap.exists) {
      final p = pending;
      if (p == null) throw StateError('profile-missing');
      await ref.set({
        'uid': user.uid,
        'firstName': p.firstName,
        'lastName': p.lastName,
        'role': p.role,
        'registrationDateTime': FieldValue.serverTimestamp(),
      });
      snap = await ref.get();
    }
    final data = snap.data() ?? {};
    for (final f in _fields.where((f) => f != 'registrationDateTime')) {
      if (data[f] == null) throw StateError('profile-incomplete');
    }
    pending = null;
    return data;
  }
}
