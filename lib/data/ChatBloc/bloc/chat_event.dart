import 'package:chatting_app/model/MessageModel.dart';

 abstract class ChatEvent {}

/// Triggered when chat screen opens to start listening to messages
class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
}

/// Triggered when user sends a message
class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;

  SendMessageEvent({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
  });
}

/// Internal event triggered when Firestore stream updates
class MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;
  MessagesUpdated(this.messages);
}
