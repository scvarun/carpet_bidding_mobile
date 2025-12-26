import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:sizer/sizer.dart';
import 'package:validators/validators.dart' as validator;

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Register'.toUpperCase()),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: const TextStyle(
                fontSize: 18,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'SourceSerifPro')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: const _RegisterForm()),
          ),
        ));
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({Key? key}) : super(key: key);

  @override
  __RegisterFormState createState() => __RegisterFormState();
}

class __RegisterFormState extends State<_RegisterForm> {
  // static const String CLASSNAME = '_RegisterForm';

  final _formKey = GlobalKey<FormState>();
  final _RegisterFormModel _model = _RegisterFormModel(
    email: '',
    firstName: '',
    lastName: '',
    password: '',
    phone: '',
    companyName: '',
  );

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _companyNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  late bool _loading;
  late bool _success;
  late bool _agreed;

  late bool _showPassword;
  // bool _facebookLoginProcessing;

  @override
  void initState() {
    _loading = false;
    _success = false;
    _agreed = false;
    _showPassword = false;
    // _facebookLoginProcessing = false;
    super.initState();
  }

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
        }
      },
      builder: (context, state) {
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              minHeight: MediaQuery.of(context).size.height - 110,
            ),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _firstNameField(context)),
                          Expanded(child: _lastNameField(context)),
                        ],
                      ),
                      _emailField(context),
                      _phoneField(context),
                      _companyNameField(context),
                      _passwordField(context),
                      _confirmPasswordField(context),
                      _agreeField(context),
                      _submitButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _firstNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 10, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              focusNode: _firstNameFocus,
              initialValue: _model.firstName,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffeeeeee))),
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'First Name',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                _formKey.currentState!.save();
                return null;
              },
              onFieldSubmitted: (e) =>
                  FocusScope.of(context).requestFocus(_lastNameFocus),
              onSaved: (String? value) {
                if (value!.isNotEmpty) {
                  _model.firstName = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _lastNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            focusNode: _lastNameFocus,
            enabled: !_loading,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            initialValue: _model.lastName,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffeeeeee))),
              hintStyle: Theme.of(context).textTheme.bodyText1,
              hintText: 'Last Name',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
              _formKey.currentState!.save();
              return null;
            },
            onFieldSubmitted: (e) =>
                FocusScope.of(context).requestFocus(_emailFocus),
            onSaved: (String? value) {
              if (value!.isNotEmpty) {
                _model.lastName = value;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
              focusNode: _emailFocus,
              textInputAction: TextInputAction.next,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              initialValue: _model.email,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffeeeeee))),
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Email',
              ),
              validator: (value) {
                if (!validator.isEmail(value!)) {
                  return 'Please enter a valid email';
                }
                _formKey.currentState!.save();
                return null;
              },
              onFieldSubmitted: (e) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              onSaved: (String? value) {
                if (value!.isNotEmpty) {
                  _model.email = value;
                }
              })
        ],
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              focusNode: _phoneFocus,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              initialValue: _model.phone,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffeeeeee))),
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Phone',
              ),
              onFieldSubmitted: (e) =>
                  FocusScope.of(context).requestFocus(_companyNameFocus),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                } else if (validator.matches(value, r"[1-9][0-9]{9}") ==
                        false ||
                    value.length != 10) {
                  return 'Please enter a valid phone no.';
                }
                _formKey.currentState!.save();
                return null;
              },
              onSaved: (String? value) {
                if (value!.isNotEmpty) {
                  _model.phone = value;
                }
              },
            ),
          ],
        ));
  }

  Widget _companyNameField(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              focusNode: _companyNameFocus,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              initialValue: _model.companyName,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffeeeeee))),
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Company',
              ),
              onFieldSubmitted: (e) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                _formKey.currentState!.save();
                return null;
              },
              onSaved: (String? value) {
                if (value!.isNotEmpty) {
                  _model.companyName = value;
                }
              },
            ),
          ],
        ));
  }

  Widget _passwordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          TextFormField(
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.next,
              enabled: !_loading,
              obscureText: !_showPassword,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1)),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffeeeeee))),
                  hintStyle: Theme.of(context).textTheme.bodyText1,
                  hintText: 'Password',
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        size: 14.sp),
                  )),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 8) {
                  return 'Please enter password atleast 8 character long';
                }
                _formKey.currentState!.save();
                return null;
              },
              onFieldSubmitted: (e) =>
                  FocusScope.of(context).requestFocus(_confirmFocus),
              onSaved: (String? value) {
                if (value!.isNotEmpty) {
                  _model.password = value;
                }
              })
        ],
      ),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            focusNode: _confirmFocus,
            enabled: !_loading,
            obscureText: true,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffeeeeee))),
              hintStyle: Theme.of(context).textTheme.bodyText1,
              hintText: 'Confirm Password',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a confirm password';
              } else if (value != _model.password) {
                return 'Password do not match';
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  Widget _agreeField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _agreed = !_agreed;
              });
            },
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 3, color: Colors.black.withOpacity(.1))),
              child: _agreed ? const Icon(Icons.check, size: 18) : Container(),
            ),
          ),
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  top: 5,
                ),
                child: RichText(
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                      const TextSpan(text: 'I agree to carpet\'s '),
                      TextSpan(
                          text: 'Terms of Services',
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  ?.color)),
                      const TextSpan(text: ' and '),
                      TextSpan(
                          text: 'Privacy Policy.',
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  ?.color)),
                    ]))),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
            child: PrimaryButton(
              title: btnTitle(),
              disabled: !_agreed || _loading,
              inverted: _success,
              onPressed: () => submit(context),
            ),
          ),
        ]));
  }

  String btnTitle() {
    if (_loading) return 'Loading...';
    if (_success) return 'Registration successful!';
    return 'Create Account';
  }

  void submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();

        setState(() {
          _loading = true;
        });

        await AuthRepository().register(
          email: _model.email,
          firstName: _model.firstName,
          lastName: _model.lastName,
          phone: _model.phone,
          password: _model.password,
          companyName: _model.companyName,
        );

        setState(() {
          _success = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Registration successful. We will reach out to you and get you onboard very soon.')));
      } catch (e) {
        AppError error = AppError.fromError(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Timer> login(BuildContext context) async =>
      Timer(const Duration(seconds: 2), () {
        context.read<AuthBloc>().add(
            AuthLoginEvent(email: _model.email, password: _model.password));
      });
}

/*
 * Register Form data datatype
 */
class _RegisterFormModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  String companyName;

  _RegisterFormModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.companyName,
  });
}
