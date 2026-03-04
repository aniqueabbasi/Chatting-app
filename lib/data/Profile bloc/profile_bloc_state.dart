import 'package:equatable/equatable.dart';
import 'dart:io';
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String uid;
  final bool isVerified;
  final File? profileImage;
  final File? coverImage;


  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.uid,
    required this.isVerified,
      this.coverImage,
      this.profileImage,
   });

  @override
  List<Object?> get props => [name, email, uid, isVerified,profileImage,coverImage];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}