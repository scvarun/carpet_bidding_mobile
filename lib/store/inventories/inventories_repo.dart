import 'package:graphql/client.dart';
import 'package:carpet_app/lib/graphql.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/auth.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/query_input.dart';

Future<List<ApiCatalogue>?> loadCatalogues(Auth auth) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query Catalogues {
            catalogues {
              uuid
              name
              rate
              size
            }
          }
        '''),
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      var catalogues = response.data!['catalogues'] as List;
      return catalogues.map((e) => ApiCatalogue.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiCatalogue?> addCatalogue(Auth auth, String name,
    {String? size, String? rate}) async {
  try {
    final client = apiClient(auth: auth);
    final query = MutationOptions(
      document: gql(r'''
          mutation AddCatalogue($data: CatalogueAddInput!) {
            addCatalogue(data: $data) {
              name
              uuid
            }
          }
        '''),
      variables: {
        'data': {
          'name': name,
          'size': size,
          'rate': rate,
        },
      },
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiCatalogue.fromJSON(response.data!['addCatalogue']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

class InventoryPatternData {
  String? patternNo;
  int quantity;
  List<ApiInventory> similarInventories;
  ApiInventoryTypes type;

  InventoryPatternData(
      {this.patternNo,
      required this.quantity,
      required this.similarInventories,
      required this.type});

  Map toJSON() {
    return {
      'patternNo': patternNo,
      'quantity': quantity,
      'similarInventoryUUIDs': similarInventories.map((e) => e.uuid).toList(),
      'type': type.toString().split('.').last,
    };
  }
}

class InventoryData {
  String catalogueUUID;
  List<String> importersUUID;
  List<InventoryPatternData> patterns;

  InventoryData(
      {required this.catalogueUUID,
      required this.importersUUID,
      required this.patterns});
}

Future<List<ApiInventory>?> addInventories(Auth auth,
    {required ApiCatalogue catalogue,
    required List<ApiImporter> importers,
    required List<InventoryPatternData> patterns}) async {
  try {
    final client = apiClient(auth: auth);
    var variables = {
      "data": {
        "catalogueUUID": catalogue.uuid,
        "importersUUID": importers.map((e) => e.uuid).toList(),
        "patterns": patterns.map((e) => e.toJSON()).toList(),
      }
    };
    final query = MutationOptions(
      document: gql(r'''
          mutation AddInventories($data: InventoryAddInput!) {
            addInventories(data: $data) {
              uuid
              quantity
              type
              catalogue {
                name
                uuid
                size
                rate
              }
              importers {
                uuid
                name
                email
                phone
              }
            }
          }
        '''),
      variables: variables,
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return (response.data!['addInventories'] as List)
          .map((e) => ApiInventory.fromJSON(e))
          .toList();
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiInventory?> updateInventory(Auth auth,
    {required List<ApiImporter> importers,
    required List<ApiInventory> similarInventories,
    required ApiInventory inventory}) async {
  try {
    final client = apiClient(auth: auth);
    var variables = {
      "data": {
        "inventoryUUID": inventory.uuid,
        "importersUUID": importers.map((e) => e.uuid).toList(),
        'patternNo': inventory.roll?.patternNo,
        'catalogName': inventory.catalogue?.name,
        "quantity": inventory.quantity,
        "rate": inventory.catalogue!.rate,
        "size": inventory.catalogue!.size,
        "similarInventoryUUIDs": similarInventories.map((e) => e.uuid).toList(),
      }
    };
    final query = MutationOptions(
      document: gql(r'''
          mutation UpdateInventories($data: InventoryUpdateInput!) {
            updateInventories(data: $data) {
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
              catalogue {
                uuid
                name
                size
                rate
                createdAt
                updatedAt
              }
              roll {
                patternNo
              }
            }
          }
        '''),
      variables: variables,
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiInventory.fromJSON(response.data!['updateInventories']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

class InventoryListOutput {
  int page;
  int total;
  int perPage;
  int lastPage;
  List<ApiInventory> inventories;

  InventoryListOutput({
    required this.page,
    required this.inventories,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory InventoryListOutput.fromJSON(Map<String, dynamic> json) {
    List<ApiInventory> inventories = [];
    if (json['inventories'] != null) {
      inventories = (json['inventories'] as List)
          .map((e) => ApiInventory.fromJSON(e))
          .toList();
    }
    return InventoryListOutput(
      page: json['page'],
      inventories: inventories,
      total: json['total'],
      perPage: json['perPage'],
      lastPage: json['lastPage'],
    );
  }
}

var defaultQuery = QueryInput(limit: 10, page: 1);

Future<InventoryListOutput> loadInventories(Auth auth, ApiInventoryTypes type,
    {QueryInput? query}) async {
  try {
    query = query ?? defaultQuery;
    final client = apiClient(auth: auth);
    final q = QueryOptions(document: gql(r'''
          query Inventories($query: InventoryQueryInput!) {
            inventories(query: $query) {
              page
              perPage
              total
              lastPage
              inventories {
                uuid
                type
                quantity
                importers {
                  uuid
                  name
                  email
                  phone
                  address
                  city
                }
                catalogue {
                  uuid
                  name
                  size
                  rate
                }
                roll {
                  patternNo
                }
              }
            }
          }
        '''), variables: {
      'query': {
        'type': type.toString().split('.').last,
        'limit': query.limit,
        'page': query.page,
        'search': query.search,
      }
    });
    final response = await client.query(q);
    if (response.hasException) throw response.exception!;
    var json = response.data ?? {};
    return InventoryListOutput.fromJSON(json['inventories']);
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiInventory?> loadInventory(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(document: gql(r'''
          query Inventory($uuid: String!) {
            inventory(uuid: $uuid) {
              uuid
              type
              similarInventories {
                uuid
                type
                roll {
                  patternNo
                }
              }
              importers {
                uuid
                email
                name
                phone
                city
                address
              }
              quantity
              catalogue {
                uuid
                name
                size
                rate
              }
              roll {
                patternNo
              }
            }
          }
        '''), variables: {'uuid': uuid});
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return ApiInventory.fromJSON(response.data!['inventory']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<String?> removeInventory(Auth auth, String uuid) async {
  try {
    final client = apiClient(auth: auth);
    var variables = {
      "uuid": uuid,
    };
    final query = MutationOptions(
      document: gql(r'''
          mutation RemoveInventory($uuid: String!) {
            removeInventory(uuid: $uuid) {
              message
            }
          }
        '''),
      variables: variables,
    );
    final response = await client.mutate(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null) {
      return response.data!['removeInventory']!['message'];
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<ApiInventory?> suggestInventories(Auth auth, String text) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query GetInventorySuggestions($text: String!) {
            getInventorySuggestions(text: $text) {
              uuid
              type
              quantity
              catalogue {
                uuid
                name
                size
                rate
                createdAt
                updatedAt
              }
              roll {
                patternNo
              }
          }
        '''),
      variables: {"text": text},
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null &&
        response.data!['getInventorySuggestions'] != null) {
      return ApiInventory.fromJSON(response.data!['getInventorySuggestions']);
    } else {
      return null;
    }
  } catch (e) {
    return Future.error(AppError.fromError(e));
  }
}

Future<List<ApiInventory>> suggestInventoriesList(
    Auth auth, String text) async {
  try {
    final client = apiClient(auth: auth);
    final query = QueryOptions(
      document: gql(r'''
          query GetInventorySuggestionsList($text: String!) {
            getInventorySuggestionsList(text: $text) {
              uuid
              type
              quantity
              catalogue {
                uuid
                name
                size
                rate
                createdAt
                updatedAt
              }
              roll {
                patternNo
              }
            }
          }
        '''),
      variables: {"text": text},
    );
    final response = await client.query(query);
    if (response.hasException) throw response.exception!;
    if (response.data != null &&
        response.data!['getInventorySuggestionsList'] != null) {
      var inventories = response.data!['getInventorySuggestionsList'] as List;
      return inventories.map((e) => ApiInventory.fromJSON(e)).toList();
    } else {
      return [];
    }
  } catch (e) {
    AppError.fromError(e);
    return [];
  }
}
