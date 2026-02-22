import 'dart:async';

import 'package:chatting_app/data/bloc/home_event.dart';
import 'package:chatting_app/data/bloc/home_state.dart';
import 'package:chatting_app/repository/ChatRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Bloc, Emitter;
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ChatRepository repository;

  StreamSubscription? _chatSub;
  StreamSubscription? _userSub;

  List<QueryDocumentSnapshot> _users = [];
  Map<String, String> _lastMessageMap = {};

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  void _onLoadHome(
    LoadHomeEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeLoading());

    _userSub?.cancel();
    _chatSub?.cancel();

    _userSub = repository.getUsers().listen((users) {
      _users = users;
      emit(HomeLoaded( users: _users, lastMessageMap: _lastMessageMap, ));
    });

    _chatSub = repository.getChats(event.currentUserId).listen((chats) {
      _lastMessageMap.clear();
      for (var chatDoc in chats) {
        List participants = chatDoc['participants'];

        String otherUserId =
            participants.firstWhere(
              (id) => id != event.currentUserId,
            );

        _lastMessageMap[otherUserId] =
            chatDoc['lastMessage'] ?? "";
      }

      emit(HomeLoaded(
        users: _users,
        lastMessageMap: _lastMessageMap,
      ));
    });
  }

  @override
  Future<void> close() {
    _chatSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
