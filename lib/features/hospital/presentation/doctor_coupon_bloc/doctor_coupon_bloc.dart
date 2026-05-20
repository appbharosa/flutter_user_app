import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/applied_coupon.dart';
import '../../../../domain/entities/doctor_coupon.dart';
import '../../../../domain/use_cases/apply_doctor_coupon.dart';
import '../../../../domain/use_cases/get_doctor_coupons.dart';
part 'doctor_coupon_event.dart';
part 'doctor_coupon_state.dart';

class DoctorCouponBloc extends Bloc<DoctorCouponEvent, DoctorCouponState> {
  final GetDoctorCouponsUseCase getCouponsUseCase;
  final ApplyDoctorCouponUseCase applyCouponUseCase;

  DoctorCouponBloc({
    required this.getCouponsUseCase,
    required this.applyCouponUseCase,
  }) : super(DoctorCouponInitial()) {
    on<LoadDoctorCoupons>(_onLoadCoupons);
    on<ApplyDoctorCoupon>(_onApplyCoupon);
    on<ResetAppliedCoupon>(_onResetApplied);
  }

  Future<void> _onLoadCoupons(LoadDoctorCoupons event, Emitter<DoctorCouponState> emit) async {
    emit(DoctorCouponLoading());
    final result = await getCouponsUseCase(event.language);
    result.fold(
          (failure) => emit(DoctorCouponError(_mapFailureToMessage(failure))),
          (coupons) => emit(DoctorCouponLoaded(coupons)),
    );
  }

  Future<void> _onApplyCoupon(ApplyDoctorCoupon event, Emitter<DoctorCouponState> emit) async {
    emit(DoctorCouponApplying());
    final result = await applyCouponUseCase(
      couponCode: event.couponCode,
      subtotal: event.subtotal,
      language: event.language,
    );
    result.fold(
          (failure) => emit(DoctorCouponApplyError(_mapFailureToMessage(failure))),
          (applied) => emit(DoctorCouponApplied(applied)),
    );
  }

  void _onResetApplied(ResetAppliedCoupon event, Emitter<DoctorCouponState> emit) {
    // Keep the loaded coupons if any, or go to initial
    if (state is DoctorCouponLoaded) {
      final coupons = (state as DoctorCouponLoaded).coupons;
      emit(DoctorCouponLoaded(coupons));
    } else {
      emit(DoctorCouponInitial());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}