import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';

abstract interface class IBloodBankRepository {
	Future<Either<Failure, List<BloodBankEntity>>> getAllBloodBanks({
		String? city,
		String? state,
		String? bloodType,
		bool? isActive,
	});

	Future<Either<Failure, BloodBankEntity>> getBloodBankById(String id);

	Future<Either<Failure, List<BloodInventoryEntity>>> getBloodBankInventory(
		String bloodBankId,
	);
}
