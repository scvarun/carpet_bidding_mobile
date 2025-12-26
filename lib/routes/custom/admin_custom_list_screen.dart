import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/custom_order.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/custom/custom_repo.dart' as custom_repo;

class AdminCustomListScreen extends StatelessWidget {
  static const routeName = '/admin/custom';

  const AdminCustomListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _AdminCustomListRender();
        return Container();
      },
    );
  }
}

class _AdminCustomListRender extends StatefulWidget {
  const _AdminCustomListRender({Key? key}) : super(key: key);

  @override
  State<_AdminCustomListRender> createState() => __AdminCustomListRenderState();
}

class __AdminCustomListRenderState extends State<_AdminCustomListRender> {
  late Future? _getCustomOrders;

  @override
  void initState() {
    _getCustomOrders = _loadCustomOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      onRefresh: () {
        setState(() {
          _getCustomOrders = _loadCustomOrders();
        });
      },
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.add,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText2!.fontSize!) * 1.4),
              onPressed: () {
                Navigator.of(context).pushNamed(CustomAddScreen.routeName);
                setState(() {
                  _getCustomOrders = _loadCustomOrders();
                });
              },
              label: Text('Add Order',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white)))
        ],
      ),
      title: 'Custom Orders',
      child: FutureBuilder(
        future: _getCustomOrders,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return _tableRender(snapshot.data);
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _loadCustomOrders() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await custom_repo.loadCustomOrders(auth);
  }

  Widget _tableRender(List<ApiCustomOrder> orders) {
    return DataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      bottomMargin: 0,
      horizontalMargin: 10,
      minWidth: 900,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Date'),
        _columnTitle(context, 'Title'),
        _columnTitle(context, 'Name'),
        _columnTitle(context, 'Phone'),
        _columnTitle(context, 'Width'),
        _columnTitle(context, 'Height'),
        _columnTitle(context, 'Remarks'),
      ],
      empty: const Text('No orders to display'),
      rows: orders.map((e) => _row(context, e)).cast<DataRow>().toList(),
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

  DataRow? _row(BuildContext context, ApiCustomOrder e) {
    Color? color = Colors.black;
    return DataRow(cells: [
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
        Text(e.title ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.name ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.phone ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.width ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.height ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
      DataCell(
        Text(e.remarks ?? '',
            overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
        onTap: () => _onTap(context, e),
      ),
    ]);
  }

  _onTap(BuildContext context, ApiCustomOrder e) async {
    await Navigator.of(context).pushNamed(AdminCustomSingleScreen.routeName,
        arguments: AdminCustomSingleScreen.args(uuid: e.uuid!));
    setState(() {
      _getCustomOrders = _loadCustomOrders();
    });
  }
}
