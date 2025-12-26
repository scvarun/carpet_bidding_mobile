///
//  Generated code. Do not modify.
//  source: models.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'models.pb.dart' as $0;
export 'models.pb.dart';

class NotificationServiceClient extends $grpc.Client {
  static final _$fetchNotifications = $grpc.ClientMethod<
          $0.FetchNotificationsRequest, $0.FetchNotificationsResponse>(
      '/carpet.src.v1.NotificationService/FetchNotifications',
      ($0.FetchNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.FetchNotificationsResponse.fromBuffer(value));
  static final _$listenNotifications = $grpc.ClientMethod<
          $0.ListenNotificationsRequest, $0.ListenNotificationsResponse>(
      '/carpet.src.v1.NotificationService/ListenNotifications',
      ($0.ListenNotificationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.ListenNotificationsResponse.fromBuffer(value));
  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/carpet.src.v1.NotificationService/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PingResponse.fromBuffer(value));

  NotificationServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.FetchNotificationsResponse> fetchNotifications(
      $0.FetchNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$fetchNotifications, request, options: options);
  }

  $grpc.ResponseStream<$0.ListenNotificationsResponse> listenNotifications(
      $0.ListenNotificationsRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$listenNotifications, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.PingResponse> ping($0.PingRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }
}

abstract class NotificationServiceBase extends $grpc.Service {
  $core.String get $name => 'carpet.src.v1.NotificationService';

  NotificationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FetchNotificationsRequest,
            $0.FetchNotificationsResponse>(
        'FetchNotifications',
        fetchNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FetchNotificationsRequest.fromBuffer(value),
        ($0.FetchNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListenNotificationsRequest,
            $0.ListenNotificationsResponse>(
        'ListenNotifications',
        listenNotifications_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ListenNotificationsRequest.fromBuffer(value),
        ($0.ListenNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.FetchNotificationsResponse> fetchNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.FetchNotificationsRequest> request) async {
    return fetchNotifications(call, await request);
  }

  $async.Stream<$0.ListenNotificationsResponse> listenNotifications_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListenNotificationsRequest> request) async* {
    yield* listenNotifications(call, await request);
  }

  $async.Future<$0.PingResponse> ping_Pre(
      $grpc.ServiceCall call, $async.Future<$0.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.FetchNotificationsResponse> fetchNotifications(
      $grpc.ServiceCall call, $0.FetchNotificationsRequest request);
  $async.Stream<$0.ListenNotificationsResponse> listenNotifications(
      $grpc.ServiceCall call, $0.ListenNotificationsRequest request);
  $async.Future<$0.PingResponse> ping(
      $grpc.ServiceCall call, $0.PingRequest request);
}

class MessageServiceClient extends $grpc.Client {
  static final _$fetchMessages =
      $grpc.ClientMethod<$0.FetchMessagesRequest, $0.FetchMessagesResponse>(
          '/carpet.src.v1.MessageService/FetchMessages',
          ($0.FetchMessagesRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.FetchMessagesResponse.fromBuffer(value));
  static final _$lisenMessages =
      $grpc.ClientMethod<$0.ListenMessagesRequest, $0.ListenMessagesResponse>(
          '/carpet.src.v1.MessageService/LisenMessages',
          ($0.ListenMessagesRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListenMessagesResponse.fromBuffer(value));
  static final _$listenOrders =
      $grpc.ClientMethod<$0.ListenOrderRequest, $0.ListenOrdersResponse>(
          '/carpet.src.v1.MessageService/ListenOrders',
          ($0.ListenOrderRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListenOrdersResponse.fromBuffer(value));
  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/carpet.src.v1.MessageService/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PingResponse.fromBuffer(value));

  MessageServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.FetchMessagesResponse> fetchMessages(
      $0.FetchMessagesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$fetchMessages, request, options: options);
  }

  $grpc.ResponseStream<$0.ListenMessagesResponse> lisenMessages(
      $0.ListenMessagesRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$lisenMessages, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.ListenOrdersResponse> listenOrders(
      $0.ListenOrderRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$listenOrders, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.PingResponse> ping($0.PingRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }
}

abstract class MessageServiceBase extends $grpc.Service {
  $core.String get $name => 'carpet.src.v1.MessageService';

  MessageServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.FetchMessagesRequest, $0.FetchMessagesResponse>(
            'FetchMessages',
            fetchMessages_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.FetchMessagesRequest.fromBuffer(value),
            ($0.FetchMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListenMessagesRequest,
            $0.ListenMessagesResponse>(
        'LisenMessages',
        lisenMessages_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ListenMessagesRequest.fromBuffer(value),
        ($0.ListenMessagesResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListenOrderRequest, $0.ListenOrdersResponse>(
            'ListenOrders',
            listenOrders_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.ListenOrderRequest.fromBuffer(value),
            ($0.ListenOrdersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.FetchMessagesResponse> fetchMessages_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.FetchMessagesRequest> request) async {
    return fetchMessages(call, await request);
  }

  $async.Stream<$0.ListenMessagesResponse> lisenMessages_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListenMessagesRequest> request) async* {
    yield* lisenMessages(call, await request);
  }

  $async.Stream<$0.ListenOrdersResponse> listenOrders_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListenOrderRequest> request) async* {
    yield* listenOrders(call, await request);
  }

  $async.Future<$0.PingResponse> ping_Pre(
      $grpc.ServiceCall call, $async.Future<$0.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.FetchMessagesResponse> fetchMessages(
      $grpc.ServiceCall call, $0.FetchMessagesRequest request);
  $async.Stream<$0.ListenMessagesResponse> lisenMessages(
      $grpc.ServiceCall call, $0.ListenMessagesRequest request);
  $async.Stream<$0.ListenOrdersResponse> listenOrders(
      $grpc.ServiceCall call, $0.ListenOrderRequest request);
  $async.Future<$0.PingResponse> ping(
      $grpc.ServiceCall call, $0.PingRequest request);
}
