import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/order_status_types.dart';
import 'package:carpet_app/lib/payment_types.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/custom_order.dart';
import 'package:carpet_app/models/delivery.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:carpet_app/store/orders/order_repo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:carpet_app/store/inventories/inventories_repo.dart'
    as inventory_repo;
import 'package:validators/validators.dart' as validator;

enum _Tabs { orders, customOrders, deliveries }

class AdminReportsScreen extends StatelessWidget {
  static const routeName = '/admin/reports';

  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _AdminReportsRender();
        return Container();
      },
    );
  }
}

class _AdminReportsRender extends StatefulWidget {
  const _AdminReportsRender({Key? key}) : super(key: key);

  @override
  State<_AdminReportsRender> createState() => __AdminReportsRenderState();
}

class __AdminReportsRenderState extends State<_AdminReportsRender> {
  late Future<ReportsOutput?> _getReports;
  late ApiOrderStatusTypes? _currentStatus = ApiOrderStatusTypes.all;
  final _userFieldController = TextEditingController();
  late String _userField = '';
  final _patternNoController = TextEditingController();
  late String _patternNoField = '';
  late String? _paymentType;
  late bool _insidePune = true;
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );
  final bool _downloading = false;
  late String? _downloadUrl;
  late Future _getCatalogues;
  late List<ApiCatalogue> _catalogues = [];
  late ApiCatalogue? _catalogue;
  late _Tabs _selectedTab = _Tabs.orders;
  final _formKey = GlobalKey<FormState>();
  final _passwordFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentType = null;
    _catalogue = null;
    _getCatalogues = _loadCatalogues(context);
    _getReports = _loadReports(context);
    _userFieldController.addListener(() {
      _userField = _userFieldController.text;
    });
    _patternNoController.addListener(() {
      _patternNoField = _patternNoController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        removeScroll: true,
        title: 'Reports',
        headerAddon: Row(
          children: [
            TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                ),
                onPressed: () => _filterOptions(context),
                child: const Center(
                    child: Icon(Icons.filter_alt, color: Colors.white))),
            TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                ),
                onPressed: () => setState(() {
                      _catalogue = null;
                      _getReports = _loadReports(context);
                    }),
                child: const Center(
                    child: Icon(Icons.refresh, color: Colors.white))),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.03)),
                child: Row(
                  children: _Tabs.values.map((e) {
                    var text = '';
                    switch (e) {
                      case _Tabs.orders:
                        text = 'Orders';
                        break;
                      case _Tabs.customOrders:
                        text = 'Custom Orders';
                        break;
                      case _Tabs.deliveries:
                        text = 'Deliveries';
                        break;
                    }
                    return GestureDetector(
                      onTap: () async {
                        if (e == _Tabs.deliveries) {
                          var a = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Enter password'),
                                  content: Container(
                                    margin: const EdgeInsets.only(
                                        top: 5, bottom: 10),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter password';
                                        }
                                        _formKey.currentState!.save();
                                        return null;
                                      },
                                      obscureText: true,
                                      controller: _passwordFieldController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        height: 1.3,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          _passwordFieldController.clear();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () async {
                                          try {

                                            var authState = context
                                                .read<AuthBloc>()
                                                .state as AuthLoggedInState;
                                            await AuthRepository().login(
                                                email: authState
                                                        .auth.user!.email ??
                                                    '',
                                                password:
                                                    _passwordFieldController
                                                        .value.text);
                                            _passwordFieldController.clear();
                                            Navigator.of(context).pop(true);
                                          } catch (e) {
                                            var error = AppError.fromError(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        error.toString())));
                                            Navigator.of(context).pop();
                                            _passwordFieldController.clear();
                                            return Future.error(error);
                                          }
                                        },
                                        child: const Text('Submit'))
                                  ],
                                );
                              });
                          if (a != true) return;
                        }
                        setState(() {
                          _selectedTab = e;
                        });
                      },
                      child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            color: _selectedTab == e
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black,
                          ),
                          child: Text(text,
                              style: const TextStyle(color: Colors.white))),
                    );
                  }).toList(),
                )),
            Expanded(
              child: FutureBuilder(
                future: Future.wait([_getReports, _getCatalogues]),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return const Center(
                          child: Text('Could not load reports'));
                    }
                    if (_selectedTab == _Tabs.orders) {
                      return _ordersRender(context, snapshot.data![0].orders);
                    } else if (_selectedTab == _Tabs.customOrders) {
                      return _customOrdersRender(
                          context, snapshot.data![0].customOrders);
                    } else if (_selectedTab == _Tabs.deliveries) {
                      return _deliveriesRender(
                          context, snapshot.data![0].deliveries);
                    }
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!_downloading) {
                _downloadReports(context);
              }
            },
            child: _downloading
                ? const CircularProgressIndicator()
                : const Icon(Icons.download, color: Colors.white)));
  }

  _filterOptions(BuildContext context) async {
    const types = ApiOrderStatusTypes.values;

    var proceed = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: ListBody(
                    children: [
                      Text('User: ',
                          style: Theme.of(context).textTheme.bodySmall),
                      Container(
                        height: 36.sp,
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        child: TextField(
                          controller: _userFieldController,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.3,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _userFieldController.clear();
                                },
                                icon: Icon(_userField.isNotEmpty
                                    ? Icons.clear
                                    : Icons.search)),
                          ),
                        ),
                      ),
                      Text('Pattern No: ',
                          style: Theme.of(context).textTheme.bodySmall),
                      Container(
                        height: 36.sp,
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        child: TextField(
                          controller: _patternNoController,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _patternNoController.clear();
                                },
                                icon: Icon(_patternNoField.isNotEmpty
                                    ? Icons.clear
                                    : Icons.search)),
                          ),
                        ),
                      ),
                      Text('Status: ',
                          style: Theme.of(context).textTheme.bodySmall),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 36.sp,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownButton<ApiOrderStatusTypes>(
                            isExpanded: true,
                            style: Theme.of(context).textTheme.bodyText1,
                            underline: Container(),
                            value: _currentStatus,
                            items: types
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(orderStatusTypesStr(e))))
                                .toList(),
                            onChanged: (e) => setState(() {
                                  _currentStatus = e;
                                })),
                      ),
                      if (_selectedTab == _Tabs.deliveries)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Payment Type: ',
                                style: Theme.of(context).textTheme.bodySmall),
                            Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 20),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: 36.sp,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black12, width: 2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: DropdownButton<String>(
                                  isExpanded: true,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  underline: Container(),
                                  value: _paymentType,
                                  items: [
                                    const DropdownMenuItem(
                                        value: null, child: Text("All")),
                                    ...paymentTypes
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList()
                                  ],
                                  onChanged: (e) => setState(() {
                                        _paymentType = e;
                                      })),
                            ),
                            Text('Password: ',
                                style: Theme.of(context).textTheme.bodySmall),
                            Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 10),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  _formKey.currentState!.save();
                                  return null;
                                },
                                obscureText: true,
                                controller: _passwordFieldController,
                                keyboardType: TextInputType.visiblePassword,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  height: 1.3,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Text('Catalog: ',
                          style: Theme.of(context).textTheme.bodySmall),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 36.sp,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownButton<ApiCatalogue>(
                            isExpanded: true,
                            style: Theme.of(context).textTheme.bodyText1,
                            underline: Container(),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('All')),
                              ..._catalogues
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e.name)))
                                  .toList()
                            ],
                            onChanged: (e) => setState(() {
                                  _catalogue = e;
                                })),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: Text('Inside Pune?: ',
                                  style: Theme.of(context).textTheme.bodySmall),
                            )),
                            Switch(
                              value: _insidePune,
                              onChanged: (value) {
                                setState(() {
                                  _insidePune = value;
                                });
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      Text('Date: ',
                          style: Theme.of(context).textTheme.bodySmall),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                          ),
                          onPressed: () async {
                            var dateTimeRange = await showDateRangePicker(
                                context: context,
                                firstDate: Jiffy().startOf(Units.YEAR).dateTime,
                                lastDate: Jiffy().endOf(Units.MONTH).dateTime);
                            if (dateTimeRange != null) {
                              setState(() {
                                _dateTimeRange = dateTimeRange;
                              });
                            }
                          },
                          child: Text(
                            '${DateFormat('d MMM').format(_dateTimeRange.start)} - ${DateFormat('d MMM').format(_dateTimeRange.end)}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                _passwordFieldController.clear();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  _passwordFieldController.clear();
                                  Navigator.of(context).pop(true);
                                }
                              },
                              child: const Text('Submit')),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
    if (proceed == null) return null;
    try {
      if (_selectedTab == _Tabs.deliveries) {
        var authState = context.read<AuthBloc>().state as AuthLoggedInState;
        await AuthRepository().login(
            email: authState.auth.user!.email ?? '',
            password: _passwordFieldController.toString());
      }
      setState(() {
        _getReports = _loadReports(context);
      });
    } catch (e) {
      var error = AppError.fromError(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _ordersRender(BuildContext context, List<ApiOrder>? orders) {
    if (orders == null) {
      return const Center(child: Text('Could not load reports'));
    }
    return DataTable2(
      columnSpacing: 20,
      dataRowHeight: 80,
      headingRowHeight: 40,
      bottomMargin: 0,
      horizontalMargin: 10,
      minWidth: 1500,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Product'),
        _columnTitle(context, 'Dealer'),
        _columnTitle(context, 'Quantity'),
        _columnTitle(context, 'Date'),
        _columnTitle(context, 'Status'),
        _columnTitle(context, 'Type'),
      ],
      empty: const Text('No orders to display'),
      rows: orders
          .where((e) {
            return e.user?.userProfile?.insidePune == _insidePune;
          })
          .map((e) => _orderRow(context, e))
          .cast<DataRow>()
          .toList(),
    );
  }

  Widget _customOrdersRender(
      BuildContext context, List<ApiCustomOrder>? customOrders) {
    if (customOrders == null) {
      return const Center(child: Text('Could not load reports'));
    }
    return DataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      bottomMargin: 0,
      horizontalMargin: 10,
      minWidth: 800,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Name'),
        _columnTitle(context, 'Title'),
        _columnTitle(context, 'Width'),
        _columnTitle(context, 'Height'),
        _columnTitle(context, 'Phone'),
        _columnTitle(context, 'Remarks'),
        _columnTitle(context, 'Date'),
      ],
      empty: const Text('No orders to display'),
      rows: customOrders
          .map((e) => _customOrderRow(context, e))
          .cast<DataRow>()
          .toList(),
    );
  }

  Widget _deliveriesRender(
      BuildContext context, List<ApiDelivery>? deliveries) {
    if (deliveries == null) {
      return const Center(child: Text('Could not load reports'));
    }
    return DataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      bottomMargin: 0,
      horizontalMargin: 10,
      minWidth: 1400,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Dealer'),
        _columnTitle(context, 'Delivered Units'),
        _columnTitle(context, 'Payment Type'),
        _columnTitle(context, 'Notes'),
        _columnTitle(context, 'Date'),
        _columnTitle(context, 'Acc. Approved?'),
      ],
      empty: const Text('No deliveries to display'),
      rows: deliveries
          .where((e) {
            if (_paymentType != null) {
              return e.paymentType == _paymentType;
            }
            return true;
          })
          .where((e) {
            return e.order?.user?.userProfile?.insidePune == _insidePune;
          })
          .map((e) => _deliveryRow(context, e))
          .cast<DataRow>()
          .toList(),
    );
  }

  DataColumn _columnTitle(BuildContext context, String title) {
    return DataColumn2(
      label: Text(title.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  DataRow? _orderRow(BuildContext context, ApiOrder e) {
    return DataRow(cells: [
      DataCell(
        Text(e.orderName),
      ),
      DataCell(
        Text(e.user?.name ?? ''),
      ),
      DataCell(
        Text(e.quantity.toString()),
      ),
      DataCell(
        Text(e.createdAt != null
            ? DateFormat('d MMM, y').format(e.createdAt!)
            : ''),
      ),
      DataCell(
        Text(e.status?.status ?? ''),
      ),
      DataCell(
        Text(e.type.toString().split('.').last),
      ),
    ]);
  }

  DataRow? _customOrderRow(BuildContext context, ApiCustomOrder e) {
    return DataRow(cells: [
      DataCell(
        Text(e.name ?? ''),
      ),
      DataCell(
        Text(e.title ?? ''),
      ),
      DataCell(
        Text(e.width ?? ''),
      ),
      DataCell(
        Text(e.height ?? ''),
      ),
      DataCell(
        Text(e.phone ?? ''),
      ),
      DataCell(
        Text(e.remarks ?? ''),
      ),
      DataCell(
        Text(e.createdAt != null
            ? DateFormat('d MMM, y').format(e.createdAt!)
            : ''),
      ),
    ]);
  }

  DataRow? _deliveryRow(BuildContext context, ApiDelivery e) {
    return DataRow(cells: [
      DataCell(
        Text(e.order?.user?.name ?? ''),
      ),
      DataCell(
        Text(e.delivered.toString()),
      ),
      DataCell(
        Text(e.paymentType ?? ''),
      ),
      DataCell(
        Text(e.notes ?? ''),
      ),
      DataCell(
        Text(e.createdAt != null
            ? DateFormat('d MMM, y').format(e.createdAt!)
            : ''),
      ),
      DataCell(Checkbox(
        onChanged: (bool? value) {
          if (value != null) {
            _setReadByAccounting(context, e, value);
          }
        },
        value: e.readByAccounting ?? false,
      )),
    ]);
  }

  Future<order_repo.ReportsOutput?> _loadReports(BuildContext context) async {
    try {
      var types = ApiOrderStatusTypes.values
          .where((e) => e != ApiOrderStatusTypes.all)
          .toList();

      if (_currentStatus != ApiOrderStatusTypes.all) {
        types.removeWhere((e) => true);
        types.add(_currentStatus!);
      }

      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var orders = await order_repo.loadReports(auth,
          catalogUUID: _catalogue?.uuid,
          dealerName: _userField,
          patternNo: _patternNoField,
          type: types,
          startDate: _dateTimeRange.start,
          endDate: _dateTimeRange.end);

      setState(() {
        _downloadUrl = orders?.reportsUrl;
      });
      return orders;
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<void> _downloadReports(BuildContext context) async {
    try {
      if (_downloadUrl == null) return;
      var response = await Dio().get(_downloadUrl!);
      var bytes = Uint8List.fromList(utf8.encode(response.data));
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/' +
          'reports--' +
          DateFormat('d-M-y').format(DateTime.now()) +
          '.xlsx');
      await file.writeAsBytes(bytes);
      OpenFile.open(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded ${file.path}')));
    } catch (e) {
      var error = AppError.fromError(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return Future.error(error);
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

  Future<bool?> _setReadByAccounting(
      BuildContext context, ApiDelivery delivery, bool isRead) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var order = await order_repo.setReadByAccounting(
        auth,
        delivery: delivery,
        isRead: isRead,
      );
      setState(() {
        _catalogue = null;
        _getCatalogues = _loadCatalogues(context);
        _getReports = _loadReports(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }
}
