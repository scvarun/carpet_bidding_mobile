import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:graphql/client.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/models/user_type.dart';

class UserRepo {
  static final UserRepo _userRepo = UserRepo._internal();

  factory UserRepo() {
    return _userRepo;
  }

  UserRepo._internal();

  Future<List<ApiUser>> loadUserList(Auth auth, ApiUserTypes userType) async {
    try {
      final client = apiClient(auth: auth);
      final query = MutationOptions(
        document: gql(r'''
          query Users($query: UserQueryInput!) {
            users(query: $query) {
              uuid
              firstName
              lastName
              email
              blocked
              userType {
                title
                slug
              }
              userProfile {
                city
                phone
                gst
                companyName
                address
              }
            }
          }
        '''),
        variables: {
          'query': {
            'type': userType.toString().split('.').last,
          }
        },
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        var users = response.data!['users'] as List;
        return users.map((e) => ApiUser.fromJSON(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiUserPreference> getPreferences(Auth auth) async {
    try {
      var response = await Dio().get('${CONFIG.apiUrl}/profile/preferences',
          options: Options(headers: {
            'Authorization': auth.bearerToken(),
          }));
      var jsonResponse = json.decode(response.toString());
      return ApiUserPreference.fromJSON(jsonResponse['userPreference']);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<String> updatePreferences(
      Auth auth, ApiUserPreference userPreference) async {
    try {
      var response = await Dio().put('${CONFIG.apiUrl}/profile/preferences',
          data: {
            'enableNewsletterSubscription':
                userPreference.enableNewsletterSubscription,
            'enablePushNotification': userPreference.enablePushNotification,
            'enableUpdatesOnEmail': userPreference.enableUpdatesOnEmail,
          },
          options: Options(headers: {
            'Authorization': auth.bearerToken(),
          }));
      var jsonResponse = json.decode(response.toString());
      return jsonResponse['message'];
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiUser> loadUser(Auth auth, String uuid) async {
    try {
      final client = apiClient(auth: auth);
      final query = QueryOptions(document: gql(r'''
          query User($uuid: String!) {
            user(uuid: $uuid) {
              email
              firstName
              lastName
              uuid
              blocked
              userProfile {
                address
                city
                companyName
                gst
                phone
                insidePune
              }
              userType {
                title
                slug
              }
            }
          }
        '''), variables: {"uuid": uuid});
      final response = await client.query(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        return ApiUser.fromJSON(response.data!['user']);
      } else {
        throw AppError(
            name: 'InvalidData',
            message: 'Could not parse user',
            type: 'danger');
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiUser?> updateUser(Auth auth, ApiUser user) async {
    try {
      final client = apiClient(auth: auth);
      var data = {
        'uuid': user.uuid,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'password': user.password,
        'phone': user.userProfile!.phone,
        'companyName': user.userProfile!.companyName,
        'gst': user.userProfile!.gst,
        'address': user.userProfile!.address,
        'city': user.userProfile!.city,
        'insidePune': user.userProfile?.insidePune,
      };
      final query = MutationOptions(
        document: gql(r'''
          mutation UpdateUser($data: UserUpdateInput!) {
            updateUser(data: $data) {
              userType {
                title
                slug
              }
              blocked
              email
              firstName
              lastName
              uuid
              userProfile {
                city
                phone
                companyName
                gst
                address
              }
            }
          }
        '''),
        variables: {"data": data},
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        return ApiUser.fromJSON(response.data!['updateUser']);
      } else {
        return null;
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<bool?> blockUser(Auth auth, ApiUser user) async {
    try {
      final client = apiClient(auth: auth);
      final query = MutationOptions(
        document: gql(r'''
          mutation BlockUser($uuid: String!) {
            blockUser(uuid: $uuid)
          }
        '''),
        variables: {"uuid": user.uuid},
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<bool?> unblockUser(Auth auth, ApiUser user) async {
    try {
      final client = apiClient(auth: auth);
      final query = MutationOptions(
        document: gql(r'''
          mutation UnblockUser($uuid: String!) {
            unblockUser(uuid: $uuid)
          }
        '''),
        variables: {"uuid": user.uuid},
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiUser?> addUser(
      Auth auth, ApiUser model, ApiUserTypes userType) async {
    try {
      final client = apiClient(auth: auth);
      final query = MutationOptions(
        document: gql(r'''
          mutation AddUser($data: UserAddInput!) {
            addUser(data: $data) {
              uuid
              firstName
              lastName
              email
              userProfile {
                companyName
              }
            }
          }
        '''),
        variables: {
          'data': {
            "companyName": model.userProfile!.companyName,
            "address": model.userProfile!.address,
            "city": model.userProfile!.city,
            "email": model.email,
            "firstName": model.firstName,
            "lastName": model.lastName,
            "password": model.password,
            "phone": model.userProfile!.phone,
            'insidePune': model.userProfile!.insidePune,
            "userType": userType.toString().split('.').last,
          }
        },
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      if (response.data != null) {
        return ApiUser.fromJSON(response.data!['addUser']);
      } else {
        return null;
      }
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }
}
