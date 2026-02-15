import '../../domain/repositories/hospital_repository.dart';
import '../../domain/entities/hospital_entity.dart';

class HospitalRepository implements IHospitalRepository {
	@override
	Future<List<HospitalEntity>> getNearbyHospitals() async {
		return const [];
	}
}
