import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/custom_order.dart';
import 'package:carpet_app/models/media.dart';

Future<List<ApiCustomOrder>?> loadCustomOrders(Auth auth) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query CustomOrders {
            customOrders {
              uuid
              title
              name
              phone
              width
              height
              remarks
              createdAt
            }
          }
        '''),
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var customOrders = response.data!['customOrders'] as List;
      return customOrders.map((e) => ApiCustomOrder.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiCustomOrder?> loadCustomOrder(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(document: gql(r'''
          query CustomOrder($uuid: String!) {
            customOrder(uuid: $uuid) {
              uuid
              title
              name
              phone
              width
              height
              remarks
              createdAt
              updatedAt
              image {
                url
                name
              }
            }
          }
        '''), variables: {
      'uuid': uuid,
    });
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiCustomOrder.fromJSON(response.data?['customOrder']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiCustomOrder?> addCustomOrder(
    Auth auth, ApiCustomOrder model, ApiMedia? media) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(r'''
          mutation AddCustomOrder($data: CustomOrderAddInput!) {
            addCustomOrder(data: $data) {
              uuid
              title
              name
              phone
              width
              height
              remarks
              createdAt
            }
          }
        '''),
      variables: {
        'data': {
          'name': model.name,
          'title': model.title,
          'remarks': model.remarks,
          'phone': model.phone,
          'width': model.width,
          'height': model.height,
          'image_uuid': media?.uuid,
        }
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiCustomOrder.fromJSON(response.data!['addCustomOrder']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiCustomOrder?> updateCustomOrder(
    Auth auth, ApiCustomOrder model, ApiMedia? media) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(r'''
          mutation UpdateCustomOrder($data: CustomOrderUpdateInput!, $uuid: String!) {
            updateCustomOrder(data: $data, uuid: $uuid) {
              uuid
              title
              name
              phone
              width
              height
              remarks
              createdAt
              updatedAt
            }
          }
        '''),
      variables: {
        'uuid': model.uuid,
        'data': {
          'name': model.name,
          'title': model.title,
          'remarks': model.remarks,
          'phone': model.phone,
          'width': model.width,
          'height': model.height,
          'image_uuid': media?.uuid
        }
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiCustomOrder.fromJSON(response.data!['updateCustomOrder']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}
