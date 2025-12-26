class ApiMedia {
  String? uuid;
  String? mimeType;
  String? name;
  String? url;

  ApiMedia(
      {required this.uuid,
      required this.mimeType,
      required this.name,
      required this.url});

  factory ApiMedia.fromJSON(Map<String, dynamic> json) {
    return ApiMedia(
      uuid: json['uuid'],
      mimeType: json['mimeType'],
      name: json['name'],
      url: json['url'],
    );
  }

  @override
  String toString() => 'Media #$uuid - $name - $url';
}
