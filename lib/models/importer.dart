class ApiImporter {
  String? uuid;
  String? name;
  String? email;
  String? phone;
  String? city;
  String? address;

  ApiImporter({
    this.uuid,
    this.name,
    this.email,
    this.phone,
    this.city,
    this.address,
  }) : super();

  factory ApiImporter.fromJSON(Map<String, dynamic> json) {
    return ApiImporter(
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
    );
  }
}
