part of 'auth_bloc.dart';

class AuthRepository {
  late Auth auth;

  Future<Auth> login({
    required String email,
    required String password,
  }) async {
    try {
      final client = apiClient();
      final query = MutationOptions(
        document: gql(r'''
          mutation Login($data: UserLoginInput!) {
            login(data: $data) {
              token
              expiresOn
              refreshToken
              refreshTokenExpiresIn
              user {
                uuid
                firstName
                lastName
                email
                userType {
                  slug
                  title
                }
              }
            }
          }
        '''),
        variables: {
          'data': {'email': email, 'password': password}
        },
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      return Auth.fromJSON(response.data!['login']);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String companyName,
  }) async {
    try {
      final client = apiClient();
      final query = MutationOptions(document: gql(r'''
          mutation Register($data: UserRegisterInput!) {
            register(data: $data) {
              uuid
              firstName
              lastName
              email
              userType {
                title
                slug
                description
              }
              userProfile {
                city
                phone
                companyName
                gst
                address
              }
            }
          }
        '''), variables: {
        "data": {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "phone": phone,
          "companyName": companyName
        }
      });
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      return ApiUser.fromJSON(response.data!['register']);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<Auth> refreshToken(
      {required String refreshToken, required String token}) async {
    try {
      final client = apiClient();
      final query = MutationOptions(
        document: gql(r'''
          mutation Login($data: UserRefreshTokenInput!) {
            refreshToken(data: $data) {
              token
              expiresOn
              refreshToken
              refreshTokenExpiresIn
              user {
                uuid
                firstName
                lastName
                email
                userType {
                  slug
                  title
                }
              }
            }
          }
        '''),
        variables: {
          'data': {'token': token, 'refreshToken': refreshToken}
        },
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;
      return Auth.fromJSON(response.data!['refreshToken']);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final client = apiClient();
      final query = MutationOptions(
        document: gql(r'''
          mutation ForgotPassword($email: String!) {
            forgotPassword(email: $email)
          }
        '''),
        variables: {'email': email},
      );
      final response = await client.mutate(query);
      if (response.hasException) throw response.exception!;

      return response.data!['forgotPassword'];
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<void> logout(String token) async {
    await Dio().post('${CONFIG.apiUrl}/logout',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<ApiUser> loadProfile(Auth auth, {String? userUUID}) async {
    try {
      Map<String, dynamic> query = {};
      if (userUUID != null) {
        query = {'userUUID': userUUID};
      }
      var response = await Dio().get('${CONFIG.apiUrl}/profile',
          queryParameters: query,
          options: Options(headers: {'Authorization': auth.token}));
      var jsonResponse = json.decode(response.toString());
      return ApiUser.fromJSON(jsonResponse['user']);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<ApiAdminProfileResponse> loadAdminProfile(Auth auth) async {
    try {
      var response = await Dio().get('${CONFIG.apiUrl}/adminProfile',
          options: Options(headers: {'Authorization': auth.token}));
      var jsonResponse = json.decode(response.toString());
      return ApiAdminProfileResponse.fromJSON(jsonResponse);
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Future<String> updateAdminProfile(
    Auth auth, {
    required String oldPassword,
    required String password,
    required double gst,
    required double fuelCost,
  }) async {
    try {
      var response = await Dio().put('${CONFIG.apiUrl}/adminProfile',
          data: {
            'password': password,
            'oldPassword': oldPassword,
            'gst': gst,
            'fuelCost': fuelCost,
          },
          options: Options(headers: {'Authorization': auth.token}));
      var jsonResponse = json.decode(response.toString());
      return jsonResponse['message'];
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }
}

class ApiAdminProfileResponse {
  ApiUser? user;
  double? gst;
  double? fuelCost;

  ApiAdminProfileResponse({this.user, this.gst, this.fuelCost});

  factory ApiAdminProfileResponse.fromJSON(Map<String, dynamic> json) {
    ApiUser? user;
    if (json['user'] != null) {
      user = ApiUser.fromJSON(json['user']);
    }
    return ApiAdminProfileResponse(
      user: user,
      gst: json['gst'].toDouble(),
      fuelCost: json['fuelCost'].toDouble(),
    );
  }
}
