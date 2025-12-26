import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/importer.dart';

Future<List<ApiImporter>?> loadImporters(Auth auth) async {
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
      return importers.map((e) => ApiImporter.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiImporter?> loadImporter(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(document: gql(r'''
          query Importer($uuid: String!) {
            importer(uuid: $uuid) {
              uuid
              name
              email
              phone
              city
              address
            }
          }
        '''), variables: {'uuid': uuid});
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiImporter.fromJSON(response.data!['importer']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiImporter?> addImporter(Auth auth, ApiImporter model) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(r'''
          mutation AddImporter($data: ImporterAddIput!) {
            addImporter(data: $data) {
              uuid
              city
              address
              name
              email
              phone
            }
          }
        '''),
      variables: {
        'data': {
          'name': model.name,
          'email': model.email,
          'phone': model.phone,
          'city': model.city,
          'address': model.address,
        }
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiImporter.fromJSON(response.data!['addImporter']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiImporter?> updateImporter(Auth auth, ApiImporter model) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(r'''
         mutation UpdateImporter($data: ImporterUpdateInput!, $uuid: String!) {
          updateImporter(data: $data, uuid: $uuid) {
            uuid
            name
            phone
            email
            city
            address
          }
        }
        '''),
      variables: {
        'uuid': model.uuid,
        'data': {
          'name': model.name,
          'email': model.email,
          'phone': model.phone,
          'city': model.city,
          'address': model.address,
        }
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiImporter.fromJSON(response.data!['updateImporter']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}
