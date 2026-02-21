import 'package:chatting_app/screens/ChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Home"),
        centerTitle: true,
        actions: [
           IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        // Navigate to notification screen (we will create it next)
        Navigator.push(
          context,
          // MaterialPageRoute(
          //   // builder: (_) => const NotificationScreen(),
          // ),
        );
      },
    ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// USERS LIST FROM FIRESTORE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData =
                        users[index].data() as Map<String, dynamic>;

                    if (userData['uid'] == currentUser?.uid) {
                      return const SizedBox();
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .where(
                            'participants',
                            arrayContains: currentUser?.uid,
                          )
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        if (!chatSnapshot.hasData) {
                          return const SizedBox();
                        }

                        String lastMessage = "";

                        for (var chatDoc in chatSnapshot.data!.docs) {
                          List participants = chatDoc['participants'];

                          if (participants.contains(userData['uid'])) {
                            lastMessage = chatDoc['lastMessage'] ?? "";
                            break;
                          }
                        }

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
                                builder: (_) => ChatScreen(
                                  receiverId: userData['uid'],
                                  receiverName: userData['name'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
