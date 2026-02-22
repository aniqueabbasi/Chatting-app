import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<QueryDocumentSnapshot> users;
  final Map<String, String> lastMessageMap;

  HomeLoaded({
    required this.users,
    required this.lastMessageMap,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
