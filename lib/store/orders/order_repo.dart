import 'dart:convert';

import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/custom_order.dart';
import 'package:carpet_app/models/delivery.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/message.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/models/user.dart';

Future<List<ApiOrder>?> loadImporters(Auth auth) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Importers {
            importers {
              uuid
              name
              email
              phone
              city
              address
            }
          }
        '''),
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var importers = response.data!['importers'] as List;
      return importers.map((e) => ApiOrder.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<List<ApiOrder>?> loadOrders(
  Auth auth, {
  List<ApiOrderStatusTypes>? type,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Orders($query: OrderQueryInput!) {
            orders(query: $query) {
              sid
              uuid
              reference
              quantity
              patternNo
              type
              createdAt
              notes
              catalogue {
                name
                uuid
              }
              user {
                uuid
                firstName
                lastName
                email
                userProfile {
                  companyName
                }
              }
              status {
                slug
                status
              }
            }
          }
        '''),
      variables: {
        "query": {
          "status": type?.map((e) => e.toString().split('.').last).toList(),
          "startDate": startDate?.toIso8601String(),
          "endDate": endDate?.toIso8601String()
        }
      },
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var orders = response.data!['orders'] as List;
      return orders.map((e) => ApiOrder.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiOrder?> loadOrder(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Order($uuid: String!) {
            order(uuid: $uuid) {
              uuid
              quantity
              reference
              type
              sid
              patternNo
              notes
              orderContacts {
                name
                phone
                uuid
              }
              messageRoom {
                uuid
              }
              deliveries {
                uuid
                delivered
                notes
                paymentType
              }
              user {
                uuid
                firstName
                lastName
                email
                userProfile {
                  phone
                }
              }
              status {
                status
                slug
              }
              catalogue {
                uuid
                name
              }
              inventory {
                uuid
                type
                quantity
                importers {
                  uuid
                  name
                  email
                  phone
                  city
                  address
                }
                similarInventories {
                  uuid
                  type
                  quantity
                  catalogue {
                    name
                    uuid
                    rate
                    size
                  }
                  roll {
                    patternNo
                  }
                }
              }
            }
          }
        '''),
      variables: {"uuid": uuid},
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiOrder.fromJSON(response.data!['order']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiOrder?> createOrder(
  Auth auth, {
  String reference = "",
  required int quantity,
  ApiInventory? inventory,
  String? patternNo,
  ApiCatalogue? catalogue,
  ApiUser? user,
  required ApiInventoryTypes type,
  required ApiOrderStatusTypes status,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation AddOrder($data: OrderCreateInput!) {
            addOrder(data: $data) {
              uuid
              quantity
              reference
              user {
                lastName
                firstName
                uuid
              }
              statusHistory {
                status {
                  status
                  slug
                }
              }
              status {
                slug
                status
              }
            }
          }
        ''',
        ),
        variables: {
          'data': {
            "userUUID": user?.uuid,
            "inventoryUUID": inventory?.uuid,
            "catalogueUUID": catalogue?.uuid,
            "quantity": quantity,
            "reference": reference,
            "patternNo": patternNo,
            "type": type.toString().split(".").last,
            "status": status.toString().split(".").last
          }
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var order = ApiOrder.fromJSON(response.data!['addOrder']);
      return order;
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

class ApiOrderCheckAvailabilityOutput {
  ApiInventory? inventory;
  bool isAvailable;
  String message;

  ApiOrderCheckAvailabilityOutput(
      {this.inventory, required this.isAvailable, required this.message});
}

Future<ApiOrderCheckAvailabilityOutput?> checkAvailability(
  Auth auth, {
  required int quantity,
  String? patternNo,
  ApiCatalogue? catalogue,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query CheckAvailability(
            $patternNo: String
            $quantity: Float!
            $catalogueUuid: String
          ) {
            checkAvailability(
              patternNo: $patternNo
              quantity: $quantity
              catalogueUUID: $catalogueUuid
            ) {
              inventory {
                uuid
                quantity

              }
              isAvailable
              message
            }
          }
        '''),
      variables: {
        "quantity": quantity,
        "patternNo": patternNo,
        "catalogueUuid": catalogue?.uuid
      },
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      ApiInventory? inventory;
      if (response.data!['checkAvailability']['inventory'] != null) {
        inventory = ApiInventory.fromJSON(
            response.data!['checkAvailability']['inventory']);
      }
      return ApiOrderCheckAvailabilityOutput(
        inventory: inventory,
        isAvailable: response.data!['checkAvailability']['isAvailable'],
        message: response.data!['checkAvailability']['message'],
      );
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<List<ApiOrder>?> createEnqiry(Auth auth,
    {required String reference,
    required int quantity,
    required String patternNo,
    required ApiInventory inventory}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Importers {
            importers {
              uuid
              name
              email
              phone
              city
              address
            }
          }
        '''),
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var importers = response.data!['importers'] as List;
      return importers.map((e) => ApiOrder.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> cancelOrder(Auth auth,
    {required ApiOrder order, String? messageForDealer}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation CancelOrder($order_uuid: String!, $messageForDealer: String) {
            cancelOrder(order_uuid: $order_uuid, messageForDealer: $messageForDealer) {
              message
            }
          }
        ''',
        ),
        variables: {
          "order_uuid": order.uuid,
          "messageForDealer": messageForDealer
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> pendingOrder(Auth auth, {required ApiOrder order}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation PendingOrder($order_uuid: String!) {
            pendingOrder(order_uuid: $order_uuid) {
              message
            }
          }
        ''',
        ),
        variables: {
          "order_uuid": order.uuid,
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> reorder(Auth auth, {required ApiOrder order}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation Reorder($order_uuid: String!) {
            reorder(order_uuid: $order_uuid) {
              message
            }
          }
        ''',
        ),
        variables: {
          "order_uuid": order.uuid,
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> placeOrder(Auth auth, {required ApiOrder order}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation PlaceOrder($order_uuid: String!) {
            placeOrder(order_uuid: $order_uuid) {
              message
            }
          }
        ''',
        ),
        variables: {
          "order_uuid": order.uuid,
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> editOrder(Auth auth,
    {required ApiOrder order, required int quantity}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(
        r'''
          mutation EditOrder($quantity: Float!, $orderUuid: String!) {
            editOrder(quantity: $quantity, order_uuid: $orderUuid) {
              message
            }
          }
        ''',
      ),
      variables: {"quantity": quantity, "orderUuid": order.uuid},
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> changeStatusAdmin(
  Auth auth, {
  required ApiOrder order,
  required ApiOrderStatusTypes status,
  String? messageForDealer,
  String? messageForBackoffice,
  int? delivered,
  String? notes,
  String? deliveredPaymentType,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(
        r'''
          mutation ChangeStatusAdmin(
            $orderUuid: String!
            $status: OrderStatusTypes!
            $messageForDealer: String
            $messageForBackoffice: String
            $delivered: Float
            $notes: String
            $deliveryPaymentType: String
          ) {
            changeStatusAdmin(
              orderUUID: $orderUuid
              status: $status
              messageForDealer: $messageForDealer
              messageForBackoffice: $messageForBackoffice
              delivered: $delivered
              notes: $notes
              deliveryPaymentType: $deliveryPaymentType
            ) {
              message
            }
          }
        ''',
      ),
      variables: {
        "orderUuid": order.uuid,
        "status": status.toString().split('.').last,
        "messageForDealer": messageForDealer,
        "messageForBackoffice": messageForBackoffice,
        'delivered': delivered,
        'deliveryPaymentType': deliveredPaymentType,
        'notes': notes,
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> changeStatusBackoffice(
  Auth auth, {
  required ApiOrder order,
  required ApiOrderStatusTypes status,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(
        r'''
          mutation ChangeStatusBackoffice($orderUuid: String!, $status: OrderStatusTypes!) {
            changeStatusBackoffice(orderUUID: $orderUuid, status: $status) {
              message
            }
          }
        ''',
      ),
      variables: {
        "orderUuid": order.uuid,
        "status": status.toString().split('.').last,
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> updateOrder(Auth auth,
    {required ApiOrder order, required ApiOrderStatusTypes status}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation ChangeStatusAdmin($orderUuid: String!, $status: OrderStatusTypes!) {
            changeStatusAdmin(orderUUID: $orderUuid, status: $status) {
              message
            }
          }
        ''',
        ),
        variables: {
          "orderUuid": order.uuid,
          "status": status.toString().split('.').last,
        });
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<List<ApiMessage>?> getMessages(Auth auth, {required String uuid}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query GetMessages($uuid: String!) {
            getMessages(uuid: $uuid) {
              uuid
              type
              message
              createdAt
              user {
                uuid
                firstName
                lastName
                email
                userType {
                  slug
                  title
                }
              }
            }
          }
        '''),
      variables: {
        'uuid': uuid,
      },
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var messages = response.data!['getMessages'] as List;
      return messages.map((e) => ApiMessage.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiMessage?> postMessage(Auth auth,
    {required String message, required String roomUUID}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          mutation PostMessage($message: String!, $roomUuid: String!) {
            postMessage(message: $message, roomUUID: $roomUuid) {
              uuid
              message
              type
              createdAt
              messageRoom {
                uuid
              }
              user {
                uuid
                firstName
                lastName
                email
              }
            }
          }
        '''),
      variables: {'roomUuid': roomUUID, 'message': message},
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiMessage.fromJSON(response.data!['postMessage']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiInventory?> loadOrderInventory(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(document: gql(r'''
          query InventoryOfOrder($uuid: String!) {
            inventoryOfOrder(uuid: $uuid) {
              uuid
              type
              quantity
              importers {
                uuid
                name
                phone
                email
                city
                address
              }
            }
          }
        '''), variables: {'uuid': uuid});
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiInventory.fromJSON(response.data!['inventoryOfOrder']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> updateOrderContacts(
    Auth auth, ApiOrder order, List<ApiOrderContact> contacts) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          mutation UpdateOrderContacts(
            $data: OrderContactUpdateData!
            $orderUuid: String!
          ) {
            updateOrderContacts(data: $data, order_uuid: $orderUuid) {
              message
            }
          }
        '''),
      variables: {
        "orderUuid": order.uuid,
        "data": {
          "contacts": contacts.map((e) {
            return {"name": e.name, "phone": e.phone};
          }).toList()
        }
      },
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<bool?> setReadByAccounting(Auth auth,
    {required ApiDelivery delivery, required bool isRead}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
        document: gql(
          r'''
          mutation SetReadByAccounting($isRead: Boolean!, $uuid: String!) {
            setReadByAccounting(isRead: $isRead, uuid: $uuid)
          }
        ''',
        ),
        variables: {"uuid": delivery.uuid, "isRead": isRead});
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

class ReportsOutput {
  List<ApiOrder> orders;
  List<ApiDelivery> deliveries;
  List<ApiCustomOrder> customOrders;
  String reportsUrl;

  ReportsOutput({
    required this.orders,
    required this.reportsUrl,
    required this.customOrders,
    required this.deliveries,
  });

  factory ReportsOutput.fromJSON(Map<String, dynamic> json) {
    List<ApiOrder> orders = [];
    if (json['orders'] != null) {
      var o = json['orders'] as List;
      orders = o.map((e) => ApiOrder.fromJSON(e)).toList();
    }

    List<ApiCustomOrder> customOrders = [];
    if (json['customOrders'] != null) {
      var o = json['customOrders'] as List;
      customOrders = o.map((e) => ApiCustomOrder.fromJSON(e)).toList();
    }

    List<ApiDelivery> deliveries = [];
    if (json['deliveries'] != null) {
      var o = json['deliveries'] as List;
      deliveries = o.map((e) => ApiDelivery.fromJSON(e)).toList();
    }

    return ReportsOutput(
      orders: orders,
      customOrders: customOrders,
      deliveries: deliveries,
      reportsUrl: json['reportsUrl'],
    );
  }
}

Future<ReportsOutput?> loadReports(
  Auth auth, {
  List<ApiOrderStatusTypes>? type,
  DateTime? startDate,
  DateTime? endDate,
  String? dealerName,
  String? patternNo,
  String? catalogUUID,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Reports($query: ReportsInput!) {
            reports(query: $query) {
              reportsUrl
              deliveries {
                delivered
                notes
                paymentType
                uuid
                readByAccounting
                createdAt
                order {
                  sid
                  uuid
                  reference
                  quantity
                  patternNo
                  type
                  createdAt
                  catalogue {
                    name
                    uuid
                  }
                  user {
                    uuid
                    firstName
                    lastName
                    email
                    userProfile {
                      companyName
                      insidePune
                      city
                      phone
                      address
                    }
                  }
                }
              }
              customOrders {
                height
                width
                name
                title
                createdAt
                phone
                remarks
              }
              orders {
                sid
                uuid
                reference
                quantity
                patternNo
                type
                createdAt
                catalogue {
                  name
                  uuid
                }
                user {
                  uuid
                  firstName
                  lastName
                  email
                  userProfile {
                    companyName
                    insidePune
                    city
                    phone
                    address
                  }
                }
                status {
                  slug
                  status
                }
              }
            }
          }
        '''),
      variables: {
        "query": {
          "status": type?.map((e) => e.toString().split('.').last).toList(),
          "startDate": startDate?.toIso8601String(),
          "endDate": endDate?.toIso8601String(),
          "dealerName": dealerName,
          "patternNo": patternNo,
          "catalagueUuid": catalogUUID,
        }
      },
    );
    print(jsonEncode(query.variables).toString());
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ReportsOutput.fromJSON(response.data!['reports']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}
