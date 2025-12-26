import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:carpet_app/models/app.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(AppInitial(App(headerNavOpen: false, profileNavOpen: false)));

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is AppHeaderNavClose) {
      yield* _mapHeaderNavClosedToState(state, event);
    } else if (event is AppHeaderNavOpen) {
      yield* _mapHeaderNavOpenedToState(state, event);
    } else if (event is AppProfileNavOpen) {
      yield* _mapProfileNavOpenedToState(state, event);
    } else if (event is AppProfileNavClose) {
      yield* _mapProfileNavClosedToState(state, event);
    }
  }
}

Stream<AppState> _mapHeaderNavClosedToState(
    AppState currentState, AppEvent event) async* {
  var app = currentState.app.copyWith(headerNavOpen: false);
  yield AppHeaderNavClosed(app);
}

Stream<AppState> _mapHeaderNavOpenedToState(
    AppState currentState, AppEvent event) async* {
  var app = currentState.app.copyWith(headerNavOpen: true);
  yield AppHeaderNavOpened(app);
}

Stream<AppState> _mapProfileNavClosedToState(
    AppState currentState, AppEvent event) async* {
  var app = currentState.app.copyWith(profileNavOpen: false);
  yield AppHeaderNavClosed(app);
}

Stream<AppState> _mapProfileNavOpenedToState(
    AppState currentState, AppEvent event) async* {
  var app = currentState.app.copyWith(profileNavOpen: true);
  yield (AppHeaderNavOpened(app));
}
