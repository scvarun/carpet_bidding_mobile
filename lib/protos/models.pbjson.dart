///
//  Generated code. Do not modify.
//  source: models.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use userTypesDescriptor instead')
const UserTypes$json = const {
  '1': 'UserTypes',
  '2': const [
    const {'1': 'USER_TYPES_UNSPECIFIED', '2': 0},
    const {'1': 'USER_TYPES_ADMIN', '2': 1},
    const {'1': 'USER_TYPES_DEALER', '2': 2},
    const {'1': 'USER_TYPES_BACKOFFICE', '2': 3},
  ],
};

/// Descriptor for `UserTypes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userTypesDescriptor = $convert.base64Decode('CglVc2VyVHlwZXMSGgoWVVNFUl9UWVBFU19VTlNQRUNJRklFRBAAEhQKEFVTRVJfVFlQRVNfQURNSU4QARIVChFVU0VSX1RZUEVTX0RFQUxFUhACEhkKFVVTRVJfVFlQRVNfQkFDS09GRklDRRAD');
@$core.Deprecated('Use messageTypesDescriptor instead')
const MessageTypes$json = const {
  '1': 'MessageTypes',
  '2': const [
    const {'1': 'text', '2': 0},
    const {'1': 'new_enquiry', '2': 1},
    const {'1': 'enquired', '2': 2},
    const {'1': 'available', '2': 3},
    const {'1': 'placed_order', '2': 4},
    const {'1': 'received_stock', '2': 5},
    const {'1': 'dispatched', '2': 6},
    const {'1': 'completed', '2': 7},
    const {'1': 'cancelled', '2': 8},
  ],
};

