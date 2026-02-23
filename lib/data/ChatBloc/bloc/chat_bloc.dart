import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:chatting_app/repository/ChatRepository.dart';
import 'package:chatting_app/model/MessageModel.dart';

/// Bloc that handles chat logic and Firestore stream listening
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<MessageModel>>? _messageSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    /// Start listening to Firestore messages stream
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());

      await _messageSubscription?.cancel();

      _messageSubscription = chatRepository.getMessages(event.chatId).listen((
        messages,
      ) {
        add(MessagesUpdated(messages));
      });
    });

    /// When Firestore sends new messages
    on<MessagesUpdated>((event, emit) {
      emit(ChatLoaded(messages: event.messages));
    });

    /// When user sends a message
    on<SendMessageEvent>((event, emit) async {
      await chatRepository.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        receiverId: event.receiverId,
        text: event.text,
      );
    });
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    return super.close();
  }
}
