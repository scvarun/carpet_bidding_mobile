part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitialState extends NotificationState {}

class NotificationLoadingState extends NotificationState {}

class NotificationLoadedState extends NotificationState {
  final List<ApiNotification> notifications;
  const NotificationLoadedState(this.notifications) : super();
}

class NotificationListeningState extends NotificationState {
  final List<ApiNotification> notifications;
  final List<ApiNotification> olderNotifications;
  const NotificationListeningState(this.notifications, this.olderNotifications)
      : super();
}

class NotificationListeningProcessingState extends NotificationState {}

class NotificationNewState extends NotificationState {
  final ApiNotification notification;
  final List<ApiNotification> notificationStack;
  final List<ApiNotification> oldNotifications;
  const NotificationNewState(
      this.notification, this.notificationStack, this.oldNotifications)
      : super();
}

class NotificationErrorState extends NotificationState {
  final AppError error;
  const NotificationErrorState(this.error) : super();
}

class NotificationClosingState extends NotificationState {}

class NotificationClosedState extends NotificationState {}
