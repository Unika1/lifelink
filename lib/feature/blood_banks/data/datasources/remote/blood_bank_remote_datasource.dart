import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;
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
    double? latitude,
    double? longitude,
    double? radiusKm,
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

    Map<String, dynamic>? nearbyParams;
    if (latitude != null && longitude != null) {
      final radius = (radiusKm ?? 15).clamp(1, 100);
      final latitudeDelta = radius / 111.0;
      final longitudeDelta = radius / (111.0 * _safeCos(latitude));
      final left = longitude - longitudeDelta;
      final right = longitude + longitudeDelta;
      final top = latitude + latitudeDelta;
      final bottom = latitude - latitudeDelta;

      nearbyParams = {
        'viewbox': '$left,$top,$right,$bottom',
        'bounded': 1,
      };
    }

    final response = await _externalDio.get(
      _searchUrl,
      queryParameters: {
        'q': queryParts.join(', '),
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 100,
        if (nearbyParams != null) ...nearbyParams,
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

    if (_lastFetchedBloodBanks.isEmpty && nearbyParams != null) {
      return await getAllBloodBanks(
        city: city,
        state: state,
        bloodType: bloodType,
        isActive: isActive,
      );
    }

    return _lastFetchedBloodBanks;
  }

  double _safeCos(double latitude) {
    const degToRad = 0.017453292519943295;
    final value = (latitude * degToRad).abs();
    final cosValue = value == 0 ? 1.0 : (value > 1.56 ? 0.01 : math.cos(value));
    return cosValue.abs() < 0.01 ? 0.01 : cosValue;
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
