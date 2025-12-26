import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';

Future<Auth> refreshToken(BuildContext context, AuthLoggedInState state) async {
  // if (state.auth.isActive == false) return null;
  var expiresOn = state.auth.expiresOn;
  var now = DateTime.now();
  var difference = expiresOn?.difference(now).inSeconds;
  if (difference! < 60) {
    try {
      Auth auth = await context.read<AuthBloc>().authRepository.refreshToken(
          refreshToken: state.auth.refreshToken ?? '',
          token: state.auth.token ?? '');
      context.read<AuthBloc>().add(AuthRefreshTokenEvent(auth));
      return auth;
    } catch (e) {
      var error = AppError.fromError(e);
      context.read<AuthBloc>().add(AuthErrorEvent(error: error));
      context.read<AuthBloc>().add(const AuthLogoutEvent());
      throw error;
    }
  } else {
    return state.auth;
  }
}

Future<Auth?> refreshTokenOnStart(
    BuildContext context, AuthAppLoadedState state) async {
  try {
    Auth auth = await context
        .read<AuthBloc>()
        .authRepository
        .refreshToken(refreshToken: state.refreshToken, token: state.token);
    context.read<AuthBloc>().add(AuthRefreshTokenEvent(auth));
    return auth;
  } catch (e) {
    var error = AppError.fromError(e);
    context.read<AuthBloc>().add(AuthErrorEvent(error: error));
    context.read<AuthBloc>().add(const AuthLogoutEvent());
    return null;
  }
}
