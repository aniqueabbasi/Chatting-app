import 'package:bloc/bloc.dart';
import 'package:chatting_app/Services/auth_service.dart';
import 'package:chatting_app/data/Login%20bloc/login_bloc_state.dart';
import 'package:equatable/equatable.dart';

part 'login_bloc_event.dart';
 class LoginBlocBloc
    extends Bloc<LoginBlocEvent, LoginBlocState> {
  final AuthService authService;

  LoginBlocBloc(this.authService)
      : super(LoginBlocInital()) {
    on<LoginEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginEvent event,
    Emitter<LoginBlocState> emit,
  ) async {
    emit(LoginBlocLoading());

    final result =
        await authService.login( email: event.email, password: event.password,);

    if (result == null) {
      emit(LoginBlocSuccess());
    } else {
      emit(LoginFailure(result));
    }
  }
}
