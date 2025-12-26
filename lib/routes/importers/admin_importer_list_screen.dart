import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/more_tabs.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/importers/importers_repo.dart'
    as importer_repo;
import 'package:carpet_app/routes/index.dart';
import 'package:sizer/sizer.dart';

class AdminImporterListScreen extends StatelessWidget {
  static const routeName = '/admin/importers';

  const AdminImporterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminImporterListRender();
        }
        return Container();
      },
    );
  }
}

class _AdminImporterListRender extends StatefulWidget {
  const _AdminImporterListRender({Key? key}) : super(key: key);

  @override
  State<_AdminImporterListRender> createState() =>
      __AdminImporterListRenderState();
}

class __AdminImporterListRenderState extends State<_AdminImporterListRender> {
  late Future _getImporters;
  final _searchQueryController = TextEditingController();
  late String _query = '';

  @override
  void initState() {
    _getImporters = _loadImporters();
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
      title: 'Importers',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.add,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText2!.fontSize!) * 1.4),
              onPressed: () async {
                await Navigator.of(context)
                    .pushNamed(AdminImporterAddScreen.routeName);
                setState(() {
                  _getImporters = _loadImporters();
                });
              },
              label: Text('Add Importer',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MoreTabs(currentTab: MoreTabsOptions.importers),
          _filter(context),
          Expanded(
            child: FutureBuilder(
              future: _getImporters,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return _tableRender(snapshot.data!);
                  }
                  return const Text(
                      'Error loading importers. Please try again');
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.black12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _tableRender(List<ApiImporter> importers) {
    return PaginatedDataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      horizontalMargin: 10,
      minWidth: 670,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Name'),
        _columnTitle(context, 'Email'),
        _columnTitle(context, 'Phone'),
        _columnTitle(context, 'City'),
      ],
      empty: const Text('No importers to display'),
      source: _ApiImportersDataSource(
          importers: importers.where((e) {
            if (_searchQueryController.text.isNotEmpty) {
              if (e.name != null &&
                  e.name!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              if (e.email != null &&
                  e.email!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              if (e.phone != null &&
                  e.phone!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              if (e.city != null &&
                  e.city!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              return false;
            }
            return true;
          }).toList(),
          moveToSingle: _moveToSingle),
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

  _moveToSingle(String? uuid) async {
    if (uuid != null) {
      await Navigator.of(context).pushNamed(AdminImporterSingleScreen.routeName,
          arguments: AdminImporterSingleScreen.args(uuid: uuid));
    }
  }

  _loadImporters() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await importer_repo.loadImporters(auth);
  }
}

class _ApiImportersDataSource extends DataTableSource {
  List<ApiImporter> importers;
  Function moveToSingle;

  _ApiImportersDataSource({
    required this.importers,
    required this.moveToSingle,
  }) : super();

  @override
  DataRow? getRow(int index) {
    var e = importers[index];
    return DataRow(cells: [
      DataCell(Text(e.name ?? ''), onTap: () => moveToSingle(e.uuid)),
      DataCell(
        Text(
          e.email ?? '',
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => moveToSingle(e.uuid),
      ),
      DataCell(
        Text(e.phone ?? ''),
        onTap: () => moveToSingle(e.uuid),
      ),
      DataCell(
        Text(
          e.city ?? '',
          textAlign: TextAlign.right,
        ),
        onTap: () => moveToSingle(e.uuid),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => importers.length;

  @override
  int get selectedRowCount => 0;
}
