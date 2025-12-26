import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:carpet_app/lib/logger.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/notification.dart';
import 'package:carpet_app/services/notifications.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  static const String className = 'NotificationBloc';

  final NotificationService notificationService;

  NotificationBloc(this.notificationService)
      : super(NotificationInitialState());

  StreamSubscription<ApiNotification>? _notificationSubscription;

  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    Logger().log(className, event.toString());
    try {
      if (event is NotificationStartEvent) {
        notificationService.start();
        yield NotificationLoadingState();
      } else if (event is NotificationFetchEvent) {
        // if (notificationService == null) notificationService.start();
        var notifications =
            await notificationService.fetchNotifications(event.auth);
        yield NotificationLoadedState(notifications);
      } else if (event is NotificationListenEvent) {
        _notificationSubscription?.cancel();
        yield NotificationListeningState(
            event.notifications, event.olderNotifications);
        _notificationSubscription = notificationService
            .listenNotifications()
            .asBroadcastStream()
            .listen((notification) {
          return add(NotificationNewEvent(
              notification, event.notifications, event.olderNotifications));
        });
        _notificationSubscription?.onError((e) {
          var error = AppError.fromError(e);
          return add(NotificationErrorEvent(error));
        });
      } else if (event is NotificationNewEvent) {
        _notificationSubscription?.cancel();
        yield NotificationListeningProcessingState();
        List<ApiNotification> notificationStack = [
          ...event.notificationStack,
        ];
        notificationStack.add(event.notification);
        add(NotificationListenEvent(notificationStack, event.oldNotifications));
      } else if (event is NotificationClosingEvent) {
        yield NotificationClosingState();
      } else if (event is NotificationCloseEvent) {
        _notificationSubscription?.cancel();
        notificationService.reload();
        yield NotificationClosedState();
      } else if (event is NotificationRestartEvent ||
          event is NotificationErrorEvent) {
        yield NotificationClosingState();
        Timer(const Duration(seconds: 5), () {
          return add(NotificationStartEvent());
        });
      }
    } catch (e) {
      Logger().log(className, e.toString());
      yield NotificationErrorState(AppError.fromError(e));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription!.cancel();
    return super.close();
  }
}
