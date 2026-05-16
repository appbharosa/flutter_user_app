import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/apply_online_doctor_coupon_usecase.dart';
part 'online_doctor_apply_coupon_event.dart';
part 'online_doctor_apply_coupon_state.dart';

class OnlineDoctorApplyCouponBloc extends Bloc<OnlineDoctorApplyCouponEvent, OnlineDoctorApplyCouponState> {
  final ApplyOnlineDoctorCouponUseCase applyCouponUseCase;
  OnlineDoctorApplyCouponBloc({required this.applyCouponUseCase}) : super(OnlineDoctorApplyCouponInitial()) {
    on<ApplyOnlineDoctorCoupon>(_onApply);
  }

  Future<void> _onApply(ApplyOnlineDoctorCoupon event, Emitter<OnlineDoctorApplyCouponState> emit) async {
    emit(OnlineDoctorApplyCouponLoading());
    final result = await applyCouponUseCase(ApplyOnlineDoctorCouponParams(event.couponCode, event.amount));
    result.fold(
          (failure) => emit(OnlineDoctorApplyCouponError(failure.message)),
          (data) => emit(OnlineDoctorApplyCouponSuccess(
        couponCode: data['couponCode'],
        discountAmount: data['discountAmount'],
        finalAmount: data['finalAmount'],
      )),
    );
  }
}