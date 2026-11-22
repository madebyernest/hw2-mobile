import 'package:cloud_firestore/cloud_firestore.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String newMessageId() => _db.collection('messages').doc().id;

  Future<void> postMessage({
    required String messageId,
    required String authorUid,
    required String authorName,
    required String text,
  }) =>
      _db.collection('messages').doc(messageId).set({
        'authorUid': authorUid,
        'authorName': authorName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<QuerySnapshot<Map<String, dynamic>>> messageBoard() =>
      _db.collection('messages').orderBy('createdAt').snapshots();

  Future<void> editMessage({
    required String messageId,
    required String newText,
  }) =>
      _db.collection('messages').doc(messageId).update({
        'text': newText,
        'editedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteMessage({required String messageId}) =>
      _db.collection('messages').doc(messageId).delete();

  static String message(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Not allowed: you can only change your own messages.';
        case 'unavailable':
          return 'You appear to be offline. It will send when you reconnect.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
