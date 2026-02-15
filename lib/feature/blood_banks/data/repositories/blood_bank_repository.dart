import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/data/datasources/blood_bank_datasource.dart';
import 'package:lifelink/feature/blood_banks/data/datasources/remote/blood_bank_remote_datasource.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:riverpod/riverpod.dart';

final bloodBankRepositoryProvider = Provider<IBloodBankRepository>((ref) {
	final remoteDataSource = ref.read(bloodBankRemoteDataSourceProvider);
	return BloodBankRepository(remoteDataSource: remoteDataSource);
});

class BloodBankRepository implements IBloodBankRepository {
	final IBloodBankRemoteDataSource _remoteDataSource;

	BloodBankRepository({required IBloodBankRemoteDataSource remoteDataSource})
			: _remoteDataSource = remoteDataSource;

	@override
	Future<Either<Failure, List<BloodBankEntity>>> getAllBloodBanks({
		String? city,
		String? state,
		String? bloodType,
		bool? isActive,
	}) async {
		try {
			final models = await _remoteDataSource.getAllBloodBanks(
				city: city,
				state: state,
				bloodType: bloodType,
				isActive: isActive,
			);
			return Right(models.map((model) => model.toEntity()).toList());
		} catch (e) {
			return Left(ApiFailure(message: e.toString()));
		}
	}

	@override
	Future<Either<Failure, BloodBankEntity>> getBloodBankById(String id) async {
		try {
			final model = await _remoteDataSource.getBloodBankById(id);
			return Right(model.toEntity());
		} catch (e) {
			return Left(ApiFailure(message: e.toString()));
		}
	}

	@override
	Future<Either<Failure, List<BloodInventoryEntity>>> getBloodBankInventory(
		String bloodBankId,
	) async {
		try {
			final models = await _remoteDataSource.getBloodBankInventory(bloodBankId);
			return Right(models.map((model) => model.toEntity()).toList());
		} catch (e) {
			return Left(ApiFailure(message: e.toString()));
		}
	}
}
