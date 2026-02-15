import 'package:lifelink/feature/hospital/domain/usecases/get_all_hospitals_usecase.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_hospital_by_id_usecase.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_hospital_inventory_usecase.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:riverpod/riverpod.dart';

final hospitalViewModelProvider =
    NotifierProvider<HospitalViewModel, HospitalState>(
  () => HospitalViewModel(),
);

class HospitalViewModel extends Notifier<HospitalState> {
  late final GetAllHospitalsUsecase _getAllHospitalsUsecase;
  late final GetHospitalByIdUsecase _getHospitalByIdUsecase;
  late final GetHospitalInventoryUsecase _getHospitalInventoryUsecase;

  @override
  HospitalState build() {
    _getAllHospitalsUsecase = ref.read(getAllHospitalsUsecaseProvider);
    _getHospitalByIdUsecase = ref.read(getHospitalByIdUsecaseProvider);
    _getHospitalInventoryUsecase =
        ref.read(getHospitalInventoryUsecaseProvider);
    return const HospitalState();
  }

  /// Fetch all hospitals (optionally filtered)
  Future<void> getAllHospitals({
    String? city,
    String? filterState,
    String? bloodType,
    bool? isActive,
  }) async {
    state = state.copyWith(status: HospitalStatus.loading, errorMessage: null);

    final params = GetAllHospitalsParams(
      city: city,
      state: filterState,
      bloodType: bloodType,
      isActive: isActive,
    );

    final result = await _getAllHospitalsUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: HospitalStatus.error,
          errorMessage: failure.message,
        );
      },
      (hospitals) {
        state = state.copyWith(
          status: HospitalStatus.loaded,
          hospitals: hospitals,
        );
      },
    );
  }

  /// Fetch a single hospital's detail
  Future<void> getHospitalById(String id) async {
    state = state.copyWith(status: HospitalStatus.loading, errorMessage: null);

    final result = await _getHospitalByIdUsecase(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: HospitalStatus.error,
          errorMessage: failure.message,
        );
      },
      (hospital) {
        state = state.copyWith(
          status: HospitalStatus.loaded,
          selectedHospital: hospital,
          inventory: hospital.bloodInventory,
        );
      },
    );
  }

  /// Fetch blood inventory for a hospital
  Future<void> getHospitalInventory(String hospitalId) async {
    final result = await _getHospitalInventoryUsecase(hospitalId);

    result.fold(
      (failure) {
        // Silently fail for inventory — don't override hospital state
      },
      (inventory) {
        state = state.copyWith(inventory: inventory);
      },
    );
  }

  /// Clear selected hospital (when navigating back)
  void clearSelectedHospital() {
    state = state.copyWith(
      selectedHospital: null,
      inventory: [],
    );
  }
}
