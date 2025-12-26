import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/lib/logger.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/services/notifications.dart';
import 'package:carpet_app/store/app/app_bloc.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/notifications/notification_bloc.dart';
import 'package:sizer/sizer.dart';

import './routes/index.dart';
import './theme.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint(CONFIG().toString());
    CONFIG().init();
    runApp(const carpetApp());
  } catch (e) {
    var error = AppError.fromError(e);
    error.printError();
  }
}

class carpetApp extends StatefulWidget {
  final Uri? uri;

  static const routes = {
    '/': SplashScreen(),
    AuthenticateScreen.routeName: AuthenticateScreen(),
    RegisterScreen.routeName: RegisterScreen(),
    LoginScreen.routeName: LoginScreen(),
    ForgotPasswordScreen.routeName: ForgotPasswordScreen(),
    ProfileScreen.routeName: ProfileScreen(),
    AdminOrderListScreen.routeName: AdminOrderListScreen(),
    OrderListScreen.routeName: OrderListScreen(),
    OrderCreateScreen.routeName: OrderCreateScreen(),
    OrderSingleScreen.routeName: OrderSingleScreen(),
    AdminEnquiryListScreen.routeName: AdminEnquiryListScreen(),
    AdminOrderReceivedStockListScreen.routeName:
        AdminOrderReceivedStockListScreen(),
    AdminOrderPendingStockListScreen.routeName:
        AdminOrderPendingStockListScreen(),
    AdminOrderSingleScreen.routeName: AdminOrderSingleScreen(),
    AdminOrderSendEnquiryScreen.routeName: AdminOrderSendEnquiryScreen(),
    AdminInventoryListScreen.routeName: AdminInventoryListScreen(),
    AdminInventorySingleScreen.routeName: AdminInventorySingleScreen(),
    AdminInventoryAddRollsScreen.routeName: AdminInventoryAddRollsScreen(),
    AdminInventoryAddCatalogScreen.routeName: AdminInventoryAddCatalogScreen(),
    AdminCustomListScreen.routeName: AdminCustomListScreen(),
    AdminCustomSingleScreen.routeName: AdminCustomSingleScreen(),
    CustomAddScreen.routeName: CustomAddScreen(),
    AdminImporterListScreen.routeName: AdminImporterListScreen(),
    AdminImporterSingleScreen.routeName: AdminImporterSingleScreen(),
    AdminUserListScreen.routeName: AdminUserListScreen(),
    AdminUserSingleScreen.routeName: AdminUserSingleScreen(),
    AdminUserAddScreen.routeName: AdminUserAddScreen(),
    AdminImporterAddScreen.routeName: AdminImporterAddScreen(),
    AdminReportsScreen.routeName: AdminReportsScreen(),
    ReportsScreen.routeName: ReportsScreen(),
    AdminArchiveListScreen.routeName: AdminArchiveListScreen(),
    NotificationListScreen.routeName: NotificationListScreen(),
    NotificationSingleScreen.routeName: NotificationSingleScreen(),
    BackofficeOrderListScreen.routeName: BackofficeOrderListScreen(),
    AdminDeliveriesListScreen.routeName: AdminDeliveriesListScreen(),
  };

  // ignore: use_key_in_widget_constructors
  const carpetApp({this.uri}) : super();

  @override
  _carpetAppState createState() => _carpetAppState();
}

class _carpetAppState extends State<carpetApp> {
  static const String className = 'carpetApp';
  final Logger _logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppBloc()),
        BlocProvider(
            create: (BuildContext context) => AuthBloc(AuthRepository())),
        BlocProvider(
            create: (BuildContext context) =>
                NotificationBloc(NotificationService())),
      ],
      child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                builder: (context, child) {
                  return Theme(
                    data: themeData(context),
                    child: child!,
                  );
                },
                onGenerateRoute: (settings) {
                  return PageTransition(
                      duration: const Duration(milliseconds: 400),
                      type: PageTransitionType.fade,
                      alignment: Alignment.centerRight,
                      settings: settings,
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<AuthBloc, AuthState>(
                            listener: (context, authState) {
                              _authListener(context, authState);
                            },
                          ),
                          BlocListener<NotificationBloc, NotificationState>(
                            listener: (context, notificationState) {
                              _notificationListener(context, notificationState);
                            },
                          ),
                        ],
                        child: carpetApp.routes[settings.name]!,
                      ));
                },
              )),
    );
  }

  Future<void> _authListener(BuildContext context, AuthState authState) async {
    if (authState is AuthAppLoadedState) {
      if (context.read<NotificationBloc>().state
          is NotificationListeningState) {
        context.read<NotificationBloc>().add(const NotificationCloseEvent());
      }
    } else if (authState is AuthLoggedInState) {
      context
          .read<NotificationBloc>()
          .add(NotificationFetchEvent(authState.auth));
    } else if (authState is AuthLoggedOutState) {
      context.read<NotificationBloc>().add(const NotificationCloseEvent());
    }
  }

  void _notificationListener(
      BuildContext context, NotificationState notificationState) {
    _logger.log(className, notificationState.toString());
    if (notificationState is NotificationInitialState) {
      _logger.log(className, 'Notification init');
      NotificationService().initNotifications();
      context.read<NotificationBloc>().add(NotificationStartEvent());
    } else if (notificationState is NotificationLoadingState) {
      Logger().log(className, 'Notifications loading');
    } else if (notificationState is NotificationLoadedState) {
      context.read<NotificationBloc>().add(
          NotificationListenEvent(const [], notificationState.notifications));
    } else if (notificationState is NotificationListeningState) {
      if (notificationState.notifications.isNotEmpty) {
        NotificationService().showNotification(
            title: notificationState.notifications.last.title ?? '',
            message: notificationState.notifications.last.message ?? '');
      }
    } else if (notificationState is NotificationErrorState) {
      context.read<NotificationBloc>().add(const NotificationRestartEvent());
    } else if (notificationState is NotificationClosingState) {
      _logger.log(className, 'Notification services closing');
    } else if (notificationState is NotificationClosedState) {
      _logger.log(className, 'Notification services closed');
    }
  }
}
