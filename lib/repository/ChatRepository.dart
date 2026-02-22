import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  Stream<List<QueryDocumentSnapshot>> getChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
