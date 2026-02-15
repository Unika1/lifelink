import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/organ_donation_request/data/datasources/organ_request_datasource.dart';
import 'package:lifelink/feature/organ_donation_request/data/models/organ_request_api_model.dart';

final organRequestRemoteDataSourceProvider =
    Provider<IOrganRequestRemoteDataSource>((ref) {
  return OrganRequestRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class OrganRequestRemoteDataSource implements IOrganRequestRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  OrganRequestRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  Options _authOptions() {
    final token = _tokenService.getToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<OrganRequestApiModel> createRequest({
    required OrganRequestApiModel request,
    required File reportFile,
  }) async {
    final fileName = reportFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'hospitalId': request.hospitalId,
      'hospitalName': request.hospitalName,
      'donorName': request.donorName,
      'requestedBy': request.requestedBy,
      'notes': request.notes,
      'report': await MultipartFile.fromFile(
        reportFile.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.post(
      ApiEndpoints.organRequests,
      data: formData,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return OrganRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.organRequests),
      message: response.data['message'] ?? 'Failed to create request',
    );
  }

  @override
  Future<List<OrganRequestApiModel>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (hospitalId != null) queryParameters['hospitalId'] = hospitalId;
    if (hospitalName != null) queryParameters['hospitalName'] = hospitalName;
    if (requestedBy != null) queryParameters['requestedBy'] = requestedBy;
    if (status != null) queryParameters['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.organRequests,
      query: queryParameters,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] as List;
      return data
          .map((json) => OrganRequestApiModel.fromJson(json))
          .toList();
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.organRequests),
      message: response.data['message'] ?? 'Failed to fetch requests',
    );
  }

  @override
  Future<OrganRequestApiModel> getRequestById(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.organRequestById(id),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return OrganRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.organRequestById(id)),
      message: response.data['message'] ?? 'Failed to fetch request',
    );
  }

  @override
  Future<OrganRequestApiModel> updateRequest(
    String id,
    OrganRequestApiModel request,
    {File? reportFile}
  ) async {
    final data = request.toJson()..removeWhere((key, value) => value == null);

    final dynamic requestBody;
    if (reportFile != null) {
      final fileName = reportFile.path.split(Platform.pathSeparator).last;
      requestBody = FormData.fromMap({
        ...data,
        'report': await MultipartFile.fromFile(
          reportFile.path,
          filename: fileName,
        ),
      });
    } else {
      requestBody = data;
    }

    final response = await _apiClient.put(
      ApiEndpoints.organRequestById(id),
      data: requestBody,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return OrganRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.organRequestById(id)),
      message: response.data['message'] ?? 'Failed to update request',
    );
  }

  @override
  Future<void> deleteRequest(String id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.organRequestById(id),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      return;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.organRequestById(id)),
      message: response.data['message'] ?? 'Failed to delete request',
    );
  }
}
