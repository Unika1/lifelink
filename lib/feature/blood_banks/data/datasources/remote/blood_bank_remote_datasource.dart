import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:lifelink/feature/blood_banks/data/datasources/blood_bank_datasource.dart';
import 'package:lifelink/feature/blood_banks/data/models/blood_bank_api_model.dart';

final bloodBankRemoteDataSourceProvider =
    Provider<IBloodBankRemoteDataSource>((ref) {
  return BloodBankRemoteDataSource();
});

class BloodBankRemoteDataSource implements IBloodBankRemoteDataSource {
  static const String _searchUrl = 'https://nominatim.openstreetmap.org/search';
  final Dio _externalDio;
  List<BloodBankApiModel> _lastFetchedBloodBanks = const [];

  BloodBankRemoteDataSource()
      : _externalDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'lifelink-mobile-app/1.0',
            },
          ),
        );

  @override
  Future<List<BloodBankApiModel>> getAllBloodBanks({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  }) async {
    final queryParts = <String>['blood bank'];
    if (city != null && city.trim().isNotEmpty) {
      queryParts.add(city.trim());
    }
    if (state != null && state.trim().isNotEmpty) {
      queryParts.add(state.trim());
    }
    if ((city == null || city.trim().isEmpty) &&
        (state == null || state.trim().isEmpty)) {
      queryParts.add('Nepal');
    }

    final response = await _externalDio.get(
      _searchUrl,
      queryParameters: {
        'q': queryParts.join(', '),
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 100,
      },
    );

    final rawList = response.data;
    if (rawList is! List) {
      _lastFetchedBloodBanks = const [];
      return _lastFetchedBloodBanks;
    }

    final results = rawList
        .whereType<Map>()
        .map((item) => BloodBankApiModel.fromNominatim(item.cast<String, dynamic>()))
        .where((item) => item.location != null)
        .toList();

    _lastFetchedBloodBanks = results;
    return _lastFetchedBloodBanks;
  }

  @override
  Future<BloodBankApiModel> getBloodBankById(String id) async {
    final match = _lastFetchedBloodBanks.where((item) => item.id == id);
    if (match.isNotEmpty) {
      return match.first;
    }

    final all = await getAllBloodBanks();
    final refreshedMatch = all.where((item) => item.id == id);
    if (refreshedMatch.isNotEmpty) {
      return refreshedMatch.first;
    }

    throw Exception('Blood bank not found');
  }

  @override
  Future<List<BloodInventoryApiModel>> getBloodBankInventory(
    String bloodBankId,
  ) async {
    return const [];
  }
}
