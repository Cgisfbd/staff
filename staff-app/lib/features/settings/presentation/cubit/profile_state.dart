import 'package:equatable/equatable.dart';
import 'package:staff_app/features/settings/domain/entities/staff_profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.localAvatarBytes,
    this.errorMessage,
    this.actionMessage,
    this.isActionLoading = false,
  });

  final ProfileStatus status;
  final StaffProfileEntity? profile;
  final List<int>? localAvatarBytes;
  final String? errorMessage;
  final String? actionMessage;
  final bool isActionLoading;

  ProfileState copyWith({
    ProfileStatus? status,
    StaffProfileEntity? profile,
    List<int>? localAvatarBytes,
    String? errorMessage,
    String? actionMessage,
    bool? isActionLoading,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      localAvatarBytes: localAvatarBytes ?? this.localAvatarBytes,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [status, profile, localAvatarBytes, errorMessage, actionMessage, isActionLoading];
}
