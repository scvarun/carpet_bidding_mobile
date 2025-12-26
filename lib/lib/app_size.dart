import 'package:flutter/material.dart';
import 'dart:core';

class AppSize {
  static final AppSize _appSize = AppSize._internal();

  AppSize._internal();

  factory AppSize() {
    return _appSize;
  }

  factory AppSize.init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    if (_mediaQueryData == null) return _appSize;
    _screenWidth = _mediaQueryData!.size.width;
    _screenHeight = _mediaQueryData!.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
    return _appSize;
  }

  factory AppSize.of(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData!.size.width;
    _screenHeight = _mediaQueryData!.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
    return _appSize;
  }

  static MediaQueryData? _mediaQueryData;
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _blockSizeHorizontal = 0;
  static double _blockSizeVertical = 0;

  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double _safeBlockHorizontal = 0;
  static double _safeBlockVertical = 0;

  double width(double val) {
    return _blockSizeHorizontal * val / 4.1;
  }

  double height(double val) {
    return _blockSizeVertical * val / 7;
  }

  double safeWidth(double val) {
    return _safeBlockHorizontal * val;
  }

  double safeHeight(double val) {
    return _safeBlockVertical * val;
  }
}
