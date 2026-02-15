import 'package:lifelink/feature/hospital/data/models/hospital_api_model.dart';

abstract interface class IHospitalRemoteDataSource {
  /// Fetch all hospitals with optional query filters
  Future<List<HospitalApiModel>> getAllHospitals({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  });

  /// Fetch a single hospital by its ID
  Future<HospitalApiModel> getHospitalById(String id);

  /// Fetch blood inventory for a specific hospital
  Future<List<BloodInventoryApiModel>> getHospitalInventory(String hospitalId);
}
