import 'package:carpet_app/models/importer.dart';

class ApiCatalogue {
  String name;
  final String? uuid;
  String? rate;
  String? size;

  ApiCatalogue({required this.name, this.uuid, this.rate, this.size}) : super();

  factory ApiCatalogue.fromJSON(Map<String, dynamic> json) {
    return ApiCatalogue(
      name: json['name'],
      uuid: json['uuid'],
      rate: json['rate'],
      size: json['size'],
    );
  }
}

enum ApiInventoryTypes { rolls, catalog }

class ApiInventory {
  String? uuid;
  String? type;
  int? quantity;
  List<ApiImporter>? importers;
  List<ApiInventory>? similarInventories;
  ApiCatalogue? catalogue;
  ApiRoll? roll;

  ApiInventory(
      {this.uuid,
      this.type,
      this.quantity,
      this.catalogue,
      this.importers,
      this.similarInventories,
      this.roll})
      : super();

  factory ApiInventory.fromJSON(Map<String, dynamic> json) {
    ApiCatalogue? catalogue;
    if (json['catalogue'] != null) {
      catalogue = ApiCatalogue.fromJSON(json['catalogue']);
    }

    List<ApiImporter>? importers;
    if (json['importers'] != null) {
      importers = (json['importers'] as List)
          .map((e) => ApiImporter.fromJSON(e))
          .toList();
    }

    List<ApiInventory>? similarInventories;
    if (json['similarInventories'] != null) {
      similarInventories = (json['similarInventories'] as List)
          .map((e) => ApiInventory.fromJSON(e))
          .toList();
    }

    ApiRoll? roll;
    if (json['roll'] != null) {
      roll = ApiRoll.fromJSON(json['roll']);
    }

    return ApiInventory(
      uuid: json['uuid'],
      type: json['type'],
      quantity: json['quantity'],
      catalogue: catalogue,
      importers: importers,
      roll: roll,
      similarInventories: similarInventories,
    );
  }

  bool isType(ApiInventoryTypes inventoryType) {
    if (inventoryType == ApiInventoryTypes.rolls && type == 'rolls') {
      return true;
    } else if (inventoryType == ApiInventoryTypes.catalog &&
        type == 'catalog') {
      return true;
    }
    return false;
  }

  ApiInventoryTypes get inventoryType {
    if (type == 'catalog') {
      return ApiInventoryTypes.catalog;
    }
    return ApiInventoryTypes.rolls;
  }
}

class ApiRoll {
  String? patternNo;

  ApiRoll({this.patternNo}) : super();

  factory ApiRoll.fromJSON(Map<String, dynamic> json) {
    return ApiRoll(
      patternNo: json['patternNo'],
    );
  }
}
