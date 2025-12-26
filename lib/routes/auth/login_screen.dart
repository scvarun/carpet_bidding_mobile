import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/lib/move_to_home.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:validators/validators.dart' as validator;

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 80,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: const _LoginForm()),
      ),
    ));
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  __LoginFormState createState() => __LoginFormState();
}

class __LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _model = _LoginFormModel(email: '', password: '');
  bool _showPassword = false;
  final FocusNode passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) async {
        if (authState is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authState.error.toString())));
        } else if (authState is AuthLoggedInState) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Login Successful. Redirecting to home...')));
          if (authState.auth.user?.userType != null) {
            moveToHome(context, authState.auth.user!.userType!);
          }
        }
      },
      builder: (context, state) {
        bool loading = false, success = false;
        if (state is AuthLoadingState) {
          loading = true;
        } else if (state is AuthLoggedInState) {
          success = true;
        }
        return Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('carpet\nImpex',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _emailField(loading: loading),
                    _passwordField(loading: loading),
                    _submitButton(context, loading: loading, success: success),
                    _forgotPassword(context),
                  ],
                )
              ],
            ));
      },
    );
  }

  Widget _emailField({bool loading = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !loading,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.email,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Email',
            labelText: 'Email',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(0xffeeeeee), style: BorderStyle.solid)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email';
            } else if (!validator.isEmail(value)) {
              return 'Please enter a valid email';
            }
            _formKey.currentState?.save();
            return null;
          },
          onFieldSubmitted: (e) =>
              FocusScope.of(context).requestFocus(passwordFocus),
          onSaved: (String? value) {
            if (value != null) {
              _model.email = value;
            }
          }),
    );
  }

  Widget _passwordField({bool loading = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          focusNode: passwordFocus,
          enabled: !loading,
          obscureText: !_showPassword,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                  gapPadding: 0,
                  borderSide: BorderSide(
                    color: Color(0xffeeeeee),
                    style: BorderStyle.solid,
                  )),
              hintStyle: Theme.of(context).textTheme.bodyText1,
              hintText: 'Password',
              labelText: 'Password',
              suffix: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    size: 16.sp),
              )),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your password';
            }
            _formKey.currentState!.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.password = value;
            }
          }),
    );
  }

  Widget _submitButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String btnText = 'Login';
    if (loading) {
      btnText = 'Loading...';
    } else if (success) {
      btnText = 'Login Successful';
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: loading || success,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: btnText,
                disabled: loading,
                inverted: success,
                onPressed: () => _submit(context),
              ),
            ),
          )
        ]));
  }

  void _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      Timer(const Duration(milliseconds: 100), () {
        var authState = context.read<AuthBloc>().state;
        if (authState is AuthLoadingState == false) {
          context.read<AuthBloc>().add(
              AuthLoginEvent(email: _model.email, password: _model.password));
        }
      });
    }
  }

  _forgotPassword(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
        },
        child: Text('Forgot Password?',
            style: Theme.of(context).textTheme.bodyText1));
  }
}

/*
 * Login Form data datatype
 */
class _LoginFormModel {
  String email;
  String password;

  _LoginFormModel({required this.email, required this.password});
}
