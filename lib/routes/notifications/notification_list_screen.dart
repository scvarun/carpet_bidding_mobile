import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/models/notification.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/notifications/notifications_repo.dart'
    as notifications_repo;

class NotificationListScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _NotificationListRender();
        return Container();
      },
    );
  }
}

class _NotificationListRender extends StatefulWidget {
  const _NotificationListRender({Key? key}) : super(key: key);

  @override
  State<_NotificationListRender> createState() =>
      __NotificationListRenderState();
}

class __NotificationListRenderState extends State<_NotificationListRender> {
  late Future _getNotifications;

  @override
  void initState() {
    super.initState();
    _getNotifications = _loadNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Alerts',
      child: FutureBuilder(
        future: _getNotifications,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _notificationsList(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _notificationsList(
      BuildContext context, List<ApiNotification> notifications) {
    return SingleChildScrollView(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _getNotifications = _loadNotifications(context);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: notifications
                .map((e) => GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                            NotificationSingleScreen.routeName,
                            arguments: NotificationSingleScreen.args(
                                uuid: e.uuid ?? ''));
                        setState(() {
                          _getNotifications = _loadNotifications(context);
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(color: Colors.black12, width: 1),
                          )),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(e.message!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: e.isRead!
                                                  ? FontWeight.normal
                                                  : FontWeight.bold))),
                                  Text(Jiffy(e.createdAt).fromNow()),
                                ],
                              ),
                            ],
                          )),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<List<ApiNotification>> _loadNotifications(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await notifications_repo.loadNotifications(auth);
  }
}
