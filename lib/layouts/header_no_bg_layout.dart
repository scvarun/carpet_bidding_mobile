import 'package:flutter/material.dart';
import 'package:carpet_app/middleware/auth.dart';
import 'package:carpet_app/partials/custom_bottom_navigation_bar.dart';

class HeaderNoBgLayout extends StatefulWidget {
  final Widget child;
  final bool hideBottomBar;
  final bool? removeScroll;
  final BoxDecoration? decoration;
  final AppBar? appbar;

  const HeaderNoBgLayout({
    Key? key,
    required this.child,
    this.decoration,
    this.appbar,
    this.removeScroll = false,
    this.hideBottomBar = false,
  }) : super(key: key);

  @override
  _HeaderNoBgLayoutState createState() => _HeaderNoBgLayoutState();
}

class _HeaderNoBgLayoutState extends State<HeaderNoBgLayout> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      body: Stack(
        children: [
          Container(
            decoration: widget.decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AuthMiddleware(
                    child: widget.removeScroll!
                        ? Stack(
                            children: [
                              widget.child,
                              const _BackButton(),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Stack(
                            children: [
                              Container(
                                  constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width),
                                  child: widget.child),
                              const _BackButton(),
                            ],
                          )),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Navigator.canPop(context)) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 50, left: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.5), blurRadius: 10)
              ]),
          child: const Icon(Icons.chevron_left, size: 20),
        ),
      );
    } else {
      return Container();
    }
  }
}
