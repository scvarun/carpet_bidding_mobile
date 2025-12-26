import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/components/more_tabs.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/delivery.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/deliveries/delivery_repo.dart'
    as delivery_repo;
import 'package:sizer/sizer.dart';

class AdminDeliveriesListScreen extends StatelessWidget {
  static const routeName = '/admin/deliveries';

  const AdminDeliveriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminDeliveriesListRender();
        }
        return Container();
      },
    );
  }
}

class _AdminDeliveriesListRender extends StatefulWidget {
  const _AdminDeliveriesListRender({Key? key}) : super(key: key);

  @override
  State<_AdminDeliveriesListRender> createState() =>
      __AdminDeliveriesListRenderState();
}

class __AdminDeliveriesListRenderState
    extends State<_AdminDeliveriesListRender> {
  Future<List<ApiDelivery>?>? _getDeliveries;
  late DateTimeRange _dateTimeRange = DateTimeRange(
    start: Jiffy().startOf(Units.YEAR).dateTime,
    end: DateTime.now(),
  );
  final _searchQueryController = TextEditingController();
  late String _query = '';

  @override
  void initState() {
    super.initState();
    _getDeliveries = _loadDeliveries();
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
      title: 'Deliveries',
      child: Column(
        children: [
          const MoreTabs(currentTab: MoreTabsOptions.deliveries),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filters(context),
                Expanded(child: _deliveriesList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
            ),
            onPressed: () async {
              var dateTimeRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(1970),
                lastDate: Jiffy().endOf(Units.MONTH).dateTime,
              );
              if (dateTimeRange != null) {
                setState(() {
                  _dateTimeRange = dateTimeRange;
                  _getDeliveries = _loadDeliveries();
                });
              }
            },
            child: Text(
              '${DateFormat('d MMM').format(_dateTimeRange.start)} - ${DateFormat('d MMM').format(_dateTimeRange.end)}',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                suffixIcon: IconButton(
                    onPressed: () {
                      _searchQueryController.clear();
                    },
                    icon: Icon(_query.isNotEmpty ? Icons.clear : Icons.search)),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _deliveriesList(BuildContext context) {
    return FutureBuilder(
      future: _getDeliveries,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return _userList(snapshot.data);
          }
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<List<ApiDelivery>?> _loadDeliveries() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await delivery_repo.loadDeliveries(auth,
        startDate: _dateTimeRange.start, endDate: _dateTimeRange.end);
  }

  Widget _userList(List<ApiDelivery> users) {
    return DataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      bottomMargin: 0,
      horizontalMargin: 10,
      minWidth: 1000,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Dealer'),
        _columnTitle(context, 'Delivered Units'),
        _columnTitle(context, 'Payment Method'),
        _columnTitle(context, 'notes'),
        _columnTitle(context, 'City'),
      ],
      empty: const Text('No orders to display'),
      rows: users
          .where((e) {
            if (_searchQueryController.text.isNotEmpty) {
              if (e.paymentType != null &&
                  e.paymentType!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              } else if (e.order?.user != null &&
                  e.order!.user!.name
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

  DataRow? _row(BuildContext context, ApiDelivery e) {
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
        Text(e.order?.user?.userProfile?.city ?? ''),
      ),
    ]);
  }
}
