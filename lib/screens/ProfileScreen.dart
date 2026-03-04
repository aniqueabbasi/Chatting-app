import 'package:chatting_app/data/Profile bloc/profile_bloc_bloc.dart';
import 'package:chatting_app/data/Profile bloc/profile_bloc_event.dart';
import 'package:chatting_app/data/Profile bloc/profile_bloc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfile()),
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [

                    /// ===== HEADER SECTION =====
                    SizedBox(
                      height: 320,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [

                          /// 🔥 COVER IMAGE
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(PickCoverImage());
                            },
                            child: Container(
                              height: 250,
                              width: double.infinity,
                              decoration: state.coverImage != null
                                  ? BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            FileImage(state.coverImage!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const BoxDecoration(
                                      color: Colors.purple,
                                    ),
                              child: state.coverImage == null
                                  ? const Center(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          /// 🔥 PROFILE IMAGE (OVERLAP)
                          Positioned(
                            top: 200,
                            child: Stack(
                              children: [

                                GestureDetector(
                                  onTap: () {
                                    context
                                        .read<ProfileBloc>()
                                        .add(PickProfileImage());
                                  },
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          state.profileImage != null
                                              ? FileImage(
                                                  state.profileImage!)
                                              : const AssetImage(
                                                      "assets/profile.jpg")
                                                  as ImageProvider,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<ProfileBloc>()
                                          .add(PickProfileImage());
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    /// ===== NAME =====
                    Text(
                      state.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ===== EMAIL VERIFIED =====
                    Text(
                      state.isVerified
                          ? "Email Verified ✅"
                          : "Email Not Verified ❌",
                      style: TextStyle(
                        color: state.isVerified
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ===== DETAILS =====
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      child: Column(
                        children: [
                          _buildField("Name", state.name),
                          _buildField("Email", state.email),
                          _buildField("User ID", state.uid),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ===== LOGOUT =====
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(LogoutRequested());
                      },
                      child: const Text("Logout"),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(height: 25),
      ],
    );
  }
}