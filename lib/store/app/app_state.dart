part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  final App app;

  const AppState(this.app);

  @override
  List<Object> get props => [app];
}

class AppInitial extends AppState {
  const AppInitial(App app) : super(app);
}

class AppHeaderNavOpened extends AppState {
  const AppHeaderNavOpened(App app) : super(app);
}

class AppHeaderNavClosed extends AppState {
  const AppHeaderNavClosed(App app) : super(app);
}

class AppProfileNavOpened extends AppState {
  const AppProfileNavOpened(App app) : super(app);
}

class AppProfileNavClosed extends AppState {
  const AppProfileNavClosed(App app) : super(app);
}
