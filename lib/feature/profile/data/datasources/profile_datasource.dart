import 'dart:io';
import 'package:lifelink/feature/profile/data/models/profile_hive_model.dart';
import 'package:lifelink/feature/profile/data/models/profile_api_model.dart';

abstract interface class IProfileLocalDataSource {
	Future<bool> cacheProfile(ProfileHiveModel profile);
	Future<ProfileHiveModel?> getCachedProfile(String userId);
	Future<bool> clearProfile(String userId);
	Future<bool> updateCachedImage(String userId, String imageUrl);
}

abstract interface class IProfileRemoteDataSource {
	Future<ProfileApiModel> getMe(String token);
	Future<String> uploadProfilePhoto({
		required String token,
		required File image,
	});
	Future<Map<String, dynamic>> updateProfile({
		required String token,
		required Map<String, dynamic> data,
	});
}