/// Descriptor for `MessageTypes`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypesDescriptor = $convert.base64Decode('CgxNZXNzYWdlVHlwZXMSCAoEdGV4dBAAEg8KC25ld19lbnF1aXJ5EAESDAoIZW5xdWlyZWQQAhINCglhdmFpbGFibGUQAxIQCgxwbGFjZWRfb3JkZXIQBBISCg5yZWNlaXZlZF9zdG9jaxAFEg4KCmRpc3BhdGNoZWQQBhINCgljb21wbGV0ZWQQBxINCgljYW5jZWxsZWQQCA==');
@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = const {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode('CgVFbXB0eQ==');
@$core.Deprecated('Use userTokenDescriptor instead')
const UserToken$json = const {
  '1': 'UserToken',
  '2': const [
    const {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `UserToken`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTokenDescriptor = $convert.base64Decode('CglVc2VyVG9rZW4SFAoFdG9rZW4YASABKAlSBXRva2Vu');
@$core.Deprecated('Use errorDescriptor instead')
const Error$json = const {
  '1': 'Error',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'statusCode', '3': 3, '4': 1, '5': 5, '10': 'statusCode'},
    const {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode('CgVFcnJvchISCgRuYW1lGAEgASgJUgRuYW1lEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USHgoKc3RhdHVzQ29kZRgDIAEoBVIKc3RhdHVzQ29kZRISCgR0eXBlGAQgASgJUgR0eXBl');
@$core.Deprecated('Use userTypeDescriptor instead')
const UserType$json = const {
  '1': 'UserType',
  '2': const [
    const {'1': 'slug', '3': 1, '4': 1, '5': 14, '6': '.carpet.src.v1.UserTypes', '10': 'slug'},
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `UserType`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTypeDescriptor = $convert.base64Decode('CghVc2VyVHlwZRItCgRzbHVnGAEgASgOMhkucGFyc2h3YS5zcmMudjEuVXNlclR5cGVzUgRzbHVnEhQKBXRpdGxlGAIgASgJUgV0aXRsZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24=');
@$core.Deprecated('Use userDescriptor instead')
const User$json = const {
  '1': 'User',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    const {'1': 'firstName', '3': 2, '4': 1, '5': 9, '10': 'firstName'},
    const {'1': 'lastName', '3': 3, '4': 1, '5': 9, '10': 'lastName'},
    const {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    const {'1': 'userType', '3': 5, '4': 1, '5': 11, '6': '.carpet.src.v1.UserType', '10': 'userType'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode('CgRVc2VyEhIKBHV1aWQYASABKAlSBHV1aWQSHAoJZmlyc3ROYW1lGAIgASgJUglmaXJzdE5hbWUSGgoIbGFzdE5hbWUYAyABKAlSCGxhc3ROYW1lEhQKBWVtYWlsGAQgASgJUgVlbWFpbBI0Cgh1c2VyVHlwZRgFIAEoCzIYLnBhcnNod2Euc3JjLnYxLlVzZXJUeXBlUgh1c2VyVHlwZQ==');
@$core.Deprecated('Use mediaDescriptor instead')
const Media$json = const {
  '1': 'Media',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    const {'1': 'mimeType', '3': 2, '4': 1, '5': 9, '10': 'mimeType'},
    const {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    const {'1': 'blocked', '3': 7, '4': 1, '5': 9, '10': 'blocked'},
    const {'1': 'createdAt', '3': 8, '4': 1, '5': 9, '10': 'createdAt'},
    const {'1': 'updatedAt', '3': 9, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Media`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaDescriptor = $convert.base64Decode('CgVNZWRpYRISCgR1dWlkGAEgASgJUgR1dWlkEhoKCG1pbWVUeXBlGAIgASgJUghtaW1lVHlwZRISCgRuYW1lGAMgASgJUgRuYW1lEhQKBXRpdGxlGAQgASgJUgV0aXRsZRIgCgtkZXNjcmlwdGlvbhgFIAEoCVILZGVzY3JpcHRpb24SEAoDdXJsGAYgASgJUgN1cmwSGAoHYmxvY2tlZBgHIAEoCVIHYmxvY2tlZBIcCgljcmVhdGVkQXQYCCABKAlSCWNyZWF0ZWRBdBIcCgl1cGRhdGVkQXQYCSABKAlSCXVwZGF0ZWRBdA==');
@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = const {
  '1': 'Notification',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'isRead', '3': 4, '4': 1, '5': 8, '10': 'isRead'},
    const {'1': 'modelType', '3': 5, '4': 1, '5': 9, '10': 'modelType'},
    const {'1': 'modelUUID', '3': 6, '4': 1, '5': 9, '10': 'modelUUID'},
    const {'1': 'createdAt', '3': 7, '4': 1, '5': 9, '10': 'createdAt'},
    const {'1': 'updatedAt', '3': 8, '4': 1, '5': 9, '10': 'updatedAt'},
    const {'1': 'user', '3': 9, '4': 1, '5': 11, '6': '.carpet.src.v1.User', '10': 'user'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode('CgxOb3RpZmljYXRpb24SEgoEdXVpZBgBIAEoCVIEdXVpZBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSGAoHbWVzc2FnZRgDIAEoCVIHbWVzc2FnZRIWCgZpc1JlYWQYBCABKAhSBmlzUmVhZBIcCgltb2RlbFR5cGUYBSABKAlSCW1vZGVsVHlwZRIcCgltb2RlbFVVSUQYBiABKAlSCW1vZGVsVVVJRBIcCgljcmVhdGVkQXQYByABKAlSCWNyZWF0ZWRBdBIcCgl1cGRhdGVkQXQYCCABKAlSCXVwZGF0ZWRBdBIoCgR1c2VyGAkgASgLMhQucGFyc2h3YS5zcmMudjEuVXNlclIEdXNlcg==');
@$core.Deprecated('Use messageDescriptor instead')
const Message$json = const {
  '1': 'Message',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'type', '3': 3, '4': 1, '5': 14, '6': '.carpet.src.v1.MessageTypes', '10': 'type'},
    const {'1': 'createdAt', '3': 4, '4': 1, '5': 9, '10': 'createdAt'},
    const {'1': 'updatedAt', '3': 5, '4': 1, '5': 9, '10': 'updatedAt'},
    const {'1': 'user', '3': 6, '4': 1, '5': 11, '6': '.carpet.src.v1.User', '10': 'user'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode('CgdNZXNzYWdlEhIKBHV1aWQYASABKAlSBHV1aWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRIwCgR0eXBlGAMgASgOMhwucGFyc2h3YS5zcmMudjEuTWVzc2FnZVR5cGVzUgR0eXBlEhwKCWNyZWF0ZWRBdBgEIAEoCVIJY3JlYXRlZEF0EhwKCXVwZGF0ZWRBdBgFIAEoCVIJdXBkYXRlZEF0EigKBHVzZXIYBiABKAsyFC5wYXJzaHdhLnNyYy52MS5Vc2VyUgR1c2Vy');
@$core.Deprecated('Use orderDescriptor instead')
const Order$json = const {
  '1': 'Order',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `Order`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderDescriptor = $convert.base64Decode('CgVPcmRlchISCgR1dWlkGAEgASgJUgR1dWlk');
@$core.Deprecated('Use fetchNotificationsRequestDescriptor instead')
const FetchNotificationsRequest$json = const {
  '1': 'FetchNotificationsRequest',
  '2': const [
    const {'1': 'userToken', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.UserToken', '10': 'userToken'},
  ],
};

/// Descriptor for `FetchNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchNotificationsRequestDescriptor = $convert.base64Decode('ChlGZXRjaE5vdGlmaWNhdGlvbnNSZXF1ZXN0EjcKCXVzZXJUb2tlbhgBIAEoCzIZLnBhcnNod2Euc3JjLnYxLlVzZXJUb2tlblIJdXNlclRva2Vu');
@$core.Deprecated('Use fetchNotificationsResponseDescriptor instead')
const FetchNotificationsResponse$json = const {
  '1': 'FetchNotificationsResponse',
  '2': const [
    const {'1': 'notifications', '3': 1, '4': 3, '5': 11, '6': '.carpet.src.v1.Notification', '10': 'notifications'},
  ],
};

/// Descriptor for `FetchNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchNotificationsResponseDescriptor = $convert.base64Decode('ChpGZXRjaE5vdGlmaWNhdGlvbnNSZXNwb25zZRJCCg1ub3RpZmljYXRpb25zGAEgAygLMhwucGFyc2h3YS5zcmMudjEuTm90aWZpY2F0aW9uUg1ub3RpZmljYXRpb25z');
@$core.Deprecated('Use listenNotificationsRequestDescriptor instead')
const ListenNotificationsRequest$json = const {
  '1': 'ListenNotificationsRequest',
  '2': const [
    const {'1': 'userToken', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.UserToken', '10': 'userToken'},
  ],
};

/// Descriptor for `ListenNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenNotificationsRequestDescriptor = $convert.base64Decode('ChpMaXN0ZW5Ob3RpZmljYXRpb25zUmVxdWVzdBI3Cgl1c2VyVG9rZW4YASABKAsyGS5wYXJzaHdhLnNyYy52MS5Vc2VyVG9rZW5SCXVzZXJUb2tlbg==');
@$core.Deprecated('Use listenNotificationsResponseDescriptor instead')
const ListenNotificationsResponse$json = const {
  '1': 'ListenNotificationsResponse',
  '2': const [
    const {'1': 'notification', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.Notification', '10': 'notification'},
  ],
};

/// Descriptor for `ListenNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenNotificationsResponseDescriptor = $convert.base64Decode('ChtMaXN0ZW5Ob3RpZmljYXRpb25zUmVzcG9uc2USQAoMbm90aWZpY2F0aW9uGAEgASgLMhwucGFyc2h3YS5zcmMudjEuTm90aWZpY2F0aW9uUgxub3RpZmljYXRpb24=');
@$core.Deprecated('Use fetchMessagesRequestDescriptor instead')
const FetchMessagesRequest$json = const {
  '1': 'FetchMessagesRequest',
  '2': const [
    const {'1': 'userToken', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.UserToken', '10': 'userToken'},
    const {'1': 'roomUUID', '3': 2, '4': 1, '5': 9, '10': 'roomUUID'},
  ],
};

/// Descriptor for `FetchMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchMessagesRequestDescriptor = $convert.base64Decode('ChRGZXRjaE1lc3NhZ2VzUmVxdWVzdBI3Cgl1c2VyVG9rZW4YASABKAsyGS5wYXJzaHdhLnNyYy52MS5Vc2VyVG9rZW5SCXVzZXJUb2tlbhIaCghyb29tVVVJRBgCIAEoCVIIcm9vbVVVSUQ=');
@$core.Deprecated('Use fetchMessagesResponseDescriptor instead')
const FetchMessagesResponse$json = const {
  '1': 'FetchMessagesResponse',
  '2': const [
    const {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.carpet.src.v1.Message', '10': 'messages'},
  ],
};

/// Descriptor for `FetchMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchMessagesResponseDescriptor = $convert.base64Decode('ChVGZXRjaE1lc3NhZ2VzUmVzcG9uc2USMwoIbWVzc2FnZXMYASADKAsyFy5wYXJzaHdhLnNyYy52MS5NZXNzYWdlUghtZXNzYWdlcw==');
@$core.Deprecated('Use listenMessagesRequestDescriptor instead')
const ListenMessagesRequest$json = const {
  '1': 'ListenMessagesRequest',
  '2': const [
    const {'1': 'userToken', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.UserToken', '10': 'userToken'},
    const {'1': 'roomUUID', '3': 2, '4': 1, '5': 9, '10': 'roomUUID'},
  ],
};

/// Descriptor for `ListenMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenMessagesRequestDescriptor = $convert.base64Decode('ChVMaXN0ZW5NZXNzYWdlc1JlcXVlc3QSNwoJdXNlclRva2VuGAEgASgLMhkucGFyc2h3YS5zcmMudjEuVXNlclRva2VuUgl1c2VyVG9rZW4SGgoIcm9vbVVVSUQYAiABKAlSCHJvb21VVUlE');
@$core.Deprecated('Use listenOrderRequestDescriptor instead')
const ListenOrderRequest$json = const {
  '1': 'ListenOrderRequest',
  '2': const [
    const {'1': 'userToken', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.UserToken', '10': 'userToken'},
  ],
};

/// Descriptor for `ListenOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenOrderRequestDescriptor = $convert.base64Decode('ChJMaXN0ZW5PcmRlclJlcXVlc3QSNwoJdXNlclRva2VuGAEgASgLMhkucGFyc2h3YS5zcmMudjEuVXNlclRva2VuUgl1c2VyVG9rZW4=');
@$core.Deprecated('Use listenMessagesResponseDescriptor instead')
const ListenMessagesResponse$json = const {
  '1': 'ListenMessagesResponse',
  '2': const [
    const {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.carpet.src.v1.Message', '10': 'messages'},
  ],
};

/// Descriptor for `ListenMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenMessagesResponseDescriptor = $convert.base64Decode('ChZMaXN0ZW5NZXNzYWdlc1Jlc3BvbnNlEjMKCG1lc3NhZ2VzGAEgAygLMhcucGFyc2h3YS5zcmMudjEuTWVzc2FnZVIIbWVzc2FnZXM=');
@$core.Deprecated('Use listenOrdersResponseDescriptor instead')
const ListenOrdersResponse$json = const {
  '1': 'ListenOrdersResponse',
  '2': const [
    const {'1': 'order', '3': 1, '4': 1, '5': 11, '6': '.carpet.src.v1.Order', '10': 'order'},
  ],
};

/// Descriptor for `ListenOrdersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listenOrdersResponseDescriptor = $convert.base64Decode('ChRMaXN0ZW5PcmRlcnNSZXNwb25zZRIrCgVvcmRlchgBIAEoCzIVLnBhcnNod2Euc3JjLnYxLk9yZGVyUgVvcmRlcg==');
@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = const {
  '1': 'PingResponse',
  '2': const [
    const {'1': 'pong', '3': 1, '4': 1, '5': 9, '10': 'pong'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode('CgxQaW5nUmVzcG9uc2USEgoEcG9uZxgBIAEoCVIEcG9uZw==');
@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = const {
  '1': 'PingRequest',
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode('CgtQaW5nUmVxdWVzdA==');
