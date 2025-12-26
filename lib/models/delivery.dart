import 'package:carpet_app/models/order.dart';

class ApiDelivery {
  String? uuid;
  int delivered;
  String? notes;
  String? paymentType;
  ApiOrder? order;
  DateTime? createdAt;
  bool? readByAccounting;

  ApiDelivery(
      {required this.delivered,
      required this.notes,
      required this.paymentType,
      this.uuid,
      this.order,
      this.createdAt,
      this.readByAccounting});

  factory ApiDelivery.fromJSON(Map<String, dynamic> json) {
    ApiOrder? order;
    if (json['order'] != null) {
      order = ApiOrder.fromJSON(json['order']);
    }

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    return ApiDelivery(
      uuid: json['uuid'],
      delivered: json['delivered'],
      notes: json['notes'],
      paymentType: json['paymentType'],
      order: order,
      createdAt: createdAt,
      readByAccounting: json['readByAccounting'],
    );
  }
}
