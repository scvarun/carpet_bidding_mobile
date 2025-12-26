import 'package:carpet_app/protos/models.pb.dart';

enum ApiUserTypes { admin, dealer, backoffice }

class ApiUserType {
  String title;
  String slug;

  ApiUserType({required this.title, required this.slug});

  factory ApiUserType.fromJSON(Map<String, dynamic> json) {
    return ApiUserType(slug: json['slug'], title: json['title']);
  }

  bool isType(ApiUserTypes type) {
    if (slug == ApiUserType.typeToString(ApiUserTypes.admin) &&
        type == ApiUserTypes.admin) {
      return true;
    } else if (slug == ApiUserType.typeToString(ApiUserTypes.dealer) &&
        type == ApiUserTypes.dealer) {
      return true;
    } else if (slug == ApiUserType.typeToString(ApiUserTypes.backoffice) &&
        type == ApiUserTypes.backoffice) {
      return true;
    }
    return false;
  }

  ApiUserTypes? get type {
    if (isType(ApiUserTypes.admin)) {
      return ApiUserTypes.admin;
    } else if (isType(ApiUserTypes.dealer)) {
      return ApiUserTypes.dealer;
    } else if (isType(ApiUserTypes.backoffice)) {
      return ApiUserTypes.backoffice;
    }
    return null;
  }

  static String? typeToString(ApiUserTypes userType) {
    switch (userType) {
      case ApiUserTypes.admin:
        return 'admin';
      case ApiUserTypes.dealer:
        return 'dealer';
      case ApiUserTypes.backoffice:
        return 'backoffice';
      default:
        return null;
    }
  }

  factory ApiUserType.fromProto(UserType userType) {
    String slug = '';
    switch (userType.slug) {
      case UserTypes.USER_TYPES_ADMIN:
        slug = 'admin';
        break;
      case UserTypes.USER_TYPES_BACKOFFICE:
        slug = 'backoffice';
        break;
      case UserTypes.USER_TYPES_DEALER:
        slug = 'dealer';
        break;
      case UserTypes.USER_TYPES_UNSPECIFIED:
        break;
    }
    return ApiUserType(title: userType.title, slug: slug);
  }
}
