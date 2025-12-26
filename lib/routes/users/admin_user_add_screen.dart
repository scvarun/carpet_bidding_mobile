import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/components/forms.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/users/users_repo.dart';
import 'package:sizer/sizer.dart';
import 'package:validators/validators.dart' as validator;

class AdminUserAddScreen extends StatelessWidget {
  static const routeName = '/admin/users/add';

  const AdminUserAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminUserAddRender();
        }
        return Container();
      },
    );
  }
}

class _AdminUserAddRender extends StatefulWidget {
  const _AdminUserAddRender({Key? key}) : super(key: key);

  @override
  State<_AdminUserAddRender> createState() => __AdminUserAddRenderState();
}

class __AdminUserAddRenderState extends State<_AdminUserAddRender> {
  final _formKey = GlobalKey<FormState>();
  late var _userType = ApiUserTypes.admin;
  late final _model = ApiUser(
      uuid: '',
      firstName: '',
      lastName: '',
      email: '',
      userProfile: ApiUserProfile(
        companyName: '',
        address: '',
        city: '',
        phone: '',
        gst: '',
        insidePune: true,
      ));
  var _showPassword = false;
  var _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Users',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.chevron_left,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText2!.fontSize!) * 1.4),
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: Text('Back',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _userTypeField(context),
                  Row(
                    children: [
                      Expanded(child: _firstNameField(context)),
                      Expanded(child: _lastNameField(context)),
                    ],
                  ),
                  _emailField(context),
                  _passwordField(context),
                  _phoneField(context),
                  _companyNameField(context),
                  _addressField(context),
                  _insidePuneField(context),
                  if (_model.userProfile?.insidePune == false)
                    _cityField(context),
                  _submitButton(context),
                ]),
          )),
    );
  }

  Widget _userTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('User Type', style: TextStyle(fontSize: 10.sp)),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: (Theme.of(context).textTheme.bodyText1!.fontSize)! * 4,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              color: Colors.white,
              border: Border.all(color: Colors.black38, width: 1)),
          child: DropdownButton<ApiUserTypes>(
            underline: Container(),
            isExpanded: true,
            itemHeight: Theme.of(context).textTheme.bodyText1!.height,
            value: _userType,
            items: ApiUserTypes.values
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.toString().split('.').last.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(),
                    )))
                .toList(),
            onChanged: (v) => setState(() {
              if (v != null) _userType = v;
            }),
          ),
        ),
      ],
    );
  }

  Widget _firstNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, right: 10),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.firstName,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'First Name',
            labelText: 'First Name',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.name = value;
            }
          }),
    );
  }

  Widget _lastNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 10),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.lastName,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Last Name',
            labelText: 'Last Name',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.lastName = value;
            }
          }),
    );
  }

  Widget _emailField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
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
            border: const OutlineInputBorder(),
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
          onSaved: (String? value) {
            if (value != null) {
              _model.email = value;
            }
          }),
    );
  }

  Widget _passwordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          obscureText: !_showPassword,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          style: Theme.of(context).textTheme.bodyText1,
          initialValue: _model.password,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
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

  Widget _phoneField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          keyboardType: TextInputType.phone,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.userProfile!.phone,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Phone',
            labelText: 'Phone',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter phone';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.userProfile!.phone = value;
            }
          }),
    );
  }

  Widget _companyNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile!.companyName,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Company Name',
                labelText: 'Company Name',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                _formKey.currentState?.save();
                return null;
              },
              onSaved: (String? value) {
                if (value != null) {
                  _model.userProfile!.companyName = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _cityField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          keyboardType: TextInputType.text,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.email,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'City',
            labelText: 'City',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.userProfile!.city = value;
            }
          }),
    );
  }

  Widget _insidePuneField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: const Label(title: 'Inside Pune?'))),
          Switch(
            value: _model.userProfile?.insidePune ?? false,
            onChanged: (value) {
              setState(() {
                if (_model.userProfile != null) {
                  _model.userProfile!.insidePune = value;
                }
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _addressField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.userProfile!.address,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Address',
            labelText: 'Address',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.userProfile!.address = value;
            }
          }),
    );
  }

  Widget _submitButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String btnText = 'Add';
    if (loading) {
      btnText = 'Loading...';
    } else if (success) {
      btnText = 'Added Successful';
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
    setState(() {
      _loading = true;
    });
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        await UserRepo().addUser(auth, _model, _userType);
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}
