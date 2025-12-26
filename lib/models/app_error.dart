import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:validators/validators.dart';

class AppError {
  final String name;
  final String message;
  final int statusCode;
  final String type;

  AppError({
    required this.name,
    required this.message,
    required this.type,
    this.statusCode = 401,
  }) {
    printError();
  }

  @override
  String toString() {
    return message;
  }

  void printError() {
    if((Platform.isAndroid || Platform.isIOS) && kDebugMode) {
      print('***********');
      print('AppError: ' + toString());
      print(StackTrace.current.toString());
      print('***********');
      // debugPrintStack(stackTrace: StackTrace.current, label: this.toString());
      // Log().logger.d(this.toString());
    }
  }

  factory AppError.fromJSON(Map<String, dynamic> json) {
    return AppError(
        message: json['message'],
        name: json['name'],
        statusCode: json['statusCode'],
        type: json['type']);
  }

  factory AppError.fromError(dynamic e) {
    if (e is AppError) {
      return e;
    }

    if (e is DioError) {
      return AppError.fromException(e);
    }

    if (e is Exception) {
      return AppError.fromException(e);
    }

    return AppError(
        name: e.toString(),
        message: e.toString(),
        type: 'danger',
        statusCode: -1);
  }

  factory AppError.fromException(Exception e) {
    if (e is DioError) {
      if (e.response != null && isJSON(e.response.toString())) {
        var jsonResponse = json.decode(e.response.toString());
        return AppError.fromErrorResponse(jsonResponse['error']);
      } else {
        return AppError(
            name: 'NetworkError',
            message: e.error,
            type: 'danger',
            statusCode: -1);
      }
    } else if (e is OperationException) {
      return AppError.fromGraphQLError(e.graphqlErrors.first);
    }

    return AppError(
        name: e.toString(),
        message: e.toString(),
        type: 'danger',
        statusCode: -1);
  }

  factory AppError.fromErrorResponse(Map<String, dynamic> errorResponse) {
    return AppError(
      name: errorResponse['name'],
      message: errorResponse['message'],
      statusCode: errorResponse['statusCode'],
      type: errorResponse['type'],
    );
  }

  factory AppError.fromGraphQLError(GraphQLError error) {
    return AppError(name: 'ApiError', message: error.message, type: 'danger');
  }

  void showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(toString())));
  }
}
