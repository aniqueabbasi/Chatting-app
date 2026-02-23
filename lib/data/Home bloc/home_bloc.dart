import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chatting_app/data/Home bloc/home_event.dart';
import 'package:chatting_app/data/Home bloc/home_state.dart';
import 'package:chatting_app/repository/ChatRepository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository repository;

  StreamSubscription? _chatSub;
  StreamSubscription? _userSub;

  List<QueryDocumentSnapshot> _users = [];
  Map<String, String> _lastMessageMap = {};

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
    on<UsersUpdated>(_onUsersUpdated);
    on<ChatsUpdated>(_onChatsUpdated);
  }

  void _onLoadHome(
    LoadHomeEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoading());

    _userSub?.cancel();
    _chatSub?.cancel();

    /// Listen Users
    _userSub = repository.getUsers().listen((users) {
      add(UsersUpdated(users));
    });

    /// Listen Chats
    _chatSub =
        repository.getChats(event.currentUserId).listen((chats) {
      add(ChatsUpdated(
        chats: chats,
        currentUserId: event.currentUserId,
      ));
    });
  }

  void _onUsersUpdated(
    UsersUpdated event,
    Emitter<HomeState> emit,
  ) {
    _users = event.users;

    emit(HomeLoaded(
      users: _users,
      lastMessageMap: _lastMessageMap,
    ));
  }

  void _onChatsUpdated(
    ChatsUpdated event,
    Emitter<HomeState> emit,
  ) {
    _lastMessageMap.clear();

    for (var chatDoc in event.chats) {
      List participants = chatDoc['participants'];

      String otherUserId = participants.firstWhere(
        (id) => id != event.currentUserId,
      );

      _lastMessageMap[otherUserId] =
          chatDoc['lastMessage'] ?? "";
    }

    emit(HomeLoaded(
      users: _users,
      lastMessageMap: _lastMessageMap,
    ));
  }

  @override
  Future<void> close() {
    _chatSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
