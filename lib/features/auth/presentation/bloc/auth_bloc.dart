import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/auth/presentation/bloc/auth_event.dart';
import 'package:user/features/auth/presentation/bloc/auth_state.dart';

import '../../../../domain/use_cases/login_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;

  AuthBloc({required this.sendOtpUseCase}) : super(OtpInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
  }

  Future<void> _onSendOtpRequested(
      SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(OtpLoading());
    final result = await sendOtpUseCase(event.phoneNumber);
    result.fold(
          (failure) => emit(OtpError(failure.message)),
          (otpResponse) => emit(OtpSent(
        userId: otpResponse.userId,
        otp: otpResponse.otp,
      )),
    );
  }
}