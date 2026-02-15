import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/blood_banks/data/repositories/blood_bank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:riverpod/riverpod.dart';

final getBloodBankByIdUsecaseProvider = Provider<GetBloodBankByIdUsecase>((ref) {
  final repository = ref.read(bloodBankRepositoryProvider);
  return GetBloodBankByIdUsecase(repository: repository);
});

class GetBloodBankByIdUsecase
    implements UsecaseWithParams<BloodBankEntity, String> {
  final IBloodBankRepository _repository;

  GetBloodBankByIdUsecase({required IBloodBankRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, BloodBankEntity>> call(String bloodBankId) {
    return _repository.getBloodBankById(bloodBankId);
  }
}
