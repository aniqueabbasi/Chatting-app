 

 import 'package:flutter/material.dart';

abstract class LoginBlocState {}
 class LoginBlocInital extends LoginBlocState {}
 class LoginBlocLoading extends LoginBlocState{}
 class LoginBlocSuccess extends LoginBlocState{}
class LoginFailure extends LoginBlocState {
  final String message;
  LoginFailure(this.message);
} 