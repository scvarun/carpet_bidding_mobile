import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/routes/index.dart';

Future<Timer> moveToHome(BuildContext context, ApiUserType userType) async =>
    Timer(const Duration(seconds: 2), () async {
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
      if (userType.isType(ApiUserTypes.admin)) {
        Navigator.pushNamed(context, AdminOrderListScreen.routeName);
      } else if (userType.isType((ApiUserTypes.dealer))) {
        Navigator.pushNamed(context, OrderCreateScreen.routeName);
      } else if (userType.isType((ApiUserTypes.backoffice))) {
        Navigator.pushNamed(context, BackofficeOrderListScreen.routeName);
      }
    });

Future<Timer> moveToLogin(BuildContext context, ApiUserType userType) async =>
    Timer(const Duration(seconds: 2), () async {
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
      if (userType.isType(ApiUserTypes.admin)) {
        Navigator.pushNamed(context, AdminOrderListScreen.routeName);
      }
    });
