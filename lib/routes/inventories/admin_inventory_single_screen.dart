import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:carpet_app/store/inventories/inventories_repo.dart'
    as inventory_repo;
import 'package:carpet_app/store/importers/importers_repo.dart'
    as importer_repo;

class _AdminInventorySingleArgs {
  final String uuid;
  final ApiInventoryTypes type;
  _AdminInventorySingleArgs({required this.uuid, required this.type});
}

class AdminInventorySingleScreen extends StatelessWidget {
  static const routeName = '/admin/inventories/single';

  const AdminInventorySingleScreen({Key? key}) : super(key: key);

  static _AdminInventorySingleArgs args(
      {required String uuid, required ApiInventoryTypes type}) {
    return _AdminInventorySingleArgs(uuid: uuid, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as _AdminInventorySingleArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return _AdminInventorySingleRender(args: args);
        }
        return Container();
      },
    );
  }
}

class _AdminInventorySingleRender extends StatefulWidget {
  final _AdminInventorySingleArgs args;

  const _AdminInventorySingleRender({Key? key, required this.args})
      : super(key: key);

  @override
  State<_AdminInventorySingleRender> createState() =>
      __AdminInventorySingleRenderState();
}

class __AdminInventorySingleRenderState
    extends State<_AdminInventorySingleRender> {
  late Future _getImporters;
  late Future _getInventories;
  late Future _getInventory;
  late List<ApiImporter> _importers = [];
  late List<ApiImporter> _availableImporters;
  final _formKey = GlobalKey<FormState>();
  final _loading = false;
  var _success = false;
  late List<ApiInventory> _availableInventories;
  late ApiInventory _inventory;
  late List<ApiInventory> _similarInventories = [];

  @override
  void initState() {
    super.initState();
    _getInventory = _loadInventory(context);
    _getImporters = _loadImporters(context);
    _getInventories = _loadInventories(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Inventory',
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
        future: Future.wait(
            <Future>[_getInventory, _getImporters, _getInventories]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _render(context);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // _info(context),
            _form(context),
            _importerField(context),
            Row(
              children: [
                Expanded(child: Container(child: _submitButton(context))),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: _cancelButton(context))),
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: _removeButton(context))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _info(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Catalogue',
                  style: TextStyle(
                    color: Colors.black87,
                  )),
            ),
            Expanded(child: Text(_inventory.catalogue!.name)),
          ],
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_inventory.isType(ApiInventoryTypes.rolls))
          Column(
            children: [
              if (_inventory.inventoryType == ApiInventoryTypes.rolls)
                _patternNoField(context),
              _rateField(context),
              _sizeField(context),
            ],
          ),
        _quantityField(context),
        if (_inventory.isType(ApiInventoryTypes.rolls)) _similarItems(context),
        if (_inventory.isType(ApiInventoryTypes.catalog)) _catalogNameField(context),
      ],
    );
  }

  Widget _quantityField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          keyboardType: TextInputType.number,
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _inventory.quantity.toString(),
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Quantity',
            labelText: 'Quantity',
            contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(
                  color: Color(0xffeeeeee),
                  style: BorderStyle.solid,
                )),
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
              _inventory.quantity = int.parse(value);
            }
          }),
    );
  }

  Widget _sizeField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _inventory.catalogue?.size ?? '',
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
            hintText: 'Size',
            labelText: 'Size',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null && _inventory.roll != null) {
              _inventory.catalogue!.size = value;
            }
          }),
    );
  }

  Widget _catalogNameField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _inventory.catalogue?.name ?? '',
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintText: 'Catalog name',
            labelText: 'Catalog name',
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
              _inventory.catalogue?.name = value;
            }
          }),
    );
  }

  Widget _patternNoField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _inventory.roll?.patternNo ?? '',
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintText: 'Pattern No.',
            labelText: 'Pattern No.',
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
              _inventory.roll?.patternNo = value;
            }
          }),
    );
  }

  Widget _rateField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _inventory.catalogue?.rate ?? '',
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
            hintText: 'Rate',
            labelText: 'Rate',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null && _inventory.roll != null) {
              _inventory.catalogue!.rate = value;
            }
          }),
    );
  }

  Widget _similarItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownSearch<ApiInventory>.multiSelection(
        mode: Mode.BOTTOM_SHEET,
        showSearchBox: true,
        showClearButton: true,
        emptyBuilder: (context, searchEntry) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text('No catalogues found',
              style: Theme.of(context).textTheme.bodyText1),
        ),
        dropdownSearchDecoration: const InputDecoration(
            label: Text('Similar Items'),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20)),
        searchFieldProps: TextFieldProps(
            decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Search',
          hintText: 'Search',
        )),
        itemAsString: (item) {
          if (_inventory.isType(ApiInventoryTypes.rolls)) {
            return item!.roll?.patternNo ?? '';
          } else if (_inventory.isType(ApiInventoryTypes.catalog)) {
            return item!.catalogue?.name ?? '';
          }
          return '';
        },
        items: _availableInventories,
        selectedItems: _similarInventories,
        onChanged: (e) {
          setState(() {
            _similarInventories = e;
          });
        },
      ),
    );
  }

  Widget _importerField(BuildContext context) {
    if (_inventory.isType(ApiInventoryTypes.rolls)) {
      return Container();
    }
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            ..._importers.asMap().keys.map((e) => Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _importers.removeAt(e);
                        });
                      },
                      child: const Icon(Icons.close)),
                  Expanded(
                    child: Text(_importers[e].name ?? '',
                        style: Theme.of(context).textTheme.bodyText1),
                  )
                ]))),
            TextButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text('Add Importer'),
                            content: SizedBox(
                                height: 200.sp,
                                width: 100.sp,
                                child: ListView.builder(
                                    itemCount: _availableImporters.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          setState(() {
                                            var i = _importers.indexWhere((e) =>
                                                e.uuid ==
                                                _availableImporters[index]
                                                    .uuid);
                                            if (i == -1) {
                                              _importers.add(
                                                  _availableImporters[index]);
                                            }
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        title: Text(
                                            _availableImporters[index].name ??
                                                ''),
                                      );
                                    })));
                      });
                },
                child: Text('Add Importer',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        )))
          ],
        ));
  }

  bool get _canSubmit {
    return _inventory.quantity != null && _inventory.quantity! >= 0;
  }

  Widget _submitButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    String btnText = 'Update';
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
                disabled: !_canSubmit || loading,
                inverted: success,
                onPressed: () => _submit(context),
              ),
            ),
          )
        ]));
  }

  Widget _cancelButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: loading || success,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: 'Cancel',
                disabled: loading,
                inverted: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          )
        ]));
  }

  Widget _removeButton(BuildContext context,
      {bool loading = false, bool success = false}) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: loading || success,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: 'Remove',
                disabled: loading,
                inverted: true,
                onPressed: () async {
                  var proceed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Deleteing inventory?'),
                          content: const Text(
                              'Are you sure you want todelete this inventory?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('No')),
                          ],
                        );
                      });
                  if (proceed == true) {
                    _remove(context);
                  }
                },
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
        await inventory_repo.updateInventory(auth,
            importers: _importers,
            inventory: _inventory,
            similarInventories: _similarInventories);
        setState(() {
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventory saved successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      }
    }
  }

  void _remove(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        await inventory_repo.removeInventory(auth, _inventory.uuid ?? '');
        setState(() {
          _success = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventory removed successfully')));
        Navigator.of(context).pop('refresh');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      }
    }
  }

  Future<List<ApiImporter>?> _loadImporters(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var importers = await importer_repo.loadImporters(auth);
    setState(() {
      if (importers != null) {
        _availableImporters = importers;
      }
    });
    return importers;
  }

  Future<ApiInventory?> _loadInventory(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var inventory = await inventory_repo.loadInventory(auth, widget.args.uuid);
    setState(() {
      if (inventory != null) {
        _inventory = inventory;
        _importers = inventory.importers ?? [];
        _similarInventories = inventory.similarInventories ?? [];
        _getInventories = _loadInventories(context);
      }
    });
    return inventory;
  }

  Future<List<ApiInventory>?> _loadInventories(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var inventories =
        await inventory_repo.loadInventories(auth, widget.args.type);
    setState(() {
      if (inventories != null) {
        _availableInventories = inventories.inventories;
      }
    });
    return inventories.inventories;
  }
}
