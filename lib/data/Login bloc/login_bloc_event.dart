part of 'login_bloc_bloc.dart';

abstract class LoginBlocEvent extends Equatable {
  const LoginBlocEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends LoginBlocEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});


List<Object> get props => [ email, password];
}