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

class _AdminUserSingleArgs {
  String uuid;
  _AdminUserSingleArgs({required this.uuid});
}

class AdminUserSingleScreen extends StatelessWidget {
  static const routeName = '/admin/users/single';

  const AdminUserSingleScreen({Key? key}) : super(key: key);

  static _AdminUserSingleArgs args({required String uuid}) {
    return _AdminUserSingleArgs(uuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as _AdminUserSingleArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return _AdminUserSingleRender(args: args);
        }
        return Container();
      },
    );
  }
}

class _AdminUserSingleRender extends StatefulWidget {
  final _AdminUserSingleArgs args;

  const _AdminUserSingleRender({Key? key, required this.args})
      : super(key: key);

  @override
  State<_AdminUserSingleRender> createState() => __AdminUserSingleRenderState();
}

class __AdminUserSingleRenderState extends State<_AdminUserSingleRender> {
  final _formKey = GlobalKey<FormState>();
  late var _userType = ApiUserTypes.admin;
  late var _model = ApiUser(
      uuid: '',
      firstName: '',
      lastName: '',
      email: '',
      blocked: null,
      userProfile: ApiUserProfile(
        companyName: '',
        address: '',
        city: '',
        phone: '',
        gst: '',
      ));
  var _showPassword = false;
  var _loading = false;
  late Future _getUser;

  @override
  void initState() {
    super.initState();
    _getUser = _loadUser(context);
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
      child: FutureBuilder(
        future: _getUser,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _render(context);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _render(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _userTypeField(context),
            Row(
              children: [
                Expanded(child: _firstNameField(context)),
                Expanded(child: _lastNameField(context)),
              ],
            ),
            _emailField(context),
            _companyField(context),
            _passwordField(context),
            _phoneField(context),
            _addressField(context),
            _insidePuneField(context),
            if (_model.userProfile?.insidePune == false) _cityField(context),
            _blockButton(context),
            _submitButton(context),
          ]),
        ));
  }

  Widget _userTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('User Type', style: TextStyle(fontSize: 10.sp)),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 20),
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
            labelText: "First Name",
            hintText: 'First Name',
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
            labelText: "Last Name",
            hintText: 'Last Name',
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
            labelText: "Email",
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
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

  Widget _companyField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          textInputAction: TextInputAction.next,
          initialValue: _model.userProfile?.companyName,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Company',
            labelText: "Company",
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _model.userProfile?.companyName = value;
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
              labelText: 'Password',
              hintText: 'Password',
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
            labelText: 'Phone',
            hintText: 'Phone',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter phone';
            } else if (!RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(value)) {
              return 'Please enter valid phone';
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

  Widget _cityField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          keyboardType: TextInputType.text,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.userProfile?.city,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            labelText: 'City',
            hintText: 'City',
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
            labelText: 'Address',
            hintText: 'Address',
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

  Widget _blockButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String? btnText;
    if (_model.blocked != null && _model.blocked! == true) {
      btnText = 'Unblock';
    } else if (_model.blocked != null && _model.blocked! == false) {
      btnText = 'Block';
    }

    if (btnText == null) {
      return Container();
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: PrimaryButton(
              color: Theme.of(context).colorScheme.secondary,
              title: btnText,
              disabled: loading,
              inverted: true,
              onPressed: () {
                if (_model.blocked != null && _model.blocked! == false) {
                  _block(context);
                } else if (_model.blocked != null && _model.blocked! == true) {
                  _unblock(context);
                }
              },
            ),
          )
        ]));
  }

  Widget _submitButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String btnText = 'Update';
    if (loading) {
      btnText = 'Loading...';
    } else if (success) {
      btnText = 'Updated Successful';
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
    try {
      if (_formKey.currentState!.validate()) {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        await UserRepo().updateUser(auth, _model);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User profile updated successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _block(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      await UserRepo().blockUser(auth, _model);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile blocked successfully')));
      setState(() {
        _getUser = _loadUser(context);
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

  void _unblock(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      await UserRepo().unblockUser(auth, _model);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile unblocked successfully')));
      setState(() {
        _getUser = _loadUser(context);
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

  Future<ApiUser?> _loadUser(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var model = await UserRepo().loadUser(auth, widget.args.uuid);
    setState(() {
      _model = model;
      _userType = model.userType!.type!;
    });
    return model;
  }
}
