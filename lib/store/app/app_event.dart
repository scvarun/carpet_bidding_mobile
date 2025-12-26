part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppHeaderNavOpen extends AppEvent {}

class AppHeaderNavClose extends AppEvent {}

class AppProfileNavOpen extends AppEvent {}

class AppProfileNavClose extends AppEvent {}
