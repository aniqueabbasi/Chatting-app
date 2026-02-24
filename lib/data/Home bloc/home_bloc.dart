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
  Map<String, String> _previousLastMessageMap = {};

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

    _userSub = repository.getUsers().listen((users) {
      add(UsersUpdated(users));
    });

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
    String? newMessageSenderId;
    String? newMessageText;
    String? newMessageSenderName;

    Map<String, String> updatedMap = {};

    for (var chatDoc in event.chats) {
      final data = chatDoc.data() as Map<String, dynamic>;

      /// Safe participants read
      List participants = data['participants'] ?? [];

      if (!participants.contains(event.currentUserId)) continue;

      String otherUserId =
          participants.firstWhere((id) => id != event.currentUserId);

       String newLastMessage = data['lastMessage'] ?? "";

      updatedMap[otherUserId] = newLastMessage;

       if (_previousLastMessageMap.containsKey(otherUserId) &&
          _previousLastMessageMap[otherUserId] != newLastMessage) {

         String senderId =
            data.containsKey('lastMessageSenderId')
                ? data['lastMessageSenderId']
                : "";

         if (senderId != event.currentUserId &&
            senderId.isNotEmpty) {

          newMessageSenderId = otherUserId;
          newMessageText = newLastMessage;

           final senderUser = _users.firstWhere(
            (user) =>
                (user.data() as Map<String, dynamic>)['uid'] ==
                otherUserId,
            orElse: () => _users.isNotEmpty ? _users.first : chatDoc,
          );

          if (_users.isNotEmpty) {
            final senderData =
                senderUser.data() as Map<String, dynamic>;
            newMessageSenderName = senderData['name'] ?? "New Message";
          }
        }
      }
    }

    _lastMessageMap = updatedMap;
    _previousLastMessageMap = Map.from(updatedMap);

    emit(HomeLoaded(
      users: _users,
      lastMessageMap: _lastMessageMap,
      newMessageSenderId: newMessageSenderId,
      newMessageText: newMessageText,
      newMessageSenderName: newMessageSenderName,
    ));
  }

  @override
  Future<void> close() {
    _chatSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}