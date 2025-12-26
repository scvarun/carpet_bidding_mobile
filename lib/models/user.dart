import 'package:equatable/equatable.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:validators/validators.dart' as validator;
import 'package:carpet_app/protos/models.pb.dart' as proto_models;

// ignore: must_be_immutable
class ApiUser extends Equatable {
  String uuid;
  String? firstName;
  String? lastName;
  String? password;
  String? email;
  String? lastLogin;
  bool? blocked;
  ApiUserProfile? userProfile;
  ApiUserType? userType;

  ApiUser({
    required this.uuid,
    required this.firstName,
    required this.lastName,
    this.password,
    required this.email,
    this.lastLogin,
    this.userProfile,
    this.userType,
    this.blocked,
  });

  String fullName() {
    return (userProfile?.companyName != null
            ? ' ${userProfile?.companyName ?? ''} ('
            : '') +
        (firstName ?? '') +
        ' ' +
        (lastName ?? '') +
        (userProfile?.companyName != null ? ')' : '');
  }

  String get name => fullName();

  set name(String nameString) {
    firstName = getFirstName(nameString);
    lastName = getLastName(nameString);
  }

  static String getFirstName(String fullName) {
    var names = fullName.trim().split(' ');
    return names[0].trim();
  }

  static String getLastName(String fullName) {
    var index = fullName.trim().indexOf(' ');
    return fullName.substring(index + 1);
  }

  factory ApiUser.fromJSON(Map<String, dynamic> json) {
    ApiUserProfile? userProfile;
    if (json['userProfile'] != null) {
      userProfile = ApiUserProfile.fromJSON(json['userProfile']);
    }

    ApiUserType? userType;
    if (json['userType'] != null) {
      userType = ApiUserType.fromJSON(json['userType']);
    }

    return ApiUser(
      uuid: json['uuid'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      lastLogin: json['lastLogin'] ?? '',
      blocked: json['blocked'],
      userProfile: userProfile,
      userType: userType,
    );
  }

  @override
  List<Object> get props => [uuid];

  factory ApiUser.fromProto(proto_models.User user) {
    return ApiUser(
      uuid: user.uuid,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      userType: ApiUserType.fromProto(user.userType),
    );
  }
}

class ApiUserProfile {
  String? phone;
  String? city;
  String? companyName;
  String? gst;
  String? address;
  bool? insidePune;

  ApiUserProfile(
      {this.phone,
      this.city,
      this.companyName,
      this.gst,
      this.address,
      this.insidePune});

  factory ApiUserProfile.fromJSON(Map<String, dynamic> json) {
    return ApiUserProfile(
      phone: json['phone'],
      city: json['city'],
      companyName: json['companyName'],
      gst: json['gst'],
      address: json['address'],
      insidePune: json['insidePune'],
    );
  }

  bool isComplete() {
    if (phone == null || validator.matches(phone!, r"[1-9][0-9]{10}")) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'UserProfile: $phone';
  }
}

class ApiUserPreference {
  bool enablePushNotification;
  bool enableUpdatesOnEmail;
  bool enableNewsletterSubscription;

  ApiUserPreference({
    this.enablePushNotification = true,
    this.enableUpdatesOnEmail = true,
    this.enableNewsletterSubscription = true,
  });

  factory ApiUserPreference.fromJSON(Map<String, dynamic> json) {
    return ApiUserPreference(
      enableNewsletterSubscription: json['enableNewsletterSubscription'],
      enableUpdatesOnEmail: json['enableUpdatesOnEmail'],
      enablePushNotification: json['enablePushNotification'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'enableNewsletterSubscription': enableNewsletterSubscription,
      'enableUpdatesOnEmail': enableUpdatesOnEmail,
      'enablePushNotification': enablePushNotification,
    };
  }
}
