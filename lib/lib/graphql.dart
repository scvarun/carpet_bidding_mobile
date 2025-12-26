import 'package:graphql/client.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:universal_io/io.dart';

GraphQLClient apiClient({Auth? auth}) {
  if (auth != null && auth.token != null) {
    Link _link = HttpLink(CONFIG.apiUrl, defaultHeaders: {
      'Authorization': auth.token!,
    });
    return GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  final Link _link = HttpLink(
    CONFIG.apiUrl,
  );
  return GraphQLClient(
    cache: GraphQLCache(),
    link: _link,
  );
}
