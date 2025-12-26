part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoadAppEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password}) : super();
}

class AuthAppleLoginEvent extends AuthEvent {
  final String accentToken;
  final String email;
  final String fullName;

  const AuthAppleLoginEvent(
      {required this.accentToken, required this.email, required this.fullName})
      : super();
}

class AuthErrorEvent extends AuthEvent {
  final AppError error;
  const AuthErrorEvent({required this.error}) : super();
}

class AuthRefreshTokenEvent extends AuthEvent {
  final Auth auth;

  const AuthRefreshTokenEvent(this.auth) : super();
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent() : super();
}
