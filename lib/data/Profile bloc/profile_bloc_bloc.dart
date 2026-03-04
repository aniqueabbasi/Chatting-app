import 'package:bloc/bloc.dart';
import 'package:chatting_app/data/Profile%20bloc/profile_bloc_event.dart';
import 'package:chatting_app/data/Profile%20bloc/profile_bloc_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final current = state as ProfileLoaded;

      emit(ProfileLoaded(
        name: current.name,
        email: current.email,
        uid: current.uid,
        isVerified: current.isVerified,
        profileImage: File(picked.path),
        coverImage: current.coverImage,
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
      final current = state as ProfileLoaded;

      emit(ProfileLoaded(
        name: current.name,
        email: current.email,
        uid: current.uid,
        isVerified: current.isVerified,
        profileImage: current.profileImage,
        coverImage: File(picked.path),
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

      emit(ProfileLoaded(
        name: refreshedUser.displayName ?? "User",
        email: refreshedUser.email ?? "",
        uid: refreshedUser.uid,
        isVerified: refreshedUser.emailVerified,
      ));
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