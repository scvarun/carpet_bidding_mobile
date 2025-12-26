// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:carpet_app/components/app_container.dart';
import 'package:carpet_app/lib/app_size.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:sizer/sizer.dart';

class AuthenticateScreen extends StatelessWidget {
  static const routeName = '/authenticate';

  const AuthenticateScreen({Key? key}) : super(key: key);

  void navigateToLogin(context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  void navigateToRegister(context) {
    Navigator.pushNamed(context, RegisterScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(40, 80, 40, 10),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/carpet.png',
                          width: 100.sp,
                          height: 100.sp,
                        ),
                        Text('carpet\nImpex',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Center(
                        child: Container(
                          width: 300,
                          height: 60.sp,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.secondary),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSize.of(context).width(5)),
                                )),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10))),
                            onPressed: () => navigateToRegister(context),
                            child: Text('Get Started',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already a member',
                                style: Theme.of(context).textTheme.bodyText1),
                            TextButton(
                                onPressed: () {
                                  navigateToLogin(context);
                                },
                                child: Text('Login',
                                    style:
                                        Theme.of(context).textTheme.bodyText1))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
