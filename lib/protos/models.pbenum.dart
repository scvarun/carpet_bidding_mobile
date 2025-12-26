///
//  Generated code. Do not modify.
//  source: models.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class UserTypes extends $pb.ProtobufEnum {
  static const UserTypes USER_TYPES_UNSPECIFIED = UserTypes._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'USER_TYPES_UNSPECIFIED');
  static const UserTypes USER_TYPES_ADMIN = UserTypes._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'USER_TYPES_ADMIN');
  static const UserTypes USER_TYPES_DEALER = UserTypes._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'USER_TYPES_DEALER');
  static const UserTypes USER_TYPES_BACKOFFICE = UserTypes._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'USER_TYPES_BACKOFFICE');

  static const $core.List<UserTypes> values = <UserTypes> [
    USER_TYPES_UNSPECIFIED,
    USER_TYPES_ADMIN,
    USER_TYPES_DEALER,
    USER_TYPES_BACKOFFICE,
  ];

  static final $core.Map<$core.int, UserTypes> _byValue = $pb.ProtobufEnum.initByValue(values);
  static UserTypes? valueOf($core.int value) => _byValue[value];

  const UserTypes._($core.int v, $core.String n) : super(v, n);
}

class MessageTypes extends $pb.ProtobufEnum {
  static const MessageTypes text = MessageTypes._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'text');
  static const MessageTypes new_enquiry = MessageTypes._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'new_enquiry');
  static const MessageTypes enquired = MessageTypes._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'enquired');
  static const MessageTypes available = MessageTypes._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'available');
  static const MessageTypes placed_order = MessageTypes._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'placed_order');
  static const MessageTypes received_stock = MessageTypes._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'received_stock');
  static const MessageTypes dispatched = MessageTypes._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'dispatched');
  static const MessageTypes completed = MessageTypes._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'completed');
  static const MessageTypes cancelled = MessageTypes._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'cancelled');

  static const $core.List<MessageTypes> values = <MessageTypes> [
    text,
    new_enquiry,
    enquired,
    available,
    placed_order,
    received_stock,
    dispatched,
    completed,
    cancelled,
  ];

  static final $core.Map<$core.int, MessageTypes> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageTypes? valueOf($core.int value) => _byValue[value];

  const MessageTypes._($core.int v, $core.String n) : super(v, n);
}

