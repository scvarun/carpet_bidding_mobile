import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/query_input.dart';
import 'package:carpet_app/routes/inventories/admin_inventory_add_catalog_screen.dart';
import 'package:carpet_app/routes/inventories/admin_inventory_add_rolls_screen.dart';
import 'package:carpet_app/routes/inventories/admin_inventory_single_screen.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/inventories/inventories_repo.dart'
    as inventory_repo;
import 'package:carpet_app/store/inventories/inventories_repo.dart';
import 'package:sizer/sizer.dart';

class AdminInventoryListScreen extends StatelessWidget {
  static const routeName = '/admin/inventories';

  const AdminInventoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminInventoryListRender();
        }
        return Container();
      },
    );
  }
}

class _AdminInventoryListRender extends StatefulWidget {
  const _AdminInventoryListRender({Key? key}) : super(key: key);

  @override
  State<_AdminInventoryListRender> createState() =>
      __AdminInventoryListRenderState();
}

class __AdminInventoryListRenderState extends State<_AdminInventoryListRender> {
  late Future<InventoryListOutput> _getInventories;
  late ApiInventoryTypes _activeTab = ApiInventoryTypes.rolls;
  final _searchQueryController = TextEditingController();
  late String _query = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getInventories = _loadInventories(context);
    _searchQueryController.addListener(() {
      setState(() {
        _query = _searchQueryController.text;
        _getInventories = _loadInventories(context, page: 1);
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   _dataSource = AsyncApiInvenntoryRollsDataSource(
  //       moveToSingle: _moveToSingle, context: context);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Inventory',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.add,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText1!.fontSize!) * 1.4),
              onPressed: () async {
                switch (_activeTab) {
                  case ApiInventoryTypes.rolls:
                    await Navigator.of(context)
                        .pushNamed(AdminInventoryAddRollsScreen.routeName);
                    break;
                  case ApiInventoryTypes.catalog:
                    await Navigator.of(context)
                        .pushNamed(AdminInventoryAddCatalogScreen.routeName);
                    break;
                }

                setState(() {
                  _getInventories = _loadInventories(context);
                });
              },
              label: Text(
                  'Add ${_activeTab == ApiInventoryTypes.rolls ? 'Rolls' : 'Catalog'}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: FutureBuilder<InventoryListOutput>(
        future: _getInventories,
        builder: (BuildContext context,
            AsyncSnapshot<InventoryListOutput> snapshot) {
          return Stack(
            children: [
              if (snapshot.data != null)
                Column(children: [
                  _tabs(context),
                  if (_activeTab == ApiInventoryTypes.rolls)
                    Expanded(
                        child: _rollsTable(
                      context,
                      snapshot.data?.inventories ?? [],
                      total: snapshot.data?.total ?? 0,
                      page: snapshot.data?.page ?? 0,
                      lastPage: snapshot.data?.lastPage ?? 0,
                    ))
                  else
                    Expanded(
                        child: _catalogTable(
                      context,
                      snapshot.data?.inventories ?? [],
                      total: snapshot.data?.total ?? 0,
                      page: snapshot.data?.page ?? 0,
                      lastPage: snapshot.data?.lastPage ?? 0,
                    )),
                ]),
              if (snapshot.connectionState == ConnectionState.waiting)
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.white60,
                    ),
                    child: const Center(child: CircularProgressIndicator())),
              if (snapshot.hasError) Text(snapshot.error.toString()),
            ],
          );
        },
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _tabSingle(context, ApiInventoryTypes.rolls),
              _tabSingle(context, ApiInventoryTypes.catalog),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
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
                        icon: Icon(
                            _query.isNotEmpty ? Icons.clear : Icons.search)),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _tabSingle(BuildContext context, ApiInventoryTypes type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // if (_activeTab == ApiInventoryTypes.rolls) {
          //   _rollContoller.goToFirstPage();
          // } else if (_activeTab == ApiInventoryTypes.catalog) {
          //   _catalogContoller.goToFirstPage();
          // }
          _activeTab = type;
          _getInventories = _loadInventories(context);
        });
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: type == _activeTab
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
          ),
          child: Text(type.toString().split('.').last.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white))),
    );
  }

  Widget _rollsTable(BuildContext context, List<ApiInventory> inventories,
      {int total = 0, int page = 0, int lastPage = 0}) {
    return Column(
      children: [
        Expanded(
          child: DataTable2(
              columnSpacing: 20,
              dataRowHeight: 40,
              headingRowHeight: 40,
              horizontalMargin: 10,
              minWidth: 670,
              columns: [
                _columnTitle(context, 'Pattern'),
                _columnTitle(context, 'Catalog'),
                _columnTitle(context, 'Importer'),
                _columnTitle(context, 'Size'),
                _columnTitle(context, 'QTY'),
              ],
              rows: inventories.map((e) {
                return DataRow(cells: [
                  DataCell(
                    Text(e.roll?.patternNo ?? ''),
                    onTap: () => _moveToSingle(e),
                  ),
                  DataCell(
                    Text(
                      e.catalogue?.name ?? '',
                    ),
                    onTap: () => _moveToSingle(e),
                  ),
                  DataCell(
                    Text(e.importers?.map((e) => e.name).join(',') ?? ''),
                    onTap: () => _moveToSingle(e),
                  ),
                  DataCell(
                    Text(e.catalogue?.size ?? ''),
                    onTap: () => _moveToSingle(e),
                  ),
                  DataCell(
                    Text(e.quantity.toString()),
                    onTap: () => _moveToSingle(e),
                  ),
                ]);
              }).toList()),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: page > 1
                    ? () {
                        setState(() {
                          _getInventories =
                              _loadInventories(context, page: page - 1);
                        });
                      }
                    : null,
                child: Row(
                  children: const [Icon(Icons.chevron_left), Text('Previous')],
                ),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Page $page')),
              TextButton(
                style: const ButtonStyle(
                  alignment: Alignment.centerRight,
                ),
                onPressed: page == lastPage
                    ? null : () {
                        setState(() {
                          _getInventories =
                              _loadInventories(context, page: page + 1);
                        });
                      },
                child: Row(
                  children: const [Text('Next'), Icon(Icons.chevron_right)],
                ),
              )
            ],
          ),
        )
      ],
    );

    // return PaginatedDataTable2(
    //   columnSpacing: 20,
    //   dataRowHeight: 40,
    //   headingRowHeight: 40,
    //   horizontalMargin: 10,
    //   minWidth: 670,
    //   controller: _rollContoller,
    //   border: TableBorder.all(color: Colors.black26),
    //   columns: [
    //     _columnTitle(context, 'Pattern'),
    //     _columnTitle(context, 'Catalog'),
    //     _columnTitle(context, 'Importer'),
    //     _columnTitle(context, 'Size'),
    //     _columnTitle(context, 'QTY'),
    //   ],
    //   onPageChanged: (value) {
    //     print(value);
    //   },
    //   source: ApiInventoryRollsDataSource(
    //     total: total,
    //       inventories: inventories.where((e) {
    //         if (_searchQueryController.text.isNotEmpty) {
    //           if (e.catalogue?.name != null &&
    //               e.catalogue!.name
    //                   .toLowerCase()
    //                   .contains(_query.toLowerCase())) {
    //             return true;
    //           }
    //           return false;
    //         }
    //         return true;
    //       }).toList(),
    //       moveToSingle: _moveToSingle),
    //   empty: const Text('No orders to display'),
    // );

    // if(_dataSource == null) {
    //   return Container();
    // }
    // return AsyncPaginatedDataTable2(

    //   onPageChanged: ((value) {
    //     print('value: ' +  value.toString());
    //   }),
    //   columnSpacing: 20,
    //   dataRowHeight: 40,
    //   headingRowHeight: 40,
    //   horizontalMargin: 10,
    //   minWidth: 670,
    //   border: TableBorder.all(color: Colors.black26),
    //   columns: [
    //     _columnTitle(context, 'Pattern'),
    //     _columnTitle(context, 'Catalog'),
    //     _columnTitle(context, 'Importer'),
    //     _columnTitle(context, 'Size'),
    //     _columnTitle(context, 'QTY'),
    //   ],
    //   empty: const Text('No orders to display'),
    //   source: _dataSource!,
    // );
  }

  Widget _catalogTable(BuildContext context, List<ApiInventory> inventories,
      {int total = 0, int page = 0, int lastPage = 0}) {
    return Column(
      children: [
        Expanded(
          child: DataTable2(
            columnSpacing: 20,
            dataRowHeight: 40,
            headingRowHeight: 40,
            horizontalMargin: 10,
            minWidth: 300,
            border: TableBorder.all(color: Colors.black26),
            columns: [
              DataColumn(
                label: Text('Catalogue'.toUpperCase()),
              ),
              DataColumn(
                label: Text('QTY'.toUpperCase()),
              ),
            ],
            rows: inventories.map((e) {
              return DataRow(cells: [
                DataCell(
                  Text(e.catalogue!.name),
                  onTap: () => _moveToSingle(e),
                ),
                DataCell(
                  Text(e.quantity.toString()),
                  onTap: () => _moveToSingle(e),
                ),
              ]);
            }).toList(),
            empty: const Text('No orders to display'),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: page > 1
                    ? () {
                        setState(() {
                          _getInventories =
                              _loadInventories(context, page: page - 1);
                        });
                      }
                    : null,
                child: Row(
                  children: const [Icon(Icons.chevron_left), Text('Previous')],
                ),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Page $page')),
              TextButton(
                style: const ButtonStyle(
                  alignment: Alignment.centerRight,
                ),
                onPressed: page == lastPage
                    ? null : () {
                        setState(() {
                          _getInventories =
                              _loadInventories(context, page: page + 1);
                        });
                      },
                child: Row(
                  children: const [Text('Next'), Icon(Icons.chevron_right)],
                ),
              )
            ],
          ),
        )
      ],
    );

    // return PaginatedDataTable2(
    //   columnSpacing: 20,
    //   dataRowHeight: 40,
    //   headingRowHeight: 40,
    //   horizontalMargin: 10,
    //   minWidth: 300,
    //   controller: _catalogContoller,
    //   border: TableBorder.all(color: Colors.black26),
    //   columns: [
    //     DataColumn(
    //       label: Text('Catalogue'.toUpperCase()),
    //     ),
    //     DataColumn(
    //       label: Text('QTY'.toUpperCase()),
    //     ),
    //   ],
    //   source: _ApiInventoryCatalogDataSource(
    //       inventories: inventories.where((e) {
    //         if (_searchQueryController.text.isNotEmpty) {
    //           if (e.catalogue?.name != null &&
    //               e.catalogue!.name
    //                   .toLowerCase()
    //                   .contains(_query.toLowerCase())) {
    //             return true;
    //           }
    //           return false;
    //         }
    //         return true;
    //       }).toList(),
    //       moveToSingle: _moveToSingle),

    //   empty: const Text('No orders to display'),
    // );
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

  _moveToSingle(ApiInventory inventory) async {
    await Navigator.of(context).pushNamed(AdminInventorySingleScreen.routeName,
        arguments: AdminInventorySingleScreen.args(
            uuid: inventory.uuid!, type: inventory.inventoryType));
    setState(() {
      _getInventories = _loadInventories(context);
    });
  }

  Future<InventoryListOutput> _loadInventories(BuildContext context,
      {int page = 1}) async {
    setState(() {
      isLoading = true;
    });
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var inventoriesList = await inventory_repo.loadInventories(auth, _activeTab,
        query: QueryInput(
            page: page, limit: 10, search: _searchQueryController.text));
    setState(() {
      isLoading = false;
    });
    return inventoriesList;
  }
}

