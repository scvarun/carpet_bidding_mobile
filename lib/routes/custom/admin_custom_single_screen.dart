import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/custom_order.dart';
import 'package:carpet_app/models/media.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/custom/custom_repo.dart' as custom_repo;
import 'package:path/path.dart' as p;
import 'package:sizer/sizer.dart';

class _AdminCustomSingleScreenArgs {
  String uuid;
  _AdminCustomSingleScreenArgs({required this.uuid});
}

class AdminCustomSingleScreen extends StatelessWidget {
  static const routeName = '/admin/custom/single';

  const AdminCustomSingleScreen({Key? key}) : super(key: key);

  static _AdminCustomSingleScreenArgs args({required String uuid}) {
    return _AdminCustomSingleScreenArgs(uuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as _AdminCustomSingleScreenArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return _AdminCustomSingleRender(args);
        return Container();
      },
    );
  }
}

class _AdminCustomSingleRender extends StatefulWidget {
  final _AdminCustomSingleScreenArgs args;

  const _AdminCustomSingleRender(this.args, {Key? key}) : super(key: key);

  @override
  State<_AdminCustomSingleRender> createState() =>
      __AdminCustomSingleRenderState();
}

class __AdminCustomSingleRenderState extends State<_AdminCustomSingleRender> {
  late Future _getCustom;
  late ApiCustomOrder _order;
  late bool _editActive = false;

  @override
  void initState() {
    super.initState();
    _getCustom = _loadOrder(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Custom Order',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.chevron_left,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText1!.fontSize!) * 1.4),
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: Text('Back',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: FutureBuilder(
        future: _getCustom,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (_editActive) {
              return _EditOrderRender(snapshot.data);
            } else {
              return _render(context, snapshot.data);
            }
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _render(BuildContext context, ApiCustomOrder customOrder) {
    List<_CustomOrderRow> rows = [
      _CustomOrderRow('Customized Title', customOrder.title ?? ''),
      _CustomOrderRow('Customer Name', customOrder.name ?? ''),
      _CustomOrderRow('Phone', customOrder.phone ?? ''),
      _CustomOrderRow('Size', customOrder.width ?? ''),
      _CustomOrderRow('Size', customOrder.height ?? ''),
      _CustomOrderRow('Remarks', customOrder.remarks ?? ''),
    ];

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50.sp, bottom: 30.sp),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                image: customOrder.image?.url != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(customOrder.image!.url!),
                      )
                    : null,
              ),
            ),
            ...rows.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(e.title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(e.value)),
                    )
                  ],
                ),
              );
            }).toList(),
            Center(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                ),
                onPressed: () {
                  setState(() {
                    _editActive = true;
                  });
                },
                child: const Text('Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<ApiCustomOrder?> _loadOrder(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var order = await custom_repo.loadCustomOrder(auth, widget.args.uuid);
    if (order != null) {
      setState(() {
        _order = order;
      });
    }
    return order;
  }
}

class _CustomOrderRow {
  String title;
  String value;
  _CustomOrderRow(this.title, this.value) : super();
}

class _EditOrderRender extends StatefulWidget {
  final ApiCustomOrder customOrder;

  const _EditOrderRender(this.customOrder, {Key? key}) : super(key: key);

  @override
  __EditOrderRenderState createState() => __EditOrderRenderState();
}

class __EditOrderRenderState extends State<_EditOrderRender> {
  final _formKey = GlobalKey<FormState>();
  final _model = ApiCustomOrder(
      name: '', phone: '', remarks: "", title: '', width: "", height: "");
  late final _loading = false;
  late var _success = false;
  late bool _settingImage = false;
  late ApiMedia? _media;

  @override
  void initState() {
    super.initState();
    _model.uuid = widget.customOrder.uuid;
    _model.name = widget.customOrder.name;
    _model.title = widget.customOrder.title;
    _model.remarks = widget.customOrder.remarks;
    _model.phone = widget.customOrder.phone;
    _model.width = widget.customOrder.width;
    _model.height = widget.customOrder.height;
    _media = widget.customOrder.image;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(children: [
              _nameField(context),
              _titleField(context),
              _phoneField(context),
              _widthField(context),
              _heightField(context),
              _remarksField(context),
              _imageField(context),
              _submitButton(context)
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
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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

  Widget _titleField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.title,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Title',
            labelText: 'Title',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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
              _model.title = value;
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
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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

  Widget _widthField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.width,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Size',
            labelText: 'Size',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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
              _model.width = value;
            }
          }),
    );
  }

  Widget _heightField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.height,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Size',
            labelText: 'Size',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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
              _model.height = value;
            }
          }),
    );
  }

  Widget _remarksField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _model.remarks,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Remarks',
            labelText: 'Remarks',
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 1)),
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
              _model.remarks = value;
            }
          }),
    );
  }

  Widget _imageField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _setImage(context);
      },
      child: Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            image: _media?.url != null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_media!.url!),
                  )
                : null,
          ),
          child: _settingImage
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Icon(Icons.camera_alt,
                      color: _media != null ? Colors.white : Colors.black))),
    );
  }

  Widget _submitButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String btnText = 'Update';
    if (loading) {
      btnText = 'Loading...';
    } else if (success) {
      btnText = 'Update Successful';
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: loading || success,
              child: Container(
                padding: const EdgeInsets.only(right: 10),
                child: PrimaryButton(
                  color: Theme.of(context).colorScheme.secondary,
                  title: "Cancel",
                  disabled: loading,
                  inverted: success,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          Expanded(
            child: AbsorbPointer(
              absorbing: loading || success,
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: PrimaryButton(
                  color: Theme.of(context).colorScheme.secondary,
                  title: btnText,
                  disabled: loading,
                  inverted: success,
                  onPressed: () => _submit(context),
                ),
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
        await custom_repo.updateCustomOrder(auth, _model, _media);
        setState(() {
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Custom order updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      }
    }
  }

  _setImage(BuildContext context) async {
    setState(() {
      _settingImage = true;
    });
    AuthLoggedInState authState;
    try {
      authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        var file = File(result.files.single.path!);

        String filename = p.basename(file.path);
        var formData = FormData.fromMap({
          'media': await MultipartFile.fromFile(file.path, filename: filename),
        });
        var response = await Dio().post('${CONFIG.expressApiUrl}/upload',
            data: formData,
            options: Options(
                headers: {'Authorization': authState.auth.bearerToken()}));
        var jsonResponse = json.decode(response.toString());
        var medias = (jsonResponse['media'] as List)
            .map((e) => ApiMedia.fromJSON(e))
            .toList();

        setState(() {
          _media = medias[0];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
    } finally {
      setState(() {
        _settingImage = false;
      });
    }
  }
}
