import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/order_status_types.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/routes/orders/order_add_screen.dart';
import 'package:carpet_app/routes/orders/order_single_screen.dart';
import 'package:carpet_app/services/messages.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:sizer/sizer.dart';

class AdminOrderListScreen extends StatelessWidget {
  static const routeName = '/admin/orders';

  const AdminOrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _AdminOrderListRender();
        return Container();
      },
    );
  }
}

class _AdminOrderListRender extends StatefulWidget {
  const _AdminOrderListRender({Key? key}) : super(key: key);

  @override
  State<_AdminOrderListRender> createState() => __AdminOrderListRenderState();
}

class __AdminOrderListRenderState extends State<_AdminOrderListRender> {
  late Future _getOrders;
  late ApiOrderStatusTypes? _currentStatus = ApiOrderStatusTypes.all;
  final _searchQueryController = TextEditingController();
  late String _query = '';
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );
  final _stream = StreamController.broadcast();
  late bool _allOrders = true;

  @override
  void initState() {
    super.initState();
    _getOrders = _loadOrders(context);
    _searchQueryController.addListener(() {
      setState(() {
        _query = _searchQueryController.text;
      });
    });
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    _stream.addStream(
        MessageService().listOrders(authState.auth).asBroadcastStream());
    _connect();
  }

  _connect() {
    debugPrint('Connecting to server');
    _stream.stream.asBroadcastStream().listen((e) {
      setState(() {
        _getOrders = _loadOrders(context);
      });
    }, onDone: () {
      debugPrint('Stream Disconnected. Trying again in 5 seconds');
      Timer(const Duration(seconds: 5), () {
        _connect();
      });
    }, onError: (e) {
      debugPrint('Stream Disconnected. Trying again in 5 seconds');
      Timer(const Duration(seconds: 5), () {
        _connect();
      });
    }, cancelOnError: false);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      headerAddon:
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Checkbox(
            value: _allOrders,
            checkColor: Theme.of(context).colorScheme.primary,
            fillColor: MaterialStateProperty.all(Colors.white),
            onChanged: (v) {
              setState(() {
                if (v != null) {
                  _allOrders = v;
                  _currentStatus = ApiOrderStatusTypes.all;
                  _getOrders = _loadOrders(context);
                }
              });
            }),
        Text('All Orders',
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Colors.white)),
      ]),
      removeScroll: true,
      title: 'Orders',
      child: StreamBuilder(
        stream: _stream.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return _orderListFuture(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(OrderCreateScreen.routeName);
          }),
    );
  }

  Widget _orderListFuture(BuildContext context) {
    return FutureBuilder(
      future: _getOrders,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return _ordersTable(context, snapshot.data);
          } else {
            return const Text('Invalid order list');
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _ordersTable(BuildContext context, List<ApiOrder> orders) {
    var types = [
      ApiOrderStatusTypes.all,
      ApiOrderStatusTypes.placed_order,
      ApiOrderStatusTypes.order_confirmed,
      ApiOrderStatusTypes.received_stock,
      ApiOrderStatusTypes.dispatched,
    ];
    if (_allOrders) {
      types = [
        ApiOrderStatusTypes.all,
        ApiOrderStatusTypes.not_available,
        ApiOrderStatusTypes.new_enquiry,
        ApiOrderStatusTypes.enquired,
        ApiOrderStatusTypes.available,
        ApiOrderStatusTypes.placed_order,
        ApiOrderStatusTypes.order_confirmed,
        ApiOrderStatusTypes.received_stock,
        ApiOrderStatusTypes.dispatched,
      ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Sort by:'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButton<ApiOrderStatusTypes>(
                            isDense: true,
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
                                  _getOrders = _loadOrders(context);
                                })),
                      ),
                      TextButton(
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
                              _getOrders = _loadOrders(context);
                            });
                          }
                        },
                        child: Text(
                          '${DateFormat('d MMM').format(_dateTimeRange.start)} - ${DateFormat('d MMM').format(_dateTimeRange.end)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 160.sp,
                        height: 28.sp,
                        child: TextField(
                          controller: _searchQueryController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Search',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _searchQueryController.clear();
                                },
                                icon: Icon(_query.isNotEmpty
                                    ? Icons.clear
                                    : Icons.search)),
                          ),
                        ),
                      )
                    ],
                  ),
                ))),
        Expanded(
          child: DataTable2(
            columnSpacing: 20,
            headingRowHeight: 40,
            bottomMargin: 0,
            horizontalMargin: 10,
            minWidth: 1500,
            border: TableBorder.all(color: Colors.black26),
            columns: [
              _columnTitle(context, 'Product', size: ColumnSize.M),
              _columnTitle(context, 'Dealer', size: ColumnSize.L),
              _columnTitle(context, 'Type', size: ColumnSize.S),
              _columnTitle(context, 'Date', size: ColumnSize.S),
              _columnTitle(context, 'Date', size: ColumnSize.S),
              _columnTitle(context, 'Status', size: ColumnSize.S),
              _columnTitle(context, 'Remarks', size: ColumnSize.M),
            ],
            empty: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text('No orders to display')),
            rows: orders
                .where((e) {
                  if (_searchQueryController.text.isNotEmpty) {
                    if (e.reference != null &&
                        e.reference!
                            .toLowerCase()
                            .contains(_query.toLowerCase())) {
                      return true;
                    }
                    if (e.patternNo != null &&
                        e.patternNo!
                            .toLowerCase()
                            .contains(_query.toLowerCase())) {
                      return true;
                    }
                    if (e.catalogue?.name != null &&
                        e.catalogue!.name
                            .toLowerCase()
                            .contains(_query.toLowerCase())) {
                      return true;
                    }
                    if (e.user?.name != null &&
                        e.user!.name
                            .toLowerCase()
                            .contains(_query.toLowerCase())) {
                      return true;
                    }
                    return false;
                  }
                  return true;
                })
                .map((e) => _row(context, e))
                .cast<DataRow>()
                .toList(),
          ),
        ),
      ],
    );
  }

  DataColumn _columnTitle(BuildContext context, String title,
      {ColumnSize size = ColumnSize.M}) {
    return DataColumn2(
      size: size,
      label: Text(title.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  _onTap(BuildContext context, ApiOrder e) async {
    await Navigator.of(context).pushNamed(OrderSingleScreen.routeName,
        arguments: OrderSingleScreen.args(uuid: e.uuid!));
    setState(() {
      _getOrders = _loadOrders(context);
    });
  }

  DataRow? _row(BuildContext context, ApiOrder e) {
    Color? color = Colors.black;
    if (e.status?.slug == ApiOrderStatusTypes.placed_order || e.status!.slug == ApiOrderStatusTypes.new_enquiry) {
      color = Colors.red;
    } else {
      color = Colors.blue;
    }
    return DataRow(cells: [
      DataCell(
        Text(e.orderName,
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.user?.name ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.quantity.toString(),
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.type.toString().split('.').last,
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(
            e.createdAt != null
                ? DateFormat('d MMM, y').format(e.createdAt!)
                : '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.status?.status ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.notes ?? '',
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        onTap: () => _onTap(context, e),
      ),
    ]);
  }

  Future _loadOrders(BuildContext context) async {
    var types = [
      ApiOrderStatusTypes.placed_order,
      ApiOrderStatusTypes.order_confirmed,
      ApiOrderStatusTypes.received_stock,
      ApiOrderStatusTypes.dispatched,
    ];

    if (_allOrders) {
      types = [
        ApiOrderStatusTypes.not_available,
        ApiOrderStatusTypes.new_enquiry,
        ApiOrderStatusTypes.enquired,
        ApiOrderStatusTypes.available,
        ApiOrderStatusTypes.placed_order,
        ApiOrderStatusTypes.order_confirmed,
        ApiOrderStatusTypes.received_stock,
        ApiOrderStatusTypes.dispatched,
      ];
    }

    if (_currentStatus != ApiOrderStatusTypes.all) {
      types.removeWhere((e) => true);
      types.add(_currentStatus!);
    }

    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var orders = await order_repo.loadOrders(auth,
        type: types,
        startDate: _dateTimeRange.start,
        endDate: _dateTimeRange.end);
    return orders;
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}
