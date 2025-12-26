import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/app/app_bloc.dart';
import 'package:sizer/sizer.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool? disableBurger;
  final List<Widget>? headerMenu;
  final Widget? headerAddon;

  const CustomHeader(
      {Key? key,
      required this.title,
      this.disableBurger = false,
      this.headerMenu,
      this.headerAddon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.of(context).canPop();
    return Container(
      height: 60.sp,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.only(left: canPop ? 0 : 20),
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontSize: 14.sp, color: Colors.white))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (headerAddon != null) headerAddon!,
              Expanded(
                child: Container(),
              ),
              TextButton(
                  onPressed: () async {
                    var logout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Are you sure?'),
                            content:
                                const Text('You want to logout of the app?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        });
                    if (logout == true) {
                      context.read<AuthBloc>().add(const AuthLogoutEvent());
                    }
                  },
                  child:
                      Icon(Icons.exit_to_app, color: Colors.white, size: 24.sp))
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final bool canPop;

  const NavigationButton({Key? key, required this.canPop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            // IF STORE NAV CLOSED
            IconData icon = Icons.leaderboard;
            Color bgColor = Colors.transparent;
            Color iconColor = Colors.white;
            VoidCallback callback =
                () => BlocProvider.of<AppBloc>(context).add(AppHeaderNavOpen());
            if (canPop) {
              // IF PAGE IS INTERNAL PAGE
              icon = Icons.arrow_back;
              callback = () => Navigator.of(context).pop();
            }

            return canPop
                ? TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )),
                        backgroundColor: MaterialStateProperty.all(bgColor),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.only(left: 15, right: 15)),
                        minimumSize:
                            MaterialStateProperty.all(const Size.fromWidth(0))),
                    onPressed: callback,
                    child: Icon(icon, color: iconColor, size: 24),
                  )
                : Container();
          },
        )),
      ],
    );
  }
}

class HeaderAddons extends StatelessWidget {
  static const className = 'HeaderAddons';
  final List<Widget>? headerMenu;

  const HeaderAddons({Key? key, this.headerMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 15),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedInState) {
            return Row(
              children: [
                Row(
                  children: [...headerMenu!],
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  static Widget iconWidget(BuildContext context, IconData icon,
      {VoidCallback? onPressed, String? number}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) onPressed();
      },
      child: Stack(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Icon(icon, color: Colors.white)),
          if (number != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                    transform: Matrix4.translationValues(3, 7, 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(number,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor))),
              ),
            )
        ],
      ),
    );
  }
}
