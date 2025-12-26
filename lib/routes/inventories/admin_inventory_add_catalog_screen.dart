import 'dart:async';

import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:sizer/sizer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/inventories/inventories_repo.dart'
    as inventory_repo;
import 'package:carpet_app/store/importers/importers_repo.dart'
    as importer_repo;

class AdminInventoryAddCatalogScreen extends StatelessWidget {
  static const routeName = '/admin/inventories/addCatalog';

  const AdminInventoryAddCatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminInventoryAddCatalogRender();
        }
        return Container();
      },
    );
  }
}

class _AdminInventoryAddCatalogRender extends StatefulWidget {
  const _AdminInventoryAddCatalogRender({Key? key}) : super(key: key);

  @override
  State<_AdminInventoryAddCatalogRender> createState() =>
      __AdminInventoryAddCatalogRenderState();
}

class __AdminInventoryAddCatalogRenderState
    extends State<_AdminInventoryAddCatalogRender> {
  late Future _getCatalogues;
  late Future _getImporters;
  late ApiCatalogue? _catalogue;
  late List<ApiCatalogue>? _catalogues;
  late final List<inventory_repo.InventoryPatternData> _patterns = [];
  late final List<ApiImporter> _importers = [];
  late List<ApiImporter> _availableImporters;
  late String _catalogueName;
  late String _catalogueRate;
  late String _catalogueSize;
  final _rateFieldController = TextEditingController();
  final _sizeFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _loading = false;
  var _success = false;

  @override
  void initState() {
    super.initState();
    _getCatalogues = _loadCatalogues(context);
    _getImporters = _loadImporters(context);
    var pattern = inventory_repo.InventoryPatternData(
        quantity: 0, similarInventories: [], type: ApiInventoryTypes.catalog);
    _patterns.add(pattern);
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
        future: Future.wait(<Future>[_getCatalogues, _getImporters]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Form(
              key: _formKey,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _catalogueField(context),
                    _patternFields(context),
                    _importerField(context),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(right: 20),
                                child: _submitButton(context))),
                        Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: _cancelButton(context))),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _catalogueField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              var value = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Add new Catalogue'),
                      content: SingleChildScrollView(
                        child: ListBody(children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20, top: 10),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  _catalogueName = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Catalogue name",
                                hintText: "Catalogue name",
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  _catalogueSize = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Size",
                                hintText: "Size",
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                setState(() {
                                  _catalogueRate = value;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Rate",
                                hintText: "Rate",
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    if (_catalogueName.isNotEmpty) {
                                      return Navigator.of(context)
                                          .pop(_catalogueName);
                                    }
                                  },
                                  child: const Text('Submit')),
                              TextButton(
                                  onPressed: () {
                                    return Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'))
                            ],
                          )
                        ]),
                      ),
                    );
                  });
              if (value != null && value.isNotEmpty) {
                var state = context.read<AuthBloc>().state as AuthLoggedInState;
                var inventory = await inventory_repo.addCatalogue(
                  state.auth,
                  _catalogueName,
                  size: _catalogueSize,
                  rate: _catalogueRate,
                );
                setState(() {
                  _getCatalogues =
                      _loadCatalogues(context, preselectUUID: inventory!.uuid);
                });
              }
            },
            child: const Icon(Icons.add),
          ),
          Expanded(
            child: DropdownSearch<ApiCatalogue>(
              mode: Mode.BOTTOM_SHEET,
              showSearchBox: true,
              showClearButton: true,
              emptyBuilder: (context, searchEntry) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text('No catalogues found',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              searchFieldProps: TextFieldProps(
                  decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                hintText: 'Search',
              )),
              itemAsString: (item) => item!.name,
              items: _catalogues,
              selectedItem: _catalogue,
              onChanged: (e) {
                setState(() {
                  if (e != null) {
                    _catalogue = e;
                    _rateFieldController.text = _catalogue?.rate ?? '';
                    _sizeFieldController.text = _catalogue?.size ?? '';
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _patternFields(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._patterns.asMap().keys.map((e) => Container(
              color: Colors.black.withOpacity(.05),
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(_patterns[e]
                              .type
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase()),
                        ),
                        Row(
                          children: [
                            if (_patterns[e].type == ApiInventoryTypes.rolls)
                              Expanded(child: _patternNoField(context, e)),
                            Expanded(
                                child: _quantityField(context, e,
                                    disableMargin: _patterns[e].type ==
                                        ApiInventoryTypes.catalog)),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(child: _similarItems(context, e)),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ],
              ))),
          // Center(
          //   child: TextButton(
          //     onPressed: () async {
          //       setState(() {
          //         var pattern = inventory_repo.InventoryPatternData(
          //             quantity: 0,
          //             similarInventoryUUIDs: [],
          //             type: ApiInventoryTypes.catalog);
          //         _patterns.add(pattern);
          //       });
          //       // var type = await showDialog<ApiInventoryTypes>(
          //       //   context: context,
          //       //   builder: (context) {
          //       //     return AlertDialog(
          //       //       title: const Text('What kind of product?'),
          //       //       actions: [
          //       //         TextButton(
          //       //           onPressed: () {
          //       //             Navigator.of(context)
          //       //                 .pop(ApiInventoryTypes.catalog);
          //       //           },
          //       //           child: const Text('Catalog'),
          //       //         ),
          //       //         TextButton(
          //       //           onPressed: () {
          //       //             Navigator.of(context).pop(ApiInventoryTypes.rolls);
          //       //           },
          //       //           child: const Text('Rolls'),
          //       //         ),
          //       //         TextButton(
          //       //           onPressed: () {
          //       //             Navigator.of(context).pop();
          //       //           },
          //       //           child: const Text('Cancel'),
          //       //         ),
          //       //       ],
          //       //     );
          //       //   },
          //       // );
          //       // if (type != null) {
          //       //   if (type == ApiInventoryTypes.rolls) {
          //       //     setState(() {
          //       //       var pattern = inventory_repo.InventoryPatternData(
          //       //           quantity: 0,
          //       //           similarInventoryUUIDs: [],
          //       //           type: ApiInventoryTypes.rolls);
          //       //       _patterns.add(pattern);
          //       //     });
          //       //   } else if (type == ApiInventoryTypes.catalog) {
          //       //     setState(() {
          //       //       var pattern = inventory_repo.InventoryPatternData(
          //       //           quantity: 0,
          //       //           similarInventoryUUIDs: [],
          //       //           type: ApiInventoryTypes.catalog);
          //       //       _patterns.add(pattern);
          //       //     });
          //       //   }
          //       // }
          //     },
          //     child: Text('Add Pattern',
          //         style: Theme.of(context).textTheme.bodyText1!.copyWith(
          //               color: Theme.of(context).colorScheme.primary,
          //             )),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _patternNoField(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, right: 10),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _patterns[index].patternNo,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Pattern No.',
            labelText: 'Pattern No.',
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
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
              _patterns[index].patternNo = value;
            }
          }),
    );
  }

  Widget _quantityField(BuildContext context, int index,
      {bool disableMargin = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: disableMargin ? 0 : 10),
      child: TextFormField(
          keyboardType: TextInputType.number,
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _patterns[index].quantity.toString(),
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Quantity',
            labelText: 'Quantity',
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
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
              _patterns[index].quantity = int.parse(value);
            }
          }),
    );
  }

  Widget _similarItems(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _patterns[index].patternNo,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText1,
            hintText: 'Similar Items',
            labelText: 'Similar Items',
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
          ),
          validator: (value) {
            // if (value!.isEmpty) {
            //   return 'Please enter some text';
            // }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              // _patterns[index].patternNo = value;
            }
          }),
    );
  }

  Widget _importerField(BuildContext context) {
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
                                            _importers.add(
                                                _availableImporters[index]);
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
    return _catalogue != null && _patterns.isNotEmpty;
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
                inverted: success,
                onPressed: () => Navigator.of(context).pop(),
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
        await inventory_repo.addInventories(
          auth,
          catalogue: _catalogue!,
          importers: _importers,
          patterns: _patterns,
        );
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

  Future<List<ApiCatalogue>?> _loadCatalogues(BuildContext context,
      {String? preselectUUID}) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var catalogues = await inventory_repo.loadCatalogues(auth);
    setState(() {
      if (preselectUUID != null) {
        var preselect = catalogues!.where((e) => e.uuid == preselectUUID);
        if (preselect.isNotEmpty) _catalogue = preselect.first;
      } else {
        _catalogue = catalogues!.isNotEmpty ? catalogues.first : null;
        _catalogues = catalogues;
      }
    });
    return catalogues;
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
}
