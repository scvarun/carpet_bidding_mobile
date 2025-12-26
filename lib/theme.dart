import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

const primaryColor = Color(0xff0962a7);
const secondaryColor = Color(0xfffba129);
const dangerColor = Color(0xffdc3545);
const headingColor = Color(0xff000000);
const borderColor = Color(0xffdddddd);
const bodyColor = Color(0xff0d0b10);

themeData(context) => ThemeData(
    appBarTheme: const AppBarTheme(backgroundColor: primaryColor),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontSize: 12.sp,
      ),
      bodyText2: TextStyle(
        fontSize: 12.sp,
      ),
      headline1: TextStyle(
        fontSize: 60.sp,
      ),
      headline2: TextStyle(
        fontSize: 48.sp,
      ),
      headline3: TextStyle(
        fontSize: 36.sp,
      ),
      headline4: TextStyle(
        fontSize: 30.sp,
      ),
      headline5: TextStyle(
        fontSize: 24.sp,
      ),
      headline6: TextStyle(
        fontSize: 18.sp,
      ),
    ),
    colorScheme: const ColorScheme(
        background: Colors.black,
        brightness: Brightness.light,
        error: dangerColor,
        primary: primaryColor,
        onBackground: Colors.white,
        onError: dangerColor,
        onPrimary: Colors.white,
        onSecondary: secondaryColor,
        secondary: secondaryColor,
        onSurface: Colors.black,
        surface: Colors.black));
