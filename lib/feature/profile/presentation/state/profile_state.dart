import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? profileImageUrl;
  final String? bloodGroup;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileImageUrl,
    this.bloodGroup,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? profileImageUrl,
    String? bloodGroup,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profileImageUrl, bloodGroup, errorMessage];
}
