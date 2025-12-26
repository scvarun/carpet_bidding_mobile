class App {
  final bool? headerNavOpen;
  final bool? profileNavOpen;

  App({this.headerNavOpen = false, this.profileNavOpen = false});

  App copyWith({bool? headerNavOpen, bool? profileNavOpen}) {
    return App(headerNavOpen: headerNavOpen, profileNavOpen: profileNavOpen);
  }

  static App fromEntity(App app) {
    return App(
      headerNavOpen: app.headerNavOpen,
      profileNavOpen: app.profileNavOpen,
    );
  }
}
