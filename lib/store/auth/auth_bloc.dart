import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as secure_storage;
import 'package:graphql/client.dart';

import 'package:carpet_app/config.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/lib/logger.dart';
import 'package:carpet_app/lib/graphql.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_repo.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String className = 'AuthBloc';

  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthAppLoadState());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    Logger().log(className, event.toString());
    if (event is AuthLoadAppEvent) {
      yield* _mapAuthLoadAppToState(event);
    } else if (event is AuthLoginEvent) {
      yield* _mapAuthLoginEventToState(event);
    } else if (event is AuthRefreshTokenEvent) {
      yield* _mapAuthRefreshTokenEventToState(event);
    } else if (event is AuthLogoutEvent) {
      yield* _mapAuthLogoutEventToState(event);
    }
  }

  Stream<AuthState> _mapAuthLoadAppToState(AuthLoadAppEvent event) async* {
    try {
      const storage = secure_storage.FlutterSecureStorage();
      var token = await storage.read(key: 'token');

      var refreshToken = await storage.read(key: 'refreshToken');
      var expiresOnString = await storage.read(key: 'expiresOn');
      var expiresOn =
          expiresOnString == null ? null : DateTime.parse(expiresOnString);
      debugPrint(expiresOnString.toString());
      if (token == null || refreshToken == null || expiresOn == null) {
        yield AuthLoggedOutState();
      } else {
        yield AuthAppLoadedState(
            token: token, refreshToken: refreshToken, expiresOn: expiresOn);
      }
    } catch (e) {
      yield AuthErrorState(AppError.fromError(e));
    }
  }

  Stream<AuthState> _mapAuthLoginEventToState(AuthLoginEvent event) async* {
    try {
      yield AuthLoadingState();
      Auth auth = await authRepository.login(
          email: event.email, password: event.password);
      const storage = secure_storage.FlutterSecureStorage();
      await storage.write(key: 'token', value: auth.token);
      await storage.write(key: 'refreshToken', value: auth.refreshToken);
      await storage.write(key: 'expiresOn', value: auth.expiresOn.toString());
      yield AuthLoggedInState(auth);
    } catch (e) {
      yield AuthErrorState(AppError.fromError(e));
    }
  }

  Stream<AuthState> _mapAuthRefreshTokenEventToState(
      AuthRefreshTokenEvent event) async* {
    yield AuthLoggedInState(event.auth);
  }

  Stream<AuthState> _mapAuthLogoutEventToState(AuthLogoutEvent event) async* {
    try {
      const storage = secure_storage.FlutterSecureStorage();
      await storage.delete(key: 'token');
      await storage.delete(key: 'refreshToken');
      await storage.delete(key: 'expiresOn');
    } catch (e) {
      yield AuthErrorState(AppError.fromError(e));
    } finally {
      yield AuthLoggedOutState();
    }
  }
}
