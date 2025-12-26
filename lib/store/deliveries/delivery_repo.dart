import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/delivery.dart';

Future<List<ApiDelivery>?> loadDeliveries(
  Auth auth, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Deliveries($query: DeliveryQueryInput!) {
            deliveries(query: $query) {
              delivered
              notes
              paymentType
              order {
                uuid
                quantity
                reference
                type
                patternNo
                user {
                  uuid
                  firstName
                  lastName
                  email
                  userProfile {
                    companyName
                    city
                  }
                }
              }
            }
          }
        '''),
      variables: {
        "query": {
          "startDate": startDate?.toIso8601String(),
          "endDate": endDate?.toIso8601String()
        }
      },
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var orders = response.data!['deliveries'] as List;
      return orders.map((e) => ApiDelivery.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}
