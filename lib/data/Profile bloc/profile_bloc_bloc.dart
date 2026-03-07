import 'package:bloc/bloc.dart';
import 'package:chatting_app/data/Profile%20bloc/profile_bloc_event.dart';
import 'package:chatting_app/data/Profile%20bloc/profile_bloc_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LogoutRequested>(_onLogout);
    on<PickProfileImage>(_onPickProfileImage);
    on<PickCoverImage>(_onPickCoverImage);
  }
Future<void> _onPickProfileImage(
  PickProfileImage event,
  Emitter<ProfileState> emit,
) async {
  if (state is ProfileLoaded) {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final user = FirebaseAuth.instance.currentUser!;
      final file = File(picked.path);

      // 🔥 Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child("users/${user.uid}/profile.jpg");

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      // 🔥 Save URL in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "profileImageUrl": downloadUrl,
      });

      final current = state as ProfileLoaded;

      emit(ProfileLoaded(
        name: current.name,
        email: current.email,
        uid: current.uid,
        isVerified: current.isVerified,
        profileImageUrl: downloadUrl,
        coverImageUrl: current.coverImageUrl,
      ));
    }
  }
} 

Future<void> _onPickCoverImage(
  PickCoverImage event,
  Emitter<ProfileState> emit,
) async {
  if (state is ProfileLoaded) {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final user = FirebaseAuth.instance.currentUser!;
      final file = File(picked.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child("users/${user.uid}/cover.jpg");

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "coverImageUrl": downloadUrl,
      });

      final current = state as ProfileLoaded;

      emit(ProfileLoaded(
        name: current.name,
        email: current.email,
        uid: current.uid,
        isVerified: current.isVerified,
        profileImageUrl: current.profileImageUrl,
        coverImageUrl: downloadUrl,
      ));
    }
  }
}
  Future<void> _onLoadProfile(
  LoadProfile event,
  Emitter<ProfileState> emit,
) async {
  emit(ProfileLoading());

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(const ProfileError("User not logged in"));
      return;
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser!;

    // 🔥 Fetch user document from Firestore
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(refreshedUser.uid)
        .get();

    final data = doc.data();

    emit(
      ProfileLoaded(
        name: refreshedUser.displayName ?? "User",
        email: refreshedUser.email ?? "",
        uid: refreshedUser.uid,
        isVerified: refreshedUser.emailVerified,

        // 🔥 Load saved image URLs
        profileImageUrl: data?["profileImageUrl"],
        coverImageUrl: data?["coverImageUrl"],
      ),
    );
  } catch (e) {
    emit(ProfileError(e.toString()));
  }
}

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await FirebaseAuth.instance.signOut();
  }
}