class AsyncApiInvenntoryRollsDataSource extends AsyncDataTableSource {
  Function moveToSingle;
  BuildContext context;

  AsyncApiInvenntoryRollsDataSource(
      {required this.context, required this.moveToSingle})
      : super();

  @override
  Future<AsyncRowsResponse> getRows(int start, int end) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var perPage = end - start;
    var page = start % perPage + 1;
    var inventoriesList = await inventory_repo.loadInventories(
        auth, ApiInventoryTypes.rolls,
        query: QueryInput(page: page, limit: perPage));
    var inventories = inventoriesList.inventories;
    return AsyncRowsResponse(
        inventoriesList.total,
        inventories.map((e) {
          return DataRow(cells: [
            DataCell(
              Text(e.roll?.patternNo ?? ''),
              onTap: () => moveToSingle(e),
            ),
            DataCell(
              Text(
                e.catalogue?.name ?? '',
              ),
              onTap: () => moveToSingle(e),
            ),
            DataCell(
              Text(e.importers?.map((e) => e.name).join(',') ?? ''),
              onTap: () => moveToSingle(e),
            ),
            DataCell(
              Text(e.catalogue?.size ?? ''),
              onTap: () => moveToSingle(e),
            ),
            DataCell(
              Text(e.quantity.toString()),
              onTap: () => moveToSingle(e),
            ),
          ]);
        }).toList());
  }
}

class ApiInventoryRollsDataSource extends DataTableSource {
  List<ApiInventory> inventories;
  Function moveToSingle;
  int total;

  ApiInventoryRollsDataSource(
      {required this.inventories,
      required this.moveToSingle,
      required this.total})
      : super();

  @override
  DataRow? getRow(int index) {
    var e = inventories[index];
    return DataRow(cells: [
      DataCell(
        Text(e.roll?.patternNo ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(
          e.catalogue?.name ?? '',
        ),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.importers?.map((e) => e.name).join(',') ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.catalogue?.size ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.quantity.toString()),
        onTap: () => moveToSingle(e),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => total;

  @override
  int get selectedRowCount => 0;
}

class _ApiInventoryCatalogDataSource extends DataTableSource {
  List<ApiInventory> inventories;
  Function moveToSingle;

  _ApiInventoryCatalogDataSource(
      {required this.inventories, required this.moveToSingle})
      : super();

  @override
  DataRow? getRow(int index) {
    var e = inventories[index];
    return DataRow(cells: [
      DataCell(
        Text(e.catalogue!.name),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.quantity.toString()),
        onTap: () => moveToSingle(e),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => inventories.length;

  @override
  int get selectedRowCount => 0;
}
