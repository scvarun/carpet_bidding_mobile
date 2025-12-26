import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/lib/move_to_home.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/routes/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AuthBloc>().add(AuthLoadAppEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAppLoadedState) {
          if (authState.token.isNotEmpty) {
            _refreshToken(context, authState);
          } else {
            moveToLogin(context);
          }
        } else if (authState is AuthLoggedInState) {
          moveToHome(context, authState.auth.user!.userType!);
        } else if (authState is AuthErrorState) {
          moveToLogin(context);
        } else if (authState is AuthLoggedOutState) {
          moveToLogin(context);
        }
      },
      builder: (context, state) {
        return const LoadingScreen();
      },
    );
  }

  void moveToLogin(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(AuthenticateScreen.routeName);
    });
  }

  Future<void> _refreshToken(BuildContext context, state) async {
    try {
      Auth? auth = await refreshTokenOnStart(context, state);
      moveToHome(context, auth!.user!.userType!);
    } catch (e) {
      moveToLogin(context);
    }
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 8.0,
            value: Tween(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.decelerate))
                .value,
          ),
        ),
      ],
    )));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class LoadUser extends StatefulWidget {
  const LoadUser({Key? key}) : super(key: key);

  @override
  _LoadUserState createState() => _LoadUserState();
}

class _LoadUserState extends State<LoadUser> {
  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
