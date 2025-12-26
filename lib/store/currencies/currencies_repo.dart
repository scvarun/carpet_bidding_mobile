import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:carpet_app/config.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/currency.dart';

class CurrencyRepo {
  static final CurrencyRepo _currencyRepo = CurrencyRepo._internal();

  factory CurrencyRepo() {
    return _currencyRepo;
  }

  CurrencyRepo._internal();

  Future<List<ApiCurrency>> loadCurrencies() async {
    try {
      var response = await Dio().get('${CONFIG.apiUrl}/currencies');
      var jsonResponse = json.decode(response.toString());
      var coupons = (jsonResponse['currencies'] as List)
          .map((e) => ApiCurrency.fromJSON(e))
          .toList();
      return coupons;
    } catch (e) {
      return Future.error(AppError.fromError(e));
    }
  }
}
