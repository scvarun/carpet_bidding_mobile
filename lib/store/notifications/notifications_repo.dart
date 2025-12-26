import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/notification.dart';

Future<List<ApiNotification>> loadNotifications(Auth auth) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Notifications {
            notifications {
              uuid
              title
              message
              isRead
              createdAt
              updatedAt
              notificationType {
                title
                slug
              }
            }
          }
        '''),
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var notifications = response.data!['notifications'] as List;
      return notifications.map((e) => ApiNotification.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiNotification?> loadNotification(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(document: gql(r'''
          query Notification($uuid: String!) {
            notification(uuid: $uuid) {
              uuid
              title
              message
              isRead
              createdAt
              updatedAt
              notificationType {
                slug
                title
              }
            }
          }
        '''), variables: {"uuid": uuid});
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiNotification.fromJSON(response.data!['notification']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}
