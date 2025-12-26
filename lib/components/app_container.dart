import 'package:flutter/material.dart';
import 'package:carpet_app/lib/app_size.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  const AppContainer({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    return child;
  }
}
