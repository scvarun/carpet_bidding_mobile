import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/index.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/users/users_repo.dart';
import 'package:sizer/sizer.dart';
import 'package:validators/validators.dart' as validator;

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _ProfileRender();
        return Container();
      },
    );
  }
}

class _ProfileRender extends StatefulWidget {
  const _ProfileRender({Key? key}) : super(key: key);

  @override
  State<_ProfileRender> createState() => __ProfileRenderState();
}

class __ProfileRenderState extends State<_ProfileRender> {
  final _formKey = GlobalKey<FormState>();
  late Future _getProfile;
  late ApiUser _model;
  late bool _showPassword = false;
  var _loading = false;

  @override
  void initState() {
    _getProfile = _loadProfile(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Edit Profile',
      child: FutureBuilder(
        future: _getProfile,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return _form(context);
            } else {
              return const Text('Invalid user');
            }
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _emailField(context),
            _passwordField(context),
            _confirmPasswordField(context),
            _fullNameField(context),
            _companyNameField(context),
            _gstField(context),
            _phoneField(context),
            _addressField(context),
            _insidePuneField(context),
            if (_model.userProfile?.insidePune == false) _cityField(context),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: _cancelButton(context),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: _updateButton(context),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Email'),
          TextFormField(
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.email,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
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
        ],
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Password'),
          TextFormField(
              enabled: !_loading,
              obscureText: !_showPassword,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              style: Theme.of(context).textTheme.bodyText1,
              initialValue: _model.password,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Password',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                suffix: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  child: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (value) {
                _formKey.currentState!.save();
                return null;
              },
              onSaved: (String? value) {
                if (value != null) {
                  _model.password = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Confirm Password'),
          TextFormField(
              enabled: !_loading,
              obscureText: true,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              style: Theme.of(context).textTheme.bodyText1,
              initialValue: _model.password,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Confirm Password',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
              ),
              validator: (value) {
                if (_model.password!.isNotEmpty && value != _model.password) {
                  return 'Password do not match';
                }
                return null;
              }),
        ],
      ),
    );
  }

  Widget _fullNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Full Name'),
          TextFormField(
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: (_model.firstName ?? '') + " " + (_model.lastName ?? ''),
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Full Name',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
              ),
              onSaved: (String? value) {
                if (value != null) {
                  _model.name = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _companyNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Company Name'),
          TextFormField(
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile!.companyName,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Company Name',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
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

  Widget _gstField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'GST No.'),
          TextFormField(
              enabled: !_loading,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile!.gst,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'GST No.',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
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
                  _model.userProfile!.gst = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Phone No.'),
          TextFormField(
              enabled: !_loading,
              keyboardType: TextInputType.phone,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile!.phone,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Phone No.',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
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
        ],
      ),
    );
  }

  Widget _cityField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'City'),
          TextFormField(
              enabled: !_loading,
              keyboardType: TextInputType.text,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile?.city ?? '',
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'City',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
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
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Label(title: 'Address (optional)'),
          TextFormField(
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              initialValue: _model.userProfile!.address,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyText1,
                hintText: 'Address (Optional)',
                filled: true,
                fillColor: Colors.white,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 2.0),
                ),
              ),
              validator: (value) {
                _formKey.currentState?.save();
                return null;
              },
              onSaved: (String? value) {
                if (value != null) {
                  _model.userProfile!.address = value;
                }
              }),
        ],
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: _loading,
              child: PrimaryButton(
                inverted: true,
                color: Theme.of(context).colorScheme.secondary,
                title: 'Cancel',
                disabled: _loading,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          )
        ]));
  }

  Widget _updateButton(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: _loading,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: 'Update',
                disabled: _loading,
                onPressed: () => _update(context),
              ),
            ),
          )
        ]));
  }

  Future<ApiUser?> _loadProfile(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var user =
        await UserRepo().loadUser(authState.auth, authState.auth.user!.uuid);
    setState(() {
      _model = user;
    });
    return user;
  }

  Future _update(BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      if (_formKey.currentState!.validate()) {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        await UserRepo().updateUser(authState.auth, _model);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You have updated profile successfully')));
      } else {
        throw AppError.fromError('Please check all fields');
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
}
