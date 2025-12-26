import 'user.dart';
import 'app_error.dart';
import 'package:carpet_app/protos/models.pb.dart' as proto_models;

class Auth {
  String? token;
  String? refreshToken;
  DateTime? expiresOn;
  int? refreshTokenExpiresIn;
  ApiUser? user;
  AppError? error;

  Auth({
    this.token,
    this.refreshToken,
    this.expiresOn,
    this.refreshTokenExpiresIn,
    this.user,
    this.error,
  });

  @override
  String toString() {
    return (user?.firstName ?? '') + ' ' + (user?.uuid ?? '');
  }

  String bearerToken() {
    return 'Bearer $token';
  }

  bool get isActive {
    return token != null && refreshToken != null;
  }

  factory Auth.fromJSON(Map<String, dynamic> json) {
    Auth auth;
    ApiUser? user;
    if (json['user'] != null) {
      user = ApiUser.fromJSON(json['user']);
    }
    auth = Auth(
        token: json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        expiresOn: DateTime.parse(json['expiresOn']),
        refreshTokenExpiresIn: json['refreshTokenExpiresIn'] ?? 0,
        user: user);
    return auth;
  }

  Auth copyWith({
    String? token,
    String? refreshToken,
    DateTime? expiresOn,
    int? refreshTokenExpiresIn,
    bool? loading,
    AppError? error,
  }) {
    return Auth(
      token: token,
      refreshToken: refreshToken,
      expiresOn: expiresOn,
      user: user,
      error: error,
      refreshTokenExpiresIn: refreshTokenExpiresIn,
    );
  }

  static Auth fromEntity(Auth auth) {
    return Auth(
      token: auth.token,
      refreshToken: auth.refreshToken,
      expiresOn: auth.expiresOn,
      user: auth.user,
      error: auth.error,
      refreshTokenExpiresIn: auth.refreshTokenExpiresIn,
    );
  }

  proto_models.UserToken toProto() {
    return proto_models.UserToken()..token = token ?? '';
  }
}
