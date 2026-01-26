import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';

final profileRemoteDatasourceProvider =
    Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(ref.read(apiClientProvider));
});

class ProfileRemoteDatasource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource(this._apiClient);

  Future<String> uploadProfileImage(File image) async {
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final res = await _apiClient.uploadFile(
      ApiEndpoints.uploadProfileImage,
      formData: formData,
    );

    // backend should return filename
    return res.data['data'];
  }
}
