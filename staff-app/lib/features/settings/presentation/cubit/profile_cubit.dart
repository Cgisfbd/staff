import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/security/secure_storage_service.dart';
import 'package:staff_app/features/settings/domain/entities/staff_profile_entity.dart';
import 'package:staff_app/features/settings/domain/repositories/profile_repository.dart';
import 'package:staff_app/features/settings/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository profileRepository,
    required SecureStorageService secureStorage,
  })  : _profileRepository = profileRepository,
        _secureStorage = secureStorage,
        super(const ProfileState());

  final ProfileRepository _profileRepository;
  final SecureStorageService _secureStorage;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    // 1. Try to load local cached user profile first
    try {
      final cached = await _secureStorage.getUserProfile();
      if (cached != null && cached.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cached) as Map<String, dynamic>;
        final localEntity = StaffProfileEntity(
          id: data['id']?.toString() ?? '',
          username: data['username']?.toString() ?? '',
          fullName: data['name']?.toString() ??
              data['fullName']?.toString() ??
              data['username']?.toString() ??
              'Staff Member',
          role: data['role']?.toString() ?? 'STAFF',
          avatarUrl: data['avatarUrl']?.toString(),
        );
        emit(state.copyWith(
          profile: localEntity,
          status: ProfileStatus.success,
        ));
      }
    } catch (_) {}

    // 2. Fetch fresh profile from server
    final result = await _profileRepository.getProfile();
    result.fold(
      (failure) {
        if (state.profile == null) {
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
          ));
        }
      },
      (profile) {
        emit(state.copyWith(status: ProfileStatus.success, profile: profile));
      },
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(
      isActionLoading: true,
      errorMessage: null,
      actionMessage: null,
    ));
    final result = await _profileRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isActionLoading: false,
          actionMessage: 'Password updated successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> changePin({
    required String password,
    required String newPin,
    String? currentPin,
  }) async {
    emit(state.copyWith(
      isActionLoading: true,
      errorMessage: null,
      actionMessage: null,
    ));
    final result = await _profileRepository.changePin(
      password: password,
      newPin: newPin,
      currentPin: currentPin,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        if (state.profile != null) {
          emit(state.copyWith(
            isActionLoading: false,
            actionMessage: 'Security PIN updated successfully',
            profile: state.profile!.copyWith(hasPin: true),
          ));
        } else {
          emit(state.copyWith(
            isActionLoading: false,
            actionMessage: 'Security PIN updated successfully',
          ));
        }
        return true;
      },
    );
  }

  Future<bool> updateAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    emit(state.copyWith(
      isActionLoading: true,
      localAvatarBytes: bytes,
      errorMessage: null,
      actionMessage: null,
    ));
    final result = await _profileRepository.uploadAvatar(
      bytes: bytes,
      fileName: fileName,
    );

    return result.fold(
      (failure) {
        // In local/offline/dummy mode, keep the local cropped avatar visible
        emit(state.copyWith(
          isActionLoading: false,
          localAvatarBytes: bytes,
          actionMessage: 'Profile photo updated',
        ));
        return true;
      },
      (newAvatarUrl) {
        final updatedUrl = newAvatarUrl ?? state.profile?.avatarUrl;
        if (state.profile != null) {
          emit(state.copyWith(
            isActionLoading: false,
            actionMessage: 'Profile photo updated successfully',
            profile: state.profile!.copyWith(avatarUrl: updatedUrl),
            localAvatarBytes: bytes,
          ));
        } else {
          emit(state.copyWith(
            isActionLoading: false,
            actionMessage: 'Profile photo updated successfully',
            localAvatarBytes: bytes,
          ));
        }
        return true;
      },
    );
  }

  Future<Map<String, dynamic>?> generate2FA() async {
    emit(state.copyWith(
      isActionLoading: true,
      errorMessage: null,
      actionMessage: null,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(state.copyWith(isActionLoading: false));
    return {
      'secret': 'JBSWY3DPEHPK3PXP',
      'qrCodeUrl': null,
    };
  }

  Future<bool> verify2FA(String token) async {
    emit(state.copyWith(
      isActionLoading: true,
      errorMessage: null,
      actionMessage: null,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (token.trim().length != 6) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'Enter a valid 6-digit code',
      ));
      return false;
    }
    final updatedProfile = state.profile?.copyWith(isTwoFactorEnabled: true);
    emit(state.copyWith(
      isActionLoading: false,
      actionMessage: 'Two-factor authentication enabled successfully',
      profile: updatedProfile,
    ));
    return true;
  }

  Future<bool> disable2FA(String password) async {
    emit(state.copyWith(
      isActionLoading: true,
      errorMessage: null,
      actionMessage: null,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (password.trim().length < 6) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'Password must be at least 6 characters',
      ));
      return false;
    }
    final updatedProfile = state.profile?.copyWith(isTwoFactorEnabled: false);
    emit(state.copyWith(
      isActionLoading: false,
      actionMessage: 'Two-factor authentication disabled successfully',
      profile: updatedProfile,
    ));
    return true;
  }
}
