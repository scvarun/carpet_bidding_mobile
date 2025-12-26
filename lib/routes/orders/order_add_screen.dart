import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:carpet_app/components/buttons.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/users/users_repo.dart';
import 'package:sizer/sizer.dart';
import 'package:carpet_app/store/inventories/inventories_repo.dart'
    as inventory_repo;
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:carpet_app/models/user.dart';

class OrderCreateScreen extends StatelessWidget {
  static const routeName = '/orders/add';

  const OrderCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _OrderCreateRender();
        return Container();
      },
    );
  }
}

class _OrderCreateRender extends StatefulWidget {
  const _OrderCreateRender({Key? key}) : super(key: key);

  @override
  State<_OrderCreateRender> createState() => __OrderCreateRenderState();
}

class __OrderCreateRenderState extends State<_OrderCreateRender> {
  late ApiInventoryTypes _activeTab = ApiInventoryTypes.rolls;
  late Future _getCatalogues;

  @override
  void initState() {
    _getCatalogues = _loadCatalogues(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: false,
      title: 'Orders',
      disableAppBar: true,
      child: FutureBuilder(
        future: _getCatalogues,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Container(
                margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
                child: Column(
                  children: [
                    _tabs(context),
                    if (_activeTab == ApiInventoryTypes.rolls)
                      _RollsForm(
                          catalogues: snapshot.data,
                          type: ApiInventoryTypes.rolls)
                    else if (_activeTab == ApiInventoryTypes.catalog)
                      _RollsForm(
                          catalogues: snapshot.data,
                          type: ApiInventoryTypes.catalog)
                  ],
                ),
              );
            } else {
              return const Text('invalid response');
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabsSingle(context, ApiInventoryTypes.rolls),
        _tabsSingle(context, ApiInventoryTypes.catalog),
      ],
    );
  }

  Widget _tabsSingle(BuildContext context, ApiInventoryTypes type) {
    var title = '';
    switch (type) {
      case ApiInventoryTypes.rolls:
        title = 'Rolls';
        break;
      case ApiInventoryTypes.catalog:
        title = 'Catalog';
        break;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 3,
                    color: _activeTab == type
                        ? Colors.black12
                        : Colors.transparent))),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: _activeTab == type
                ? Theme.of(context).colorScheme.primary
                : Colors.black54,
          ),
        ),
      ),
    );
  }

  Future<List<ApiCatalogue>?> _loadCatalogues(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return inventory_repo.loadCatalogues(auth);
  }
}

class _RollsForm extends StatefulWidget {
  final ApiInventoryTypes type;
  final List<ApiCatalogue> catalogues;

  const _RollsForm({Key? key, required this.catalogues, required this.type})
      : super(key: key);

  @override
  State<_RollsForm> createState() => __RollsFormState();
}

class __RollsFormState extends State<_RollsForm> {
  final _formKey = GlobalKey<FormState>();
  late final _loading = false;
  late final _success = false;
  late var _reference = '';
  late var _quantity = 0;
  late var _patternNo = '';
  late Future _getUsers;
  late ApiCatalogue? _catalogue;
  late bool? _isAvailable;
  late ApiInventory? _selectedInventory;
  late ApiInventory? _loadedInventory;
  late List<ApiInventory> _inventories;
  final _controller = TextEditingController();
  final _rateFieldController = TextEditingController();
  late ApiUser? _user = null;
  late List<ApiUser> _users = [];

