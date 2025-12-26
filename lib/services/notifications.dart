import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/notification.dart';
import 'package:grpc/grpc.dart';
import 'package:carpet_app/protos/models.pbgrpc.dart';
import 'package:carpet_app/protos/models.pb.dart' as proto_models;

class NotificationService {
  static const className = 'NotificationService';

  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    initNotifications().then((value) => value);
  }

  Auth? _auth;
  NotificationServiceClient? _stub;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  Future<FlutterLocalNotificationsPlugin?> initNotifications() async {
    if (_flutterLocalNotificationsPlugin != null) {
      return _flutterLocalNotificationsPlugin;
    }
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
    );
    return _flutterLocalNotificationsPlugin;
  }

  Future<void> showNotification(
      {int id = 1,
      String title = '',
      String message = '',
      Priority priority = Priority.high,
      dynamic payload,
      bool ongoing = false}) async {
    var androidPlatformChannelSpecific = AndroidNotificationDetails(
      'carpet',
      'carpet',
      priority: priority,
      ongoing: ongoing,
    );

    var iosPlatformChannelSpecific = IOSNotificationDetails();

    var platformChannelSpecific = NotificationDetails(
        android: androidPlatformChannelSpecific,
        iOS: iosPlatformChannelSpecific);

    await _flutterLocalNotificationsPlugin?.show(id, title, message, platformChannelSpecific, payload: payload);


    // var androidPlatformChannelSpecific = AndroidNotificationDetails(
    //   'carpet',
    //   'carpet',
    //   'carpetImpex',
    //   priority: priority,
    //   ongoing: ongoing,
    // );

    // var iosPlatformChannelSpecific = const IOSNotificationDetails();

    // var platformChannelSpecific = NotificationDetails(
    //     android: androidPlatformChannelSpecific,
    //     iOS: iosPlatformChannelSpecific);

    // await _flutterLocalNotificationsPlugin!
    //     .show(id, title, message, platformChannelSpecific, payload: payload);
  }

  Future<void> dismissNotification(int id) async {
    _flutterLocalNotificationsPlugin!.cancel(id);
  }

  void reload() {
    _auth = null;
  }

  void start() {
    if (_stub == null) {
      ChannelCredentials credentials = const ChannelCredentials.insecure();
      if (CONFIG.securePorts) credentials = const ChannelCredentials.secure();
      final channel = ClientChannel(
        CONFIG.notificationHost,
        port: CONFIG.notificationPort,
        options: ChannelOptions(credentials: credentials),
      );
      _stub = NotificationServiceClient(channel);
    }
  }

  Future<List<ApiNotification>> fetchNotifications(Auth auth) async {
    try {
      if (_stub == null) start();
      _auth = auth;
      if (_auth == null) throw 'User disconnected';
      var userToken = _auth!.toProto();
      var req = proto_models.FetchNotificationsRequest(userToken: userToken);
      var response = await _stub!.fetchNotifications(req);
      var notifications = response.notifications
          .map((e) => ApiNotification.fromProto(e))
          .toList();
      return notifications;
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Stream<ApiNotification> listenNotifications() async* {
    if (_stub == null) start();
    var userToken = _auth!.toProto();
    var req = proto_models.ListenNotificationsRequest(userToken: userToken);
    await for (var chunk in _stub!.listenNotifications(req)) {
      var notification = ApiNotification.fromProto(chunk.notification);
      yield notification;
    }
  }
}
