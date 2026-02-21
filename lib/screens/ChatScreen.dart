import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =  TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser!;

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode
        ? '$uid1-$uid2'
        : '$uid2-$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(currentUser.uid, widget.receiverId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          /// Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data()
                            as Map<String, dynamic>;

                    final isMe =
                        message['senderId'] ==
                            currentUser.uid;

                    return Container(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Send message field
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (messageController.text.isEmpty)
                      return;

                    await FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .set({
  'participants': [currentUser.uid, widget.receiverId],
  'lastMessage': messageController.text,
  'lastTimestamp': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));

await FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .add({
  'senderId': currentUser.uid,
  'text': messageController.text,
  'timestamp': FieldValue.serverTimestamp(),
});
                    messageController.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}