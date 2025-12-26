import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/components/more_tabs.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/order_status_types.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/routes/orders/order_single_screen.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:sizer/sizer.dart';

class AdminArchiveListScreen extends StatelessWidget {
  static const routeName = '/admin/archives';

  const AdminArchiveListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _AdminArchiveListRender();
        return Container();
      },
    );
  }
}

class _AdminArchiveListRender extends StatefulWidget {
  const _AdminArchiveListRender({Key? key}) : super(key: key);

  @override
  State<_AdminArchiveListRender> createState() =>
      __AdminArchiveListRenderState();
}

class __AdminArchiveListRenderState extends State<_AdminArchiveListRender> {
  late Future _getOrders;
  late ApiOrderStatusTypes? _currentStatus = ApiOrderStatusTypes.all;
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );
  final _searchQueryController = TextEditingController();
  late String _query = '';

  @override
  void initState() {
    _getOrders = _loadOrders(context);
    _searchQueryController.addListener(() {
      setState(() {
        _query = _searchQueryController.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Orders',
      child: Column(
        children: [
          const MoreTabs(currentTab: MoreTabsOptions.archive),
          Expanded(
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
          ),
        ],
      ),
    );
  }

  Widget _ordersTable(BuildContext context, List<ApiOrder> orders) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: const BoxDecoration(
              color: Colors.black12,
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Sort by:'),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButton<ApiOrderStatusTypes>(
                          isDense: true,
                          style: Theme.of(context).textTheme.bodyText1,
                          underline: Container(),
                          value: _currentStatus,
                          items: ApiOrderStatusTypes.values
                              .where((e) {
                                switch (e) {
                                  case ApiOrderStatusTypes.all:
                                  case ApiOrderStatusTypes.cancelled:
                                  case ApiOrderStatusTypes.completed:
                                    return true;
                                  default:
                                    return false;
                                }
                              })
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
                ))),
        Expanded(
          child: DataTable2(
            columnSpacing: 20,
            dataRowHeight: 40,
            headingRowHeight: 40,
            bottomMargin: 0,
            horizontalMargin: 10,
            minWidth: 1000,
            border: TableBorder.all(color: Colors.black26),
            columns: [
              _columnTitle(context, 'Date'),
              _columnTitle(context, 'Status'),
              _columnTitle(context, 'Dealer'),
              _columnTitle(context, 'Type'),
              _columnTitle(context, 'Catalogue'),
              _columnTitle(context, 'Quantity'),
            ],
            empty: const Text('No orders to display'),
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

  DataColumn _columnTitle(BuildContext context, String title) {
    return DataColumn(
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
    if (e.status != null && e.status?.slug == ApiOrderStatusTypes.completed) {
      color = Colors.green;
    } else if (e.status != null &&
        e.status!.slug == ApiOrderStatusTypes.cancelled) {
      color = Colors.red;
    }
    return DataRow(cells: [
      DataCell(
        Text(
            e.createdAt != null
                ? DateFormat('d MMM, y').format(e.createdAt!)
                : '',
            style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.status?.status ?? '', style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.user?.name ?? '', style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.type.toString().split('.').last, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.catalogue?.name ?? '', style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.quantity.toString(), style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
    ]);
  }

  Future _loadOrders(BuildContext context) async {
    var types = [
      ApiOrderStatusTypes.completed,
      ApiOrderStatusTypes.cancelled,
    ];

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
}
