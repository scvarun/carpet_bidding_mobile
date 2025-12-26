import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/routes/orders/order_add_screen.dart';
import 'package:carpet_app/routes/orders/order_single_screen.dart';
import 'package:carpet_app/services/messages.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/models/order.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:sizer/sizer.dart';

class AdminOrderReceivedStockListScreen extends StatelessWidget {
  static const routeName = '/admin/received';

  const AdminOrderReceivedStockListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminOrderReceivedStockListRender();
        }
        return Container();
      },
    );
  }
}

class _AdminOrderReceivedStockListRender extends StatefulWidget {
  const _AdminOrderReceivedStockListRender({Key? key}) : super(key: key);

  @override
  State<_AdminOrderReceivedStockListRender> createState() =>
      __AdminOrderReceivedStockListRenderState();
}

class __AdminOrderReceivedStockListRenderState
    extends State<_AdminOrderReceivedStockListRender> {
  late Future _getOrders;
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );
  final _searchQueryController = TextEditingController();
  late String _query = '';
  final _stream = StreamController.broadcast();

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
    _stream.stream.asBroadcastStream().listen((e) {
      setState(() {
        _getOrders = _loadOrders(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Received Stock',
      child: StreamBuilder(
        stream: _stream.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _orderListFuture(context);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
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
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _ordersTable(BuildContext context, List<ApiOrder> orders) {
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      const Text('Sort by:'),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
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
            dataRowHeight: 40,
            headingRowHeight: 40,
            bottomMargin: 0,
            horizontalMargin: 10,
            minWidth: 1500,
            border: TableBorder.all(color: Colors.black26),
            columns: [
              _columnTitle(context, 'Product', size: ColumnSize.M),
              _columnTitle(context, 'Dealer', size: ColumnSize.L),
              _columnTitle(context, 'Quantity', size: ColumnSize.S),
              _columnTitle(context, 'Type', size: ColumnSize.S),
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
    return DataRow(cells: [
      _cell(e.orderName, e),
      _cell(e.user?.name ?? '', e),
      _cell(e.quantity.toString(), e),
      _cell(e.type.toString().split('.').last, e),
      _cell(
          e.createdAt != null
              ? DateFormat('d MMM, y').format(e.createdAt!)
              : '',
          e),
      _cell(e.status?.status ?? '', e,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      _cell(e.notes ?? '', e,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    ]);
  }

  DataCell _cell(String text, ApiOrder e,
      {TextStyle? style = const TextStyle()}) {
    Color color = Colors.black;
    if (e.status!.slug == ApiOrderStatusTypes.new_enquiry) {
      color = Colors.red;
    } else if (e.status!.slug == ApiOrderStatusTypes.not_available) {
      color = Colors.cyan;
    } else if (e.status!.slug == ApiOrderStatusTypes.enquired) {
      color = Colors.yellow;
    } else if (e.status!.slug == ApiOrderStatusTypes.available) {
      color = Colors.green;
    }
    return DataCell(
      Text(text,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: color)
              .merge(style)),
      onTap: () => _onTap(context, e),
    );
  }

  Future _loadOrders(BuildContext context) async {
    var types = [
      ApiOrderStatusTypes.received_stock,
    ];
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await order_repo.loadOrders(auth, type: types);
  }
}
