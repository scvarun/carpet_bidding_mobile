import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:validators/validators.dart' as validator;
import 'package:carpet_app/store/importers/importers_repo.dart'
    as importer_repo;

class AdminImporterAddScreen extends StatelessWidget {
  static const routeName = '/admin/importers/add';

  const AdminImporterAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminImporterAddRender();
        }
        return Container();
      },
    );
  }
}

class _AdminImporterAddRender extends StatefulWidget {
  const _AdminImporterAddRender({Key? key}) : super(key: key);

  @override
  State<_AdminImporterAddRender> createState() =>
      __AdminImporterAddRenderState();
}

class __AdminImporterAddRenderState extends State<_AdminImporterAddRender> {
  final _formKey = GlobalKey<FormState>();
  final _model = ApiImporter(name: '', email: '', phone: "", city: '');
  final _loading = false;
  var _success = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Importers',
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
            child: Column(children: [
              _nameField(context),
              _emailField(context),
              _phoneField(context),
              _cityField(context),
              _addressField(context),
              _submitButton(context),
            ]),
          )),
    );
  }

  Widget _nameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.name,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Name',
            labelText: 'Name',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black12)),
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
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black12)),
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

  Widget _phoneField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          keyboardType: TextInputType.phone,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.phone,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Phone',
            labelText: 'Phone',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black12)),
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
              _model.phone = value;
            }
          }),
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
          initialValue: _model.city,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'City',
            labelText: 'City',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black12)),
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
              _model.city = value;
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
          initialValue: _model.address,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Address',
            labelText: 'Address',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black12)),
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
              _model.address = value;
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
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        await importer_repo.addImporter(auth, _model);
        setState(() {
          _success = true;
        });
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      }
    }
  }
}
