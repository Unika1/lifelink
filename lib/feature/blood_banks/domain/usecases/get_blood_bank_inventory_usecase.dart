import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/blood_banks/data/repositories/blood_bank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:riverpod/riverpod.dart';

final getBloodBankInventoryUsecaseProvider =
    Provider<GetBloodBankInventoryUsecase>((ref) {
  final repository = ref.read(bloodBankRepositoryProvider);
  return GetBloodBankInventoryUsecase(repository: repository);
});

class GetBloodBankInventoryUsecase
    implements UsecaseWithParams<List<BloodInventoryEntity>, String> {
  final IBloodBankRepository _repository;

  GetBloodBankInventoryUsecase({required IBloodBankRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<BloodInventoryEntity>>> call(String bloodBankId) {
    return _repository.getBloodBankInventory(bloodBankId);
  }
}
