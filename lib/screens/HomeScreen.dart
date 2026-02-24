import 'package:chatting_app/Services/notification_service.dart';
import 'package:chatting_app/data/ChatBloc/bloc/chat_bloc.dart';
import 'package:chatting_app/data/Home bloc/home_bloc.dart';
import 'package:chatting_app/data/Home bloc/home_event.dart';
import 'package:chatting_app/data/Home bloc/home_state.dart';
import 'package:chatting_app/screens/ChatScreen.dart';
import 'package:chatting_app/screens/Login.dart';
import 'package:chatting_app/screens/NotificationScreen.dart';
import 'package:chatting_app/repository/ChatRepository.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.isTokenRefresh();
  }

  @override
  Widget build(BuildContext context) {

    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) => HomeBloc(
        ChatRepository(),
      )..add(
          LoadHomeEvent(currentUser!.uid),
        ),
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) => current is HomeLoaded,
        listener: (context, state) {
          if (state is HomeLoaded) {
            if (state.newMessageSenderName != null) {
              // NotificationService.showNotification(
              //   "New Message",
              //   "Message from ${state.newMessageSenderName}",
              // );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Chat Home"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),

              /// Welcome Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentUser?.email ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "All Users",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// USERS LIST
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {

                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is HomeLoaded) {

                      final users = state.users;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {

                          final userData =
                              users[index].data()
                                  as Map<String, dynamic>;

                          if (userData['uid'] == currentUser?.uid) {
                            return const SizedBox();
                          }

                          String lastMessage =
                              state.lastMessageMap[
                                      userData['uid']] ??
                                  "";

                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(userData['name'] ?? ""),
                            subtitle: Text(
                              lastMessage.isEmpty
                                  ? userData['email'] ?? ""
                                  : lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chat),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) => ChatBloc(
                                      chatRepository: ChatRepository(),
                                    ),
                                    child: ChatScreen(
                                      receiverId: userData['uid'],
                                      receiverName: userData['name'],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    if (state is HomeError) {
                      return Center(
                        child: Text(state.message),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}