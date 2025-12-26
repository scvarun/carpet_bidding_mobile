import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/more_tabs.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/users/users_repo.dart';
import 'package:sizer/sizer.dart';

class AdminUserListScreen extends StatelessWidget {
  static const routeName = '/admin/users';

  const AdminUserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return const _AdminUserListRender();
        }
        return Container();
      },
    );
  }
}

class _AdminUserListRender extends StatefulWidget {
  const _AdminUserListRender({Key? key}) : super(key: key);

  @override
  State<_AdminUserListRender> createState() => __AdminUserListRenderState();
}

class __AdminUserListRenderState extends State<_AdminUserListRender> {
  Future<List<ApiUser>?>? _getAdmin;
  Future<List<ApiUser>?>? _getDealers;
  Future<List<ApiUser>?>? _getBackoffice;
  late var _activeUserType = ApiUserTypes.admin;
  final _searchQueryController = TextEditingController();
  late String _query = '';

  @override
  void initState() {
    super.initState();
    _getAdmin = _loadAdmins();
    _getDealers = _loadDealers();
    _getBackoffice = _loadBackoffice();
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
      title: 'Users',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.add,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText2!.fontSize!) * 1.4),
              onPressed: () async {
                await Navigator.of(context)
                    .pushNamed(AdminUserAddScreen.routeName);
                setState(() {
                  _getAdmin = _loadAdmins();
                  _getDealers = _loadDealers();
                  _getBackoffice = _loadBackoffice();
                });
              },
              label: Text('Add User',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: Column(
        children: [
          const MoreTabs(currentTab: MoreTabsOptions.users),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _tabs(context),
                if (_activeUserType == ApiUserTypes.admin)
                  Expanded(child: _adminsList(context)),
                if (_activeUserType == ApiUserTypes.dealer)
                  Expanded(child: _dealersList(context)),
                if (_activeUserType == ApiUserTypes.backoffice)
                  Expanded(child: _backofficeList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            _tabSingle(context, ApiUserTypes.admin),
            _tabSingle(context, ApiUserTypes.dealer),
            _tabSingle(context, ApiUserTypes.backoffice),
            Container(
              margin: const EdgeInsets.only(left: 20),
              width: 160.sp,
              height: 28.sp,
              child: TextField(
                controller: _searchQueryController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        _searchQueryController.clear();
                      },
                      icon:
                          Icon(_query.isNotEmpty ? Icons.clear : Icons.search)),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _tabSingle(BuildContext context, ApiUserTypes userType) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeUserType = userType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: _activeUserType == userType
              ? Theme.of(context).colorScheme.primary
              : Colors.black54,
        ),
        child: Text(userType.toString().split('.').last.toUpperCase(),
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _adminsList(BuildContext context) {
    return FutureBuilder(
      future: _getAdmin,
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

  Widget _dealersList(BuildContext context) {
    return FutureBuilder(
      future: _getDealers,
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

  Widget _backofficeList(BuildContext context) {
    return FutureBuilder(
      future: _getBackoffice,
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

  Future<List<ApiUser>?> _loadAdmins() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await UserRepo().loadUserList(auth, ApiUserTypes.admin);
  }

  Future<List<ApiUser>?> _loadDealers() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await UserRepo().loadUserList(auth, ApiUserTypes.dealer);
  }

  Future<List<ApiUser>?> _loadBackoffice() async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await UserRepo().loadUserList(auth, ApiUserTypes.backoffice);
  }

  Widget _userList(List<ApiUser> users) {
    return PaginatedDataTable2(
      columnSpacing: 20,
      dataRowHeight: 40,
      headingRowHeight: 40,
      horizontalMargin: 10,
      minWidth: 1000,
      border: TableBorder.all(color: Colors.black26),
      columns: [
        _columnTitle(context, 'Name'),
        _columnTitle(context, 'Email'),
        _columnTitle(context, 'Company Name'),
        _columnTitle(context, 'Phone'),
        _columnTitle(context, 'City'),
      ],
      empty: const Text('No orders to display'),
      source: _ApiUsersDataSource(
          users: users.where((e) {
            if (_searchQueryController.text.isNotEmpty) {
              if (e.name.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              if (e.email!.toLowerCase().contains(_query.toLowerCase())) {
                return true;
              }
              if (e.userProfile?.phone != null &&
                  e.userProfile!.phone!.contains(_query.toLowerCase())) {
                return true;
              }
              if (e.userProfile?.city != null &&
                  e.userProfile!.city!.contains(_query.toLowerCase())) {
                return true;
              }
              return false;
            }
            return true;
          }).toList(),
          moveToSingle: (ApiUser e) => _onTap(context, e)),
    );
  }

  Widget _tableCell(String? value) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Text(
          value ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 14),
        ),
      ),
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

  _onTap(BuildContext context, ApiUser e) async {
    await Navigator.of(context).pushNamed(AdminUserSingleScreen.routeName,
        arguments: AdminUserSingleScreen.args(uuid: e.uuid));
  }
}

class _ApiUsersDataSource extends DataTableSource {
  List<ApiUser> users;
  Function moveToSingle;

  _ApiUsersDataSource({required this.users, required this.moveToSingle})
      : super();

  @override
  DataRow? getRow(int index) {
    var e = users[index];
    return DataRow(cells: [
      DataCell(
        Text('${e.firstName} ${e.lastName}'),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.email ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.userProfile?.companyName ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.userProfile!.phone ?? ''),
        onTap: () => moveToSingle(e),
      ),
      DataCell(
        Text(e.userProfile!.city ?? ''),
        onTap: () => moveToSingle(e),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
