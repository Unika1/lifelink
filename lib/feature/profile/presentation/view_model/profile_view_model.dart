import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/profile/data/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/usecases/upload_profile_usecase.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UploadProfileImageUsecase _uploadUsecase;
  late final IProfileRepository _repository;

  @override
  ProfileState build() {
    _uploadUsecase = ref.read(uploadProfileImageUsecaseProvider);
    _repository = ref.read(profileRepositoryProvider);

    _loadCached();
    return const ProfileState();
  }

  Future<void> _loadCached() async {
    final res = await _repository.getProfile();
    res.fold(
      (_) {},
      (profile) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          profileImageUrl: profile.imageUrl,
          bloodGroup: profile.bloodGroup,
          phoneNumber: profile.phoneNumber,
          emergencyContact: profile.emergencyContact,
          errorMessage: null,
        );
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
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profileImageUrl: imageUrl,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> setBloodGroup(String bloodGroup) async {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);

    final result =
        await _repository.updateProfile({'bloodGroup': bloodGroup});

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          bloodGroup: bloodGroup,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> setPhoneNumber(String phone) async {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);

    final result =
        await _repository.updateProfile({'phoneNumber': phone});

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          phoneNumber: phone,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> setBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);

    final result = await _repository.updateProfile({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          firstName: firstName,
          lastName: lastName,
          email: email,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> setEmergencyContact(String contact) async {
    state = state.copyWith(status: ProfileStatus.loading, errorMessage: null);

    final result = await _repository.updateProfile({
      'emergencyContact': contact,
    });

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          emergencyContact: contact,
          errorMessage: null,
        );
      },
    );
  }
}
