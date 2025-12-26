import 'dart:async';

import 'package:carpet_app/config.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/message.dart';
import 'package:grpc/grpc.dart';
import 'package:carpet_app/protos/models.pbgrpc.dart';
import 'package:carpet_app/protos/models.pb.dart' as proto_models;

class MessageService {
  static const className = 'MessageService';

  static final MessageService _messageService = MessageService._internal();

  factory MessageService() {
    return _messageService;
  }

  MessageService._internal();

  Auth? _auth;
  MessageServiceClient? _stub;

  void reload() {
    _auth = null;
  }

  void start() {
    if (_stub == null) {
      ChannelCredentials credentials = const ChannelCredentials.insecure();
      if (CONFIG.securePorts) credentials = const ChannelCredentials.secure();
      final channel = ClientChannel(
        CONFIG.messageHost,
        port: CONFIG.messagePort,
        options: ChannelOptions(credentials: credentials),
      );
      _stub = MessageServiceClient(channel);
    }
  }

  Future<List<ApiMessage>> fetchMessages(Auth auth) async {
    try {
      if (_stub == null) start();
      _auth = auth;
      if (_auth == null) throw 'User disconnected';
      var userToken = _auth!.toProto();
      var req = proto_models.FetchMessagesRequest(userToken: userToken);
      var response = await _stub!.fetchMessages(req);
      var messages =
          response.messages.map((e) => ApiMessage.fromProto(e)).toList();
      return messages;
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }

  Stream<List<ApiMessage>> listenMessages(Auth auth, String roomUUID) async* {
    if (_stub == null) start();
    var userToken = auth.toProto();
    var req = proto_models.ListenMessagesRequest(
        userToken: userToken, roomUUID: roomUUID);
    await for (var chunk in _stub!.lisenMessages(req)) {
      var messages =
          chunk.messages.map((e) => ApiMessage.fromProto(e)).toList();
      yield messages;
    }
  }

  Stream<String> listOrders(Auth auth) async* {
    if (_stub == null) start();
    var userToken = auth.toProto();
    var req = proto_models.ListenOrderRequest(userToken: userToken);
    yield '';
    await for (var chunk in _stub!.listenOrders(req)) {
      yield chunk.order.uuid;
    }
  }
}
