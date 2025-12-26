import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/components/app_container.dart';
import 'package:carpet_app/middleware/auth.dart';
import 'package:flutter/services.dart';
import 'package:carpet_app/partials/custom_bottom_navigation_bar.dart';
import 'package:carpet_app/partials/custom_header.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final String title;
  final AppBar? appbar;
  final bool removeScroll;
  final VoidCallback? onRefresh;
  final bool disableBurger;
  final FloatingActionButton? floatingActionButton;
  final bool? disableBottomBar;
  final bool disableAuth;
  final bool disableAppBar;
  final List<Widget>? headerMenu;
  final Widget? headerAddon;

  const MainLayout({
    Key? key,
    required this.child,
    this.removeScroll = false,
    this.disableBurger = false,
    this.disableAuth = false,
    this.disableAppBar = false,
    this.disableBottomBar = false,
    this.floatingActionButton,
    this.headerMenu,
    this.headerAddon,
    this.decoration,
    this.appbar,
    this.onRefresh,
    required this.title,
  }) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());

    return AppContainer(
      child: Scaffold(
        key: _drawerKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
                child: Stack(
              children: [
                Container(
                  decoration: widget.decoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!widget.disableAppBar)
                        CustomHeader(
                          title: widget.title,
                          headerMenu: widget.headerMenu,
                          headerAddon: widget.headerAddon,
                        ),
                      Expanded(
                        child: Center(
                          child: Container(
                            child: widget.disableAuth
                                ? widget.child
                                : AuthMiddleware(
                                    child: widget.removeScroll
                                        ? widget.child
                                        : widget.onRefresh != null
                                            ? RefreshIndicator(
                                                onRefresh: () async {
                                                  widget.onRefresh!();
                                                },
                                                child: SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    child: widget.child),
                                              )
                                            : SingleChildScrollView(
                                                child: widget.child),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ));
          },
        ),
        bottomNavigationBar:
            widget.disableBottomBar! ? null : const CustomBottomNavigationBar(),
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }
}
