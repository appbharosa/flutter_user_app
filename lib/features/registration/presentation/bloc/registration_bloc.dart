import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/registration/presentation/bloc/registration_event.dart';
import 'package:user/features/registration/presentation/bloc/registration_state.dart';

import '../../../../domain/use_cases/register_user_usecase.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegisterUserUseCase registerUserUseCase;

  RegistrationBloc({required this.registerUserUseCase}) : super(RegistrationInitial()) {
    on<SubmitRegistration>(_onSubmitRegistration);
  }

  Future<void> _onSubmitRegistration(SubmitRegistration event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    final result = await registerUserUseCase(RegisterUserParams(event.userData));
    result.fold(
          (failure) => emit(RegistrationError(failure.message)),
          (registration) => emit(RegistrationSuccess(registration)),
    );
  }
}