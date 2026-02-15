import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/services/hive/hive_service.dart';
import 'package:lifelink/core/provider/hive_service_provider.dart';
import 'package:lifelink/feature/profile/data/datasources/profile_datasource.dart';
import 'package:lifelink/feature/profile/data/models/profile_hive_model.dart';

final profileLocalDatasourceProvider = Provider<IProfileLocalDataSource>((ref) {
	final hiveService = ref.read(hiveServiceProvider);
	return ProfileLocalDatasource(hiveService: hiveService);
});

class ProfileLocalDatasource implements IProfileLocalDataSource {
	final HiveService _hiveService;

	ProfileLocalDatasource({required HiveService hiveService})
			: _hiveService = hiveService;

	@override
	Future<bool> cacheProfile(ProfileHiveModel profile) async {
		try {
			await _hiveService.cacheProfile(profile);
			return true;
		} catch (_) {
			return false;
		}
	}

	@override
	Future<ProfileHiveModel?> getCachedProfile(String userId) async {
		try {
			return await _hiveService.getCachedProfile(userId);
		} catch (_) {
			return null;
		}
	}

	@override
	Future<bool> clearProfile(String userId) async {
		try {
			await _hiveService.clearProfile(userId);
			return true;
		} catch (_) {
			return false;
		}
	}

	@override
	Future<bool> updateCachedImage(String userId, String imageUrl) async {
		try {
			await _hiveService.updateCachedProfileImage(userId, imageUrl);
			return true;
		} catch (_) {
			return false;
		}
	}
}
