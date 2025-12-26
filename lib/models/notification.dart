import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/protos/models.pb.dart' as proto_models;

class ApiNotification {
  String? uuid;
  String? title;
  String? message;
  bool? isRead;
  String? modelType;
  String? modelUUID;
  DateTime? createdAt;
  ApiUser? user;

  ApiNotification({
    this.title,
    this.message,
    this.uuid,
    this.isRead,
    this.createdAt,
    this.modelType,
    this.modelUUID,
    this.user,
  });

  factory ApiNotification.fromJSON(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    ApiUser? user;
    if (json['user'] != null) {
      user = ApiUser.fromJSON(json['user']);
    }

    return ApiNotification(
      uuid: json['uuid'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'],
      createdAt: createdAt,
      user: user,
    );
  }

  factory ApiNotification.fromProto(proto_models.Notification notification) {
    ApiUser? user;
    if (notification.hasUser()) {
      user = ApiUser.fromProto(notification.user);
    }

    return ApiNotification(
      uuid: notification.uuid,
      title: notification.title,
      message: notification.message,
      isRead: notification.isRead,
      modelType: notification.modelType,
      modelUUID: notification.modelUUID,
      user: user,
      createdAt: DateTime.parse(notification.createdAt).toLocal(),
    );
  }
}
