import 'package:chatting_app/model/MessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Stream<List<MessageModel>> getMessages(String chatId) {
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) =>
          snapshot.docs.map((doc) => MessageModel.fromDoc(doc)).toList());
}

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
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
