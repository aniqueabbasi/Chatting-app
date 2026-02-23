import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load everything (users + chats)
class LoadHomeEvent extends HomeEvent {
  final String currentUserId;

  const LoadHomeEvent(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}
class UsersUpdated extends HomeEvent {
  final List<QueryDocumentSnapshot> users;
  const UsersUpdated(this.users);

  @override
  List<Object?> get props => [users];
}

class ChatsUpdated extends HomeEvent {
  final List<QueryDocumentSnapshot> chats;
  final String currentUserId;

  const ChatsUpdated({
    required this.chats,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [chats, currentUserId];
}
