import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AuthMiddleware extends StatelessWidget {
  final Widget child;

  const AuthMiddleware({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOutState) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(child: Container(child: child)),
          ],
        );
      },
    );
  }
}
