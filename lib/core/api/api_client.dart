import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_endpoints.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        sendTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return dio.post(path, data: data, options: options);
  }
   Future<Response> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    return dio.get(path, queryParameters: query, options: options);
  }
  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return dio.put(path, data: data, options: options);
  }

  Future<Response> delete(
    String path, {
    Options? options,
  }) async {
    return dio.delete(path, options: options);
  }

  //for image upload
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return dio.put(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}
