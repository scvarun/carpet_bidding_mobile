import 'package:carpet_app/models/media.dart';

class ApiCustomOrder {
  String? uuid;
  String? title;
  String? name;
  String? phone;
  String? width;
  String? height;
  String? remarks;
  DateTime? createdAt;
  ApiMedia? image;

  ApiCustomOrder(
      {this.uuid,
      this.title,
      this.name,
      this.phone,
      this.width,
      this.height,
      this.remarks,
      this.image,
      this.createdAt})
      : super();

  factory ApiCustomOrder.fromJSON(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.parse(json['createdAt']).toLocal();
    }

    ApiMedia? image;
    if (json['image'] != null) {
      image = ApiMedia.fromJSON(json['image']);
    }

    return ApiCustomOrder(
      uuid: json['uuid'],
      title: json['title'],
      name: json['name'],
      phone: json['phone'],
      height: json['height'],
      width: json['width'],
      remarks: json['remarks'],
      createdAt: createdAt,
      image: image,
    );
  }
}
