import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/blood_banks/data/repositories/blood_bank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:riverpod/riverpod.dart';

class GetAllBloodBanksParams extends Equatable {
  final String? city;
  final String? state;
  final String? bloodType;
  final bool? isActive;

  const GetAllBloodBanksParams({
    this.city,
    this.state,
    this.bloodType,
    this.isActive,
  });

  @override
  List<Object?> get props => [city, state, bloodType, isActive];
}

final getAllBloodBanksUsecaseProvider = Provider<GetAllBloodBanksUsecase>((ref) {
  final repository = ref.read(bloodBankRepositoryProvider);
  return GetAllBloodBanksUsecase(repository: repository);
});

class GetAllBloodBanksUsecase
    implements UsecaseWithParams<List<BloodBankEntity>, GetAllBloodBanksParams> {
  final IBloodBankRepository _repository;

  GetAllBloodBanksUsecase({required IBloodBankRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<BloodBankEntity>>> call(
    GetAllBloodBanksParams params,
  ) {
    return _repository.getAllBloodBanks(
      city: params.city,
      state: params.state,
      bloodType: params.bloodType,
      isActive: params.isActive,
    );
  }
}
