import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/routes/orders/order_single_screen.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:sizer/sizer.dart';

class _BackofficeOrderListArgs {
  final ApiOrderStatusTypes? type;
  _BackofficeOrderListArgs({this.type});
}

class BackofficeOrderListScreen extends StatelessWidget {
  static const routeName = '/backoffice/orders';

  const BackofficeOrderListScreen({Key? key}) : super(key: key);

  static _BackofficeOrderListArgs args({ApiOrderStatusTypes? type}) {
    return _BackofficeOrderListArgs(type: type);
  }

  @override
  Widget build(BuildContext context) {
    _BackofficeOrderListArgs? args = (ModalRoute.of(context)!
        .settings
        .arguments) as _BackofficeOrderListArgs?;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return _BackofficeOrderListRender(args: args);
        }
        return Container();
      },
    );
  }
}

class _BackofficeOrderListRender extends StatefulWidget {
  final _BackofficeOrderListArgs? args;

  const _BackofficeOrderListRender({Key? key, required this.args})
      : super(key: key);

  @override
  State<_BackofficeOrderListRender> createState() =>
      __BackofficeOrderListRenderState();
}

class __BackofficeOrderListRenderState
    extends State<_BackofficeOrderListRender> {
  late Future _getOrders;
  final ScrollController horizontalScroll = ScrollController();
  final ScrollController verticalScroll = ScrollController();
  final _searchQueryController = TextEditingController();
  late String _query = '';
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _getOrders = _loadOrders(context);
    _searchQueryController.addListener(() {
      setState(() {
        _query = _searchQueryController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'All Orders',
      child: FutureBuilder(
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
      ),
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
            dataRowHeight: 40,
            headingRowHeight: 40,
            bottomMargin: 0,
            horizontalMargin: 10,
            minWidth: 1300,
            border: TableBorder.all(color: Colors.black26),
            columns: [
              DataColumn2(label: Text('Product'.toUpperCase())),
              DataColumn2(label: Text('Dealer'.toUpperCase())),
              DataColumn2(label: Text('Type'.toUpperCase())),
              DataColumn2(label: Text('Date'.toUpperCase())),
              DataColumn2(label: Text('Status'.toUpperCase())),
              DataColumn2(label: Text('Dealer'.toUpperCase())),
              DataColumn2(label: Text('Quantity'.toUpperCase())),
            ],
            empty: Container(
                margin: const EdgeInsets.only(top: 30),
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

  _onTap(BuildContext context, ApiOrder e) {
    Navigator.of(context).pushNamed(OrderSingleScreen.routeName,
        arguments: OrderSingleScreen.args(uuid: e.uuid!));
    setState(() {
      _getOrders = _loadOrders(context);
    });
  }

  DataRow? _row(BuildContext context, ApiOrder e) {
    return DataRow(cells: [
      DataCell(
        Text(e.orderName),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.user?.name ?? ''),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.type.toString().split('.').last),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        e.createdAt != null
            ? Text(DateFormat('d MMM y').format(e.createdAt!))
            : const Text(''),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.status?.status ?? ''),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.reference ?? ''),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.quantity.toString()),
        onTap: () => _onTap(context, e),
      ),
      if (0 == 1 && e.status?.slug == ApiOrderStatusTypes.order_confirmed)
        DataCell(
          TextButton(
              onPressed: () async {
                var proceed = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('Do you want to change status?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Proceed'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    });
                if (proceed == null) return;
                _receivedStock(context, e);
              },
              child: const Text('Received')),
        ),
      if (0 == 1 && e.status?.slug == ApiOrderStatusTypes.dispatched)
        DataCell(
          TextButton(
              onPressed: () async {
                var proceed = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('Do you want to change status?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Proceed'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    });
                if (proceed == null) return;
                _delievered(context, e);
              },
              child: const Text('Delivered')),
        ),
    ]);
  }

  Future _loadOrders(BuildContext context) async {
    var types = [
      ApiOrderStatusTypes.order_confirmed,
      ApiOrderStatusTypes.dispatched,
    ];

    if (widget.args != null &&
        widget.args!.type != null &&
        widget.args!.type == ApiOrderStatusTypes.order_confirmed) {
      types.removeWhere((e) => true);
      types.add(ApiOrderStatusTypes.order_confirmed);
    } else if (widget.args != null &&
        widget.args!.type != null &&
        widget.args!.type == ApiOrderStatusTypes.dispatched) {
      types.removeWhere((e) => true);
      types.add(ApiOrderStatusTypes.dispatched);
    }

    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var orders = await order_repo.loadOrders(auth,
        type: types,
        startDate: Jiffy(_dateTimeRange.start).startOf(Units.DAY).dateTime,
        endDate: Jiffy(_dateTimeRange.end).endOf(Units.DAY).dateTime);
    return orders;
  }

  Future<bool?> _receivedStock(BuildContext context, ApiOrder order) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      await order_repo.changeStatusBackoffice(
        auth,
        order: order,
        status: ApiOrderStatusTypes.received_stock,
      );
      setState(() {
        _getOrders = _loadOrders(context);
      });
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _delievered(BuildContext context, ApiOrder order) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      await order_repo.changeStatusBackoffice(
        auth,
        order: order,
        status: ApiOrderStatusTypes.completed,
      );
      setState(() {
        _getOrders = _loadOrders(context);
      });
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }
}
