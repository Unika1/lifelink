import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/check_eligibility_usecase.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/submit_questionnaire_usecase.dart';
import 'package:lifelink/feature/eligibility/presentation/state/eligibility_state.dart';
import 'package:riverpod/riverpod.dart';

final eligibilityViewModelProvider =
    NotifierProvider<EligibilityViewModel, EligibilityState>(
  () => EligibilityViewModel(),
);

class EligibilityViewModel extends Notifier<EligibilityState> {
  late final SubmitQuestionnaireUsecase _submitQuestionnaireUsecase;
  late final CheckEligibilityUsecase _checkEligibilityUsecase;

  @override
  EligibilityState build() {
    _submitQuestionnaireUsecase =
        ref.read(submitQuestionnaireUsecaseProvider);
    _checkEligibilityUsecase = ref.read(checkEligibilityUsecaseProvider);
    return const EligibilityState();
  }

  /// Submit questionnaire then immediately check eligibility
  Future<bool> submitAndCheck(
      EligibilityQuestionnaireEntity questionnaire) async {
    state = state.copyWith(
        status: EligibilityStatus.loading, errorMessage: null);

    // Step 1: Submit
    final submitResult = await _submitQuestionnaireUsecase(questionnaire);

    return await submitResult.fold(
      (failure) {
        state = state.copyWith(
          status: EligibilityStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) async {
        // Step 2: Check
        final checkResult = await _checkEligibilityUsecase();

        return checkResult.fold(
          (failure) {
            state = state.copyWith(
              status: EligibilityStatus.error,
              errorMessage: failure.message,
            );
            return false;
          },
          (result) {
            state = state.copyWith(
              status: EligibilityStatus.checked,
              result: result,
            );
            return result.eligible;
          },
        );
      },
    );
  }

  void reset() {
    state = const EligibilityState();
  }
}
