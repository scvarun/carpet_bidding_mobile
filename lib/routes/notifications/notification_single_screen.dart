import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/models/notification.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/notifications/notifications_repo.dart'
    as notifications_repo;

class _NotificationSingleArgs {
  final String uuid;

  _NotificationSingleArgs({required this.uuid});
}

class NotificationSingleScreen extends StatelessWidget {
  static const routeName = '/notifications/single';

  const NotificationSingleScreen({Key? key}) : super(key: key);

  static _NotificationSingleArgs args({required String uuid}) {
    return _NotificationSingleArgs(uuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as _NotificationSingleArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return _NotificationSingleRender(args: args);
        }
        return Container();
      },
    );
  }
}

class _NotificationSingleRender extends StatefulWidget {
  final _NotificationSingleArgs args;

  const _NotificationSingleRender({Key? key, required this.args})
      : super(key: key);

  @override
  __NotificationSingleRenderState createState() =>
      __NotificationSingleRenderState();
}

class __NotificationSingleRenderState extends State<_NotificationSingleRender> {
  late Future _getNotification;

  @override
  void initState() {
    _getNotification = _loadNotification(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Alerts',
      removeScroll: true,
      child: FutureBuilder(
        future: _getNotification,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _render(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.chevron_left,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText1!.fontSize!) * 1.4),
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: Text('Back',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _render(BuildContext context, ApiNotification notification) {
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(Jiffy(notification.createdAt).fromNow(),
                            style: const TextStyle(color: Colors.black54)),
                      ),
                      Text(notification.message ?? ''),
                    ],
                  )),
            ],
          )),
    );
  }

  Future<ApiNotification?> _loadNotification(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    return await notifications_repo.loadNotification(auth, widget.args.uuid);
  }
}
