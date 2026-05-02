import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/profile/presentation/bloc/profile_event.dart';
import 'package:user/features/profile/presentation/bloc/profile_state.dart';

import '../../../../domain/use_cases/get_profile_usecase.dart';
import '../../../../domain/use_cases/update_profile_usecase.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(FetchProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
          (failure) => emit(ProfileError(failure.message)),
          (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await updateProfileUseCase(event.updatedData);
    result.fold(
          (failure) => emit(ProfileError(failure.message)),
          (updatedProfile) => emit(ProfileLoaded(updatedProfile)),
    );
  }
}