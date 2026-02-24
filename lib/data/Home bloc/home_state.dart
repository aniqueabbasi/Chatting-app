import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<QueryDocumentSnapshot> users;
  final Map<String, String> lastMessageMap;

   final String? newMessageSenderId;
  final String? newMessageSenderName;
  final String? newMessageText;

  HomeLoaded({
    required this.users,
    required this.lastMessageMap,
    this.newMessageSenderId,
    this.newMessageSenderName,
    this.newMessageText,
  });

   HomeLoaded copyWith({
    List<QueryDocumentSnapshot>? users,
    Map<String, String>? lastMessageMap,
    String? newMessageSenderId,
    String? newMessageSenderName,
    String? newMessageText,
  }) {
    return HomeLoaded(
      users: users ?? this.users,
      lastMessageMap: lastMessageMap ?? this.lastMessageMap,
      newMessageSenderId:
          newMessageSenderId ?? this.newMessageSenderId,
      newMessageSenderName:
          newMessageSenderName ?? this.newMessageSenderName,
      newMessageText:
          newMessageText ?? this.newMessageText,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}