  @override
  void initState() {
    if (widget.type == ApiInventoryTypes.catalog) {
      _catalogue = widget.catalogues.first;
    } else {
      _catalogue = null;
    }
    _isAvailable = null;
    _selectedInventory = null;
    _loadedInventory = null;
    _controller.addListener(() {
      setState(() {
        _patternNo = _controller.text;
      });
      Timer(const Duration(seconds: 1), () {
        if (_loadedInventory != null &&
            _loadedInventory!.roll!.patternNo! == _controller.text) {
          setState(() {
            _catalogue = _loadedInventory!.catalogue;
            _rateFieldController.text = _catalogue!.rate ?? '';
          });
        } else {
          setState(() {
            _catalogue = null;
            _loadedInventory = null;
          });
        }
      });
    });
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    if (authState.auth.user!.userType!.isType(ApiUserTypes.admin)) {
      _getUsers = _loadDealers();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    return Form(
        key: _formKey,
        child: Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                if (authState.auth.user!.userType!.isType(ApiUserTypes.admin))
                  _userField(context),
                _referenceField(context),
                if (widget.type == ApiInventoryTypes.rolls)
                  _patternNoField(context),
                _catalogueField(context),
                _quantityField(context),
                if (widget.type == ApiInventoryTypes.rolls &&
                    _loadedInventory != null)
                  _rateField(context),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            // margin: const EdgeInsets.only(right: 10),
                            child: _checkAvailabilityBtn(context))),
                    Expanded(
                        child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: _orderButton(
                                context, ApiOrderStatusTypes.placed_order))),
                  ],
                )
              ],
            )));
  }

  Widget _userField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: DropdownSearch<ApiUser>(
        mode: Mode.BOTTOM_SHEET,
        showSearchBox: true,
        showClearButton: true,
        emptyBuilder: (context, searchEntry) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text('No user found',
              style: Theme.of(context).textTheme.bodyText1),
        ),
        searchFieldProps: TextFieldProps(
            decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Search',
          hintText: 'Search',
        )),
        itemAsString: (item) => item!.name,
        items: _users,
        selectedItem: _user,
        onChanged: (u) {
          setState(() {
            _user = u;
          });
        },
      ),
    );
  }

  Widget _referenceField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            enabled: !_loading,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            initialValue: _reference,
            style: Theme.of(context).textTheme.bodyText2,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyText2,
              hintText: 'Reference',
              labelText: 'Reference',
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
              _formKey.currentState!.save();
              return null;
            },
            onSaved: (String? value) {
              if (value!.isNotEmpty) {
                _reference = value;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _patternNoField(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: TypeAheadField<ApiInventory>(
          minCharsForSuggestions: 4,
          hideOnEmpty: true,
          hideOnError: true,
          hideOnLoading: true,
          textFieldConfiguration: TextFieldConfiguration(
              controller: _controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search Pattern',
                  labelText: 'Search Pattern')),
          suggestionsCallback: (pattern) async {
            return await _loadInventorySuggestions(context, pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion.roll!.patternNo!),
              subtitle: Text(suggestion.catalogue!.name),
            );
          },
          onSuggestionSelected: (suggestion) {
            setState(() {
              _controller.text = suggestion.roll!.patternNo!;
              _loadedInventory = suggestion;
            });
          },
        ));
  }

  Widget _catalogueField(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: DropdownSearch<ApiCatalogue>(
          mode: Mode.BOTTOM_SHEET,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
              style: Theme.of(context).textTheme.bodyText2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                hintText: 'Search',
              )),
          emptyBuilder: (context, searchEntry) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text('No catalogues found',
                style: Theme.of(context).textTheme.bodyText2),
          ),
          dropdownSearchDecoration: const InputDecoration(
            hintText: 'Catalogues',
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 2.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 2.0),
            ),
          ),
          enabled: widget.type != ApiInventoryTypes.rolls,
          itemAsString: (item) => item?.name ?? '',
          items: widget.catalogues,
          selectedItem: _catalogue,
          onChanged: (e) {
            setState(() {
              _catalogue = e;
            });
          },
        ));
  }

  Widget _quantityField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
          keyboardType: TextInputType.number,
          enabled: !_loading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          initialValue: _quantity.toString(),
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.bodyText2,
            hintText: 'Quantity',
            labelText: 'Quantity',
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
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
            } else if (int.parse(value) <= 0) {
              return 'Please enter valid quantity';
            }
            _formKey.currentState?.save();
            return null;
          },
          onSaved: (String? value) {
            if (value != null) {
              _quantity = int.parse(value);
            }
          }),
    );
  }

  Widget _rateField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _rateFieldController,
            enabled: false,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: Theme.of(context).textTheme.bodyText2,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyText2,
              hintText: 'Rate',
              labelText: 'Rate',
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 2.0),
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _checkAvailabilityBtn(BuildContext context) {
    String btnText = 'Check Availability';
    if (_loading) {
      btnText = 'Loading...';
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: _loading,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: btnText,
                disabled: _loading,
                onPressed: () => _checkAvailability(context),
                style: TextStyle(fontSize: 11.sp, color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              ),
            ),
          )
        ]));
  }

  Widget _orderButton(BuildContext context, ApiOrderStatusTypes status) {
    String btnText = 'Place Order';
    if (_loading) {
      btnText = 'Loading...';
    } else if (_success) {
      btnText = 'Added Successfully';
    } else if (_isAvailable != null && _isAvailable! == false) {
      btnText = 'Enquiry';
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(children: [
          Expanded(
            child: AbsorbPointer(
              absorbing: _loading,
              child: PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                title: btnText,
                disabled: _loading,
                onPressed: () => _order(context, status),
                style: TextStyle(fontSize: 11.sp, color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              ),
            ),
          )
        ]));
  }

  Future _order(BuildContext context, ApiOrderStatusTypes status) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        if (auth.user!.userType!.isType(ApiUserTypes.admin) && _user == null) {
          throw Exception('User is not selected');
        }
        await order_repo.createOrder(auth,
            user: _user,
            reference: _reference,
            quantity: _quantity,
            inventory: _selectedInventory,
            catalogue: _catalogue,
            type: widget.type,
            patternNo: _patternNo,
            status: status);
        if (status == ApiOrderStatusTypes.new_enquiry) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enquiry added successfully, redirecting...')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Order added successfully, redirecting...')));
        }
        if (authState.auth.user!.userType!.isType(ApiUserTypes.admin)) {
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pushNamed(AdminOrderListScreen.routeName);
          });
        } else {
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pushNamed(OrderListScreen.routeName);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
      }
    }
  }

  Future<bool?> _checkAvailability(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        var auth = await refreshToken(context, authState);
        var response = await order_repo.checkAvailability(auth,
            patternNo:
                widget.type == ApiInventoryTypes.rolls ? _patternNo : null,
            quantity: _quantity,
            catalogue: _catalogue);
        if (response != null) {
          setState(() {
            _isAvailable = response.isAvailable;
            _selectedInventory = response.inventory;
          });
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text('Order'),
                  content: Text(response.message,
                      style: Theme.of(context).textTheme.bodyText1),
                  actions: [
                    _orderButton(
                        context,
                        response.isAvailable
                            ? ApiOrderStatusTypes.placed_order
                            : ApiOrderStatusTypes.new_enquiry)
                  ]);
            },
          );
          return response.isAvailable;
        } else {
          setState(() {
            _selectedInventory = null;
            _isAvailable = false;
          });
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text('Order'),
                  content: Text('Product is not available',
                      style: Theme.of(context).textTheme.bodyText1),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Okay'),
                    )
                  ]);
            },
          );
          return false;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppError.fromError(e).toString())));
        return false;
      }
    } else {
      return false;
    }
  }

  Future<ApiInventory?> _loadInventory(
      BuildContext context, String text) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var inventory = await inventory_repo.suggestInventories(auth, text);
      setState(() {
        _catalogue = inventory?.catalogue;
      });
      return inventory;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
    }
    return null;
  }

  Future<Iterable<ApiInventory>> _loadInventorySuggestions(
      BuildContext context, String text) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var inventories = await inventory_repo.suggestInventoriesList(auth, text);
      return inventories;
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<List<ApiUser>?> _loadDealers() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var users = await UserRepo().loadUserList(auth, ApiUserTypes.dealer);
    setState(() {
      _users = users;
    });
    return users;
  }
}
