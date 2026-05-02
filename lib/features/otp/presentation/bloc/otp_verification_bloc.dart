import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/verify_otp_usecase.dart';
import 'otp_verification_event.dart';
import 'otp_verification_state.dart';


class OtpVerificationBloc extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  final VerifyOtpUseCase verifyOtpUseCase;

  OtpVerificationBloc({required this.verifyOtpUseCase}) : super(OtpVerificationInitial()) {
    on<VerifyOtpButtonPressed>(_onVerifyOtpButtonPressed);
  }

  Future<void> _onVerifyOtpButtonPressed(
      VerifyOtpButtonPressed event, Emitter<OtpVerificationState> emit) async {
    emit(OtpVerificationLoading());
    final result = await verifyOtpUseCase(VerifyOtpParams(userId: event.userId, otp: event.otp));
    result.fold(
          (failure) => emit(OtpVerificationError(failure.message)),
          (userProfile) => emit(OtpVerificationSuccess(userProfile)),
    );
  }
}