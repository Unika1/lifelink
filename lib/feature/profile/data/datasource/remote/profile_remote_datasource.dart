import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/profile/data/datasource/profile_datasource.dart';
import 'package:lifelink/feature/profile/data/models/profile_api_model.dart';

final profileRemoteDatasourceProvider =
    Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class ProfileRemoteDatasource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// GET /auth/me
  @override
  Future<ProfileApiModel> getMe(String token) async {
    final res = await _apiClient.get(
      ApiEndpoints.me,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return ProfileApiModel.fromJson(
      Map<String, dynamic>.from(res.data['data']),
    );
  }

  /// PUT /auth/update-profile
  @override
  Future<String> uploadProfilePhoto({
    required String token,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });

    final res = await _apiClient.uploadFile(
      ApiEndpoints.updateProfile,
      formData: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    // backend returns: { data: { imageUrl: "/uploads/xyz.jpg" } }
    return res.data['data']['imageUrl'] as String;
  }
}
