import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/profile/domain/usecases/get_cached_profile_image_usecase.dart';
import 'package:lifelink/feature/profile/domain/usecases/upload_profile_usecase.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UploadProfileImageUsecase _uploadUsecase;
  late final GetCachedProfileImageUsecase _getCachedUsecase;

  @override
  ProfileState build() {
    _uploadUsecase = ref.read(uploadProfileImageUsecaseProvider);
    _getCachedUsecase = ref.read(getCachedProfileImageUsecaseProvider);

    _loadCached();
    return const ProfileState();
  }

  Future<void> _loadCached() async {
    final res = await _getCachedUsecase();
    res.fold(
      (_) {},
      (imageUrl) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          state = state.copyWith(
            status: ProfileStatus.loaded,
            profileImageUrl: imageUrl,
            errorMessage: null,
          );
        }
      },
    );
  }

  Future<void> uploadProfileImage(File image) async {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);

    final uploadRes = await _uploadUsecase(image);

    uploadRes.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageUrl) {
        // upload returns "/uploads/xyz.jpg"
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profileImageUrl: imageUrl,
          errorMessage: null,
        );
      },
    );
  }
  void setBloodGroup(String bloodGroup) {
    state = state.copyWith(
      status: ProfileStatus.loaded,
      bloodGroup: bloodGroup,
      errorMessage: null,
    );
  }
}
