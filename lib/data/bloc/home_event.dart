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
