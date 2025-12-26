// ignore_for_file: constant_identifier_names

import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/protos/models.pb.dart' as proto_models;
import 'package:carpet_app/models/user.dart';

enum ApiMessageTypes {
  text,
  new_enquiry,
  enquired,
  available,
  placed_order,
  received_stock,
  dispatched,
  completed,
  cancelled
}

class ApiMessageRoom {
  String? uuid;
  ApiOrder? order;
  List<ApiMessage>? messages;

  ApiMessageRoom({
    this.uuid,
    this.order,
    this.messages,
  }) : super();

  factory ApiMessageRoom.fromJSON(Map<String, dynamic> json) {
    ApiOrder? order;
    if (json['order'] != null) {
      order = ApiOrder.fromJSON(json['order']);
    }

    List<ApiMessage>? messages;
    if (json['messages'] != null) {
      messages = (json["messages"] as List)
          .map((e) => ApiMessage.fromJSON(e))
          .toList();
    }

    return ApiMessageRoom(uuid: json['uuid'], order: order, messages: messages);
  }
}

class ApiMessage {
  String? uuid;
  String? message;
  ApiMessageTypes? type;
  DateTime? createdAt;
  ApiUser? user;

  ApiMessage({
    this.uuid,
    this.message,
    this.type,
    this.createdAt,
    this.user,
  }) : super();

  factory ApiMessage.fromJSON(Map<String, dynamic> json) {
    ApiMessageTypes? type;
    if (json['type'] != null) {
      switch (json['type']) {
        case 'text':
          type = ApiMessageTypes.text;
          break;
        case 'new_enquiry':
          type = ApiMessageTypes.new_enquiry;
          break;
        case 'enquired':
          type = ApiMessageTypes.enquired;
          break;
        case 'available':
          type = ApiMessageTypes.available;
          break;
        case 'placed_order':
          type = ApiMessageTypes.placed_order;
          break;
        case 'received_stock':
          type = ApiMessageTypes.received_stock;
          break;
        case 'dispatched':
          type = ApiMessageTypes.dispatched;
          break;
        case 'completed':
          type = ApiMessageTypes.completed;
          break;
        case 'cancelled':
          type = ApiMessageTypes.cancelled;
      }
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    ApiUser? user;
    if (json['user'] != null) {
      user = ApiUser.fromJSON(json['user']);
    }

    return ApiMessage(
        uuid: json['uuid'],
        message: json['message'],
        user: user,
        type: type,
        createdAt: createdAt);
  }

  factory ApiMessage.fromProto(proto_models.Message message) {
    ApiUser? user;
    if (message.hasUser()) {
      user = ApiUser.fromProto(message.user);
    }

    DateTime? createdAt;
    if (message.hasCreatedAt()) {
      createdAt = DateTime.parse(message.createdAt).toLocal();
    }

    ApiMessageTypes? type;
    if (message.hasType()) {
      switch (message.type) {
        case proto_models.MessageTypes.available:
          type = ApiMessageTypes.cancelled;
          break;
        case proto_models.MessageTypes.cancelled:
          type = ApiMessageTypes.cancelled;
          break;
        case proto_models.MessageTypes.completed:
          type = ApiMessageTypes.completed;
          break;
        case proto_models.MessageTypes.dispatched:
          type = ApiMessageTypes.dispatched;
          break;
        case proto_models.MessageTypes.enquired:
          type = ApiMessageTypes.enquired;
          break;
        case proto_models.MessageTypes.new_enquiry:
          type = ApiMessageTypes.new_enquiry;
          break;
        case proto_models.MessageTypes.placed_order:
          type = ApiMessageTypes.placed_order;
          break;
        case proto_models.MessageTypes.received_stock:
          type = ApiMessageTypes.received_stock;
          break;
        case proto_models.MessageTypes.text:
          type = ApiMessageTypes.text;
          break;
      }
    }

    return ApiMessage(
      uuid: message.uuid,
      message: message.message,
      type: type,
      createdAt: createdAt,
      user: user,
    );
  }
}
