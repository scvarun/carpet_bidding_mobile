part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class NotificationStartEvent extends NotificationEvent {}

class NotificationFetchEvent extends NotificationEvent {
  final Auth auth;
  const NotificationFetchEvent(this.auth) : super();
}

class NotificationListenEvent extends NotificationEvent {
  final List<ApiNotification> notifications;
  final List<ApiNotification> olderNotifications;
  const NotificationListenEvent(this.notifications, this.olderNotifications)
      : super();
}

class NotificationNewEvent extends NotificationEvent {
  final ApiNotification notification;
  late List<ApiNotification> notificationStack;
  final List<ApiNotification> oldNotifications;
  NotificationNewEvent(
      this.notification, this.notificationStack, this.oldNotifications)
      : super();
}

class NotificationClosingEvent extends NotificationEvent {
  final List<ApiNotification> notifications;
  const NotificationClosingEvent({required this.notifications}) : super();
}

class NotificationCloseEvent extends NotificationEvent {
  final List<ApiNotification>? notifications;
  const NotificationCloseEvent({this.notifications}) : super();
}

class NotificationRestartEvent extends NotificationEvent {
  final List<ApiNotification>? notifications;
  const NotificationRestartEvent({this.notifications}) : super();
}

class NotificationErrorEvent extends NotificationEvent {
  final List<ApiNotification>? notifications;
  final AppError error;
  const NotificationErrorEvent(this.error, {this.notifications}) : super();
}
