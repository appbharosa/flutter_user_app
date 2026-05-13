import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/use_cases/apply_lab_coupon_usecase.dart';
import 'apply_lab_coupon_event.dart';
import 'apply_lab_coupon_state.dart';



class ApplyLabCouponBloc extends Bloc<ApplyLabCouponEvent, ApplyLabCouponState> {
  final ApplyLabCouponUseCase applyCouponUseCase;
  ApplyLabCouponBloc({required this.applyCouponUseCase}) : super(ApplyCouponInitial()) {
    on<ApplyCoupon>(_onApplyCoupon);
  }

  Future<void> _onApplyCoupon(ApplyCoupon event, Emitter<ApplyLabCouponState> emit) async {
    emit(ApplyCouponLoading());
    final result = await applyCouponUseCase(ApplyLabCouponParams(
      couponCode: event.couponCode,
      amount: event.amount,
    ));
    result.fold(
          (failure) => emit(ApplyCouponError(failure.message)),
          (data) => emit(ApplyCouponSuccess(
        couponCode: event.couponCode,
        discountAmount: data['discountAmount'],
        finalAmount: data['finalAmount'],
      )),
    );
  }
}