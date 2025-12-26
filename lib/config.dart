import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'lib/logger.dart';

class CONFIG {
  static final String apiUrl = dotenv.env['API_URL'] ?? '';
  static final String expressApiUrl = dotenv.env['EXPRESS_API_URL'] ?? '';
  static final String blogApiUrl = dotenv.env['BLOG_API_URL'] ?? '';
  static final String hostUrl = dotenv.env['HOST_URL'] ?? '';
  static final String onlyHostUrl = dotenv.env['ONLY_HOST_URL'] ?? '';
  static final bool securePorts =
      dotenv.env['SECURE_PORTS']?.parseBool() ?? false;
  static final int notificationPort =
      int.tryParse(dotenv.env['NOTIFICATION_PORT'].toString()) ?? 0;
  static final String notificationHost = dotenv.env['NOTIFICATION_HOST'] ?? '';
  static final int messagePort =
      int.tryParse(dotenv.env['MESSAGE_PORT'].toString()) ?? 0;
  static final String messageHost = dotenv.env['MESSAGE_HOST'] ?? '';
  static const uniUrl = 'carpet://app.carpet.com';
  static final CONFIG _singleton = CONFIG._internal();

  late PackageInfo _packageInfo;

  factory CONFIG() {
    return _singleton;
  }

  CONFIG._internal();

  init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  String get version {
    return _packageInfo.version;
  }

  @override
  String toString() {
    Map<String, dynamic> map = {
      'apiUrl': CONFIG.apiUrl,
      'notificationHost': CONFIG.notificationHost,
      'notificationPort': CONFIG.notificationPort,
      'messageHost': CONFIG.messageHost,
      'messagePort': CONFIG.messagePort,
    };
    return map.toString();
  }
}
