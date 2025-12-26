import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Logger {
  static final Logger _logger = Logger._internal();

  factory Logger() {
    return _logger;
  }

  Logger._internal();

  // BuildContext _context;

  // ignore: non_constant_identifier_names
  void log(String CLASSNAME, String message) {
    if(Platform.isAndroid || Platform.isIOS) {
      debugPrint('[$CLASSNAME] : $message');
    }
  }
}

extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}
