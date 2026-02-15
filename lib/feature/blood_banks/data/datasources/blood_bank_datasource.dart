import 'package:lifelink/feature/blood_banks/data/models/blood_bank_api_model.dart';

abstract interface class IBloodBankRemoteDataSource {
  Future<List<BloodBankApiModel>> getAllBloodBanks({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  });

  Future<BloodBankApiModel> getBloodBankById(String id);

  Future<List<BloodInventoryApiModel>> getBloodBankInventory(String bloodBankId);
}
