import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class LogoutRequested extends ProfileEvent {}
 class PickProfileImage extends ProfileEvent {}

class PickCoverImage extends ProfileEvent {}