import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.connectTimeout = const Duration(seconds: 30);
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Dio get dio => _dio;
}
