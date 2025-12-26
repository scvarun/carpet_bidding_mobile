// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:carpet_app/models/delivery.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/message.dart';
import 'package:carpet_app/models/user.dart';

enum ApiOrderStatusTypes {
  all,
  new_enquiry,
  enquired,
  available,
  placed_order,
  order_confirmed,
  received_stock,
  dispatched,
  completed,
  cancelled,
  not_available,
  pending,
}

class ApiOrderStatus {
  String? status;
  ApiOrderStatusTypes? slug;

  ApiOrderStatus({required this.status, this.slug}) : super();

  factory ApiOrderStatus.fromJSON(Map<String, dynamic> json) {
    ApiOrderStatusTypes? slug;
    if (json['slug'] != null) {
      switch (json['slug']) {
        case 'new_enquiry':
          slug = ApiOrderStatusTypes.new_enquiry;
          break;
        case 'enquired':
          slug = ApiOrderStatusTypes.enquired;
          break;
        case 'available':
          slug = ApiOrderStatusTypes.available;
          break;
        case 'placed_order':
          slug = ApiOrderStatusTypes.placed_order;
          break;
        case 'order_confirmed':
          slug = ApiOrderStatusTypes.order_confirmed;
          break;
        case 'received_stock':
          slug = ApiOrderStatusTypes.received_stock;
          break;
        case 'dispatched':
          slug = ApiOrderStatusTypes.dispatched;
          break;
        case 'completed':
          slug = ApiOrderStatusTypes.completed;
          break;
        case 'cancelled':
          slug = ApiOrderStatusTypes.cancelled;
          break;
        case 'not_available':
          slug = ApiOrderStatusTypes.not_available;
          break;
        case 'pending':
          slug = ApiOrderStatusTypes.pending;
          break;
      }
    }
    return ApiOrderStatus(status: json['status'], slug: slug);
  }

  String get slugString {
    switch (slug) {
      case ApiOrderStatusTypes.all:
        return 'All';
      case ApiOrderStatusTypes.new_enquiry:
        return 'New Enquiry';
      case ApiOrderStatusTypes.enquired:
        return 'Enquired';
      case ApiOrderStatusTypes.available:
        return 'Available';
      case ApiOrderStatusTypes.placed_order:
        return 'Placed Order';
      case ApiOrderStatusTypes.order_confirmed:
        return 'Order Confirmed';
      case ApiOrderStatusTypes.received_stock:
        return 'Received Stock';
      case ApiOrderStatusTypes.dispatched:
        return 'Dispatched';
      case ApiOrderStatusTypes.completed:
        return 'Completed';
      case ApiOrderStatusTypes.cancelled:
        return 'Cancelled';
      case ApiOrderStatusTypes.not_available:
        return 'Not Available';
      case ApiOrderStatusTypes.pending:
        return 'Pending';
      default:
        return '';
    }
  }
}

class ApiOrderStatusHistory {
  ApiOrder? order;
  ApiOrderStatus? status;
  DateTime? createdAt;

  ApiOrderStatusHistory({this.createdAt, this.order, this.status});

  factory ApiOrderStatusHistory.fromJSON(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    ApiOrder? order;
    if (json['order'] != null) {
      order = ApiOrder.fromJSON(json['order']);
    }

    ApiOrderStatus? status;
    if (json['status'] != null) {
      status = ApiOrderStatus.fromJSON(json['status']);
    }

    return ApiOrderStatusHistory(
      order: order,
      createdAt: createdAt,
      status: status,
    );
  }
}

class ApiOrder {
  String? sid;
  String? uuid;
  String? patternNo;
  String? reference;
  String? notes;
  int? quantity;
  ApiInventoryTypes? type;
  ApiCatalogue? catalogue;
  List<ApiOrderStatusHistory>? statusHistory;
  List<ApiDelivery>? deliveries;
  List<ApiOrderContact>? orderContacts;
  ApiOrderStatus? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  ApiMessageRoom? messageRoom;
  ApiInventory? inventory;
  ApiUser? user;

  ApiOrder({
    this.sid,
    this.uuid,
    this.catalogue,
    this.statusHistory,
    this.status,
    this.patternNo,
    this.reference,
    this.notes,
    this.deliveries,
    this.type,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.messageRoom,
    this.inventory,
    this.user,
    this.orderContacts,
  });

  factory ApiOrder.fromJSON(Map<String, dynamic> json) {
    ApiCatalogue? catalogue;
    if (json['catalogue'] != null) {
      catalogue = ApiCatalogue.fromJSON(json['catalogue']);
    }

    ApiOrderStatus? status;
    if (json['status'] != null) {
      status = ApiOrderStatus.fromJSON(json['status']);
    }

    ApiMessageRoom? messageRoom;
    if (json['messageRoom'] != null) {
      messageRoom = ApiMessageRoom.fromJSON(json['messageRoom']);
    }

    ApiInventory? inventory;
    if (json['inventory'] != null) {
      inventory = ApiInventory.fromJSON(json['inventory']);
    }

    ApiUser? user;
    if (json['user'] != null) {
      user = ApiUser.fromJSON(json['user']);
    }

    List<ApiOrderStatusHistory>? statusHistory;
    if (json['statusHistory'] != null) {
      debugPrint(json['statusHistory'].runtimeType.toString());
      statusHistory = (json['statusHistory'] as List)
          .map((e) => ApiOrderStatusHistory.fromJSON(e))
          .toList();
    }

    List<ApiDelivery>? deliveries;
    if (json['deliveries'] != null) {
      debugPrint(json['deliveries'].runtimeType.toString());
      deliveries = (json['deliveries'] as List)
          .map((e) => ApiDelivery.fromJSON(e))
          .toList();
    }

    List<ApiOrderContact>? orderContacts;
    if (json['orderContacts'] != null) {
      debugPrint(json['orderContacts'].runtimeType.toString());
      orderContacts = (json['orderContacts'] as List)
          .map((e) => ApiOrderContact.fromJSON(e))
          .toList();
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    ApiInventoryTypes? type;
    if (json['type'] != null) {
      switch (json['type']) {
        case "rolls":
          type = ApiInventoryTypes.rolls;
          break;
        case "catalog":
          type = ApiInventoryTypes.catalog;
          break;
      }
    }

    return ApiOrder(
      sid: json['sid'],
      uuid: json['uuid'],
      patternNo: json['patternNo'],
      reference: json['reference'],
      notes: json['notes'],
      quantity: json['quantity'],
      type: type,
      catalogue: catalogue,
      status: status,
      messageRoom: messageRoom,
      statusHistory: statusHistory,
      deliveries: deliveries,
      user: user,
      inventory: inventory,
      createdAt: createdAt,
      orderContacts: orderContacts,
    );
  }

  String get orderName {
    return '${patternNo ?? ''}${patternNo != null && catalogue?.name != null ? " - " : ""}${catalogue?.name ?? ''}';
  }
}

class ApiOrderContact {
  String? uuid;
  String? name;
  String? email;
  String? phone;

  ApiOrderContact({
    this.uuid,
    this.name,
    this.email,
    this.phone,
  }) : super();

  factory ApiOrderContact.fromJSON(Map<String, dynamic> json) {
    return ApiOrderContact(
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
