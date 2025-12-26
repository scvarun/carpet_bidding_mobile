import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:validators/validators.dart' as validator;

class ForgotPasswordScreen extends StatelessWidget {
  static const routeName = '/forgotPassword';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Forgot Password'),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
                fontSize: 12.sp,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'SourceSerifPro')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            _ForgotPasswordForm(),
          ],
        ));
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  __ForgotPasswordFormState createState() => __ForgotPasswordFormState();
}

class __ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _model = _ForgotPasswordModel(email: '');
  final FocusNode passwordFocus = FocusNode();
  var _loading = false;
  var _success = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error.toString())));
        } else if (state is AuthLoggedInState) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Login Successful. Redirecting to home...')));
          _changeRouteTimer();
        }
      },
      builder: (context, state) {
        return Form(
            key: _formKey,
            child: Column(children: [
              _emailField(),
              _submitButton(context),
            ]));
      },
    );
  }

  Widget _emailField() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextFormField(
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

  Widget _submitButton(BuildContext context) {
    String btnText = 'Reset Password';
    if (_loading) {
      btnText = 'Loading...';
    } else if (_success) {
      btnText = 'Password updated';
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(
            child: PrimaryButton(
              color: Theme.of(context).colorScheme.secondary,
              title: btnText,
              disabled: _loading,
              inverted: _success,
              onPressed: () => submit(context),
            ),
          )
        ]));
  }

  void submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _loading = true;
        });
        var message = await AuthRepository().forgotPassword(_model.email);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
        setState(() {
          _success = true;
        });
      } catch (e) {
        var error = AppError.fromError(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Timer> _changeRouteTimer() async =>
      Timer(const Duration(seconds: 2), () {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).pop();
        // Navigator.pushNamed(context, CustomerHomeScreen.routeName);
      });
}

/*
 * Login Form data datatype
 */
class _ForgotPasswordModel {
  String email;

  _ForgotPasswordModel({required this.email});
}
