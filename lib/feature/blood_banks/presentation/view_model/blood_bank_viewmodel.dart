import 'package:lifelink/feature/blood_banks/domain/usecases/get_all_blood_banks_usecase.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_by_id_usecase.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_inventory_usecase.dart';
import 'package:lifelink/feature/blood_banks/presentation/state/blood_bank_state.dart';
import 'package:riverpod/riverpod.dart';

final bloodBankViewModelProvider =
		NotifierProvider<BloodBankViewModel, BloodBankState>(
	() => BloodBankViewModel(),
);

class BloodBankViewModel extends Notifier<BloodBankState> {
	late final GetAllBloodBanksUsecase _getAllBloodBanksUsecase;
	late final GetBloodBankByIdUsecase _getBloodBankByIdUsecase;
	late final GetBloodBankInventoryUsecase _getBloodBankInventoryUsecase;

	@override
	BloodBankState build() {
		_getAllBloodBanksUsecase = ref.read(getAllBloodBanksUsecaseProvider);
		_getBloodBankByIdUsecase = ref.read(getBloodBankByIdUsecaseProvider);
		_getBloodBankInventoryUsecase =
				ref.read(getBloodBankInventoryUsecaseProvider);
		return const BloodBankState();
	}

	Future<void> getAllBloodBanks({
		String? city,
		String? filterState,
		String? bloodType,
		bool? isActive,
	}) async {
		state = state.copyWith(status: BloodBankStatus.loading, errorMessage: null);

		final params = GetAllBloodBanksParams(
			city: city,
			state: filterState,
			bloodType: bloodType,
			isActive: isActive,
		);

		final result = await _getAllBloodBanksUsecase(params);

		result.fold(
			(failure) {
				state = state.copyWith(
					status: BloodBankStatus.error,
					errorMessage: failure.message,
				);
			},
			(bloodBanks) {
				state = state.copyWith(
					status: BloodBankStatus.loaded,
					bloodBanks: bloodBanks,
				);
			},
		);
	}

	Future<void> getBloodBankById(String id) async {
		state = state.copyWith(status: BloodBankStatus.loading, errorMessage: null);

		final result = await _getBloodBankByIdUsecase(id);

		result.fold(
			(failure) {
				state = state.copyWith(
					status: BloodBankStatus.error,
					errorMessage: failure.message,
				);
			},
			(bloodBank) {
				state = state.copyWith(
					status: BloodBankStatus.loaded,
					selectedBloodBank: bloodBank,
					inventory: bloodBank.bloodInventory,
				);
			},
		);
	}

	Future<void> getBloodBankInventory(String bloodBankId) async {
		final result = await _getBloodBankInventoryUsecase(bloodBankId);

		result.fold(
			(failure) {},
			(inventory) {
				state = state.copyWith(inventory: inventory);
			},
		);
	}

	void clearSelectedBloodBank() {
		state = state.copyWith(
			selectedBloodBank: null,
			inventory: [],
		);
	}
}
