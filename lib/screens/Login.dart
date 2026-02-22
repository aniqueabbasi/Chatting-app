import 'package:chatting_app/Services/auth_service.dart';
import 'package:chatting_app/data/Login bloc/login_bloc_bloc.dart';
import 'package:chatting_app/data/Login bloc/login_bloc_state.dart';
import 'package:chatting_app/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBlocBloc(AuthService()),
      child: Scaffold(
        body: BlocListener<LoginBlocBloc, LoginBlocState>(
          listener: (context, state) {
            if (state is LoginBlocSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              );
            }

            if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<LoginBlocBloc, LoginBlocState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/background.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: emailController,
                            decoration:
                                const InputDecoration(
                              labelText: "Email",
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller:
                                passwordController,
                            obscureText: true,
                            decoration:
                                const InputDecoration(
                              labelText: "Password",
                            ),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  state is LoginBlocLoading
                                      ? null
                                      : () {
                                          context
                                              .read<
                                                  LoginBlocBloc>()
                                              .add(
                                                LoginEvent(
                                                  email:
                                                      emailController
                                                          .text
                                                          .trim(),
                                                  password:
                                                      passwordController
                                                          .text
                                                          .trim(),
                                                ),
                                              );
                                        },
                              child: state
                                      is LoginBlocLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Login",
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
