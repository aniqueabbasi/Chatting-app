import 'package:equatable/equatable.dart';
import 'package:chatting_app/model/MessageModel.dart';

/// Base state class
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state before anything loads
class ChatInitial extends ChatState {}

/// State while loading messages
class ChatLoading extends ChatState {}

/// State when messages are successfully loaded
class ChatLoaded extends ChatState {
  final List<MessageModel> messages;

  const ChatLoaded({required this.messages});

  @override
  List<Object?> get props => [messages]; // Required for UI rebuild
}

/// State when error occurs
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
