part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoadingState extends AuthState {}

class AuthAppLoadState extends AuthState {}

class AuthAppLoadedState extends AuthState {
  final String token;
  final String refreshToken;
  final DateTime expiresOn;

  AuthAppLoadedState({
    required this.token,
    required this.refreshToken,
    required this.expiresOn,
  }) : super();

  @override
  List<Object> get props => [token, refreshToken, expiresOn];
}

class AuthErrorState extends AuthState {
  final AppError error;

  AuthErrorState(this.error) : super();

  @override
  List<Object> get props => [error];
}

class AuthGoogleLoginLoadingState extends AuthState {}

class AuthFacebookLoginLoadingState extends AuthState {}

class AuthAppleLoginLoadingState extends AuthState {}

class AuthLoggingInState extends AuthState {
  final Auth auth;

  AuthLoggingInState(this.auth) : super();

  @override
  List<Object> get props => [auth];
}

class AuthLoggedInState extends AuthState {
  final Auth auth;

  AuthLoggedInState(this.auth) : super();

  @override
  List<Object> get props => [auth];
}

class AuthRefreshTokenStartedState extends AuthState {}

class AuthLoggedOutState extends AuthState {}
