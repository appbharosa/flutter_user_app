import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/online_doctor_coupon.dart';
import '../../../../domain/use_cases/get_online_doctor_coupons_usecase.dart';
part 'online_doctor_coupon_event.dart';
part 'online_doctor_coupon_state.dart';

class OnlineDoctorCouponBloc extends Bloc<OnlineDoctorCouponEvent, OnlineDoctorCouponState> {
  final GetOnlineDoctorCouponsUseCase getCouponsUseCase;
  OnlineDoctorCouponBloc({required this.getCouponsUseCase}) : super(OnlineDoctorCouponInitial()) {
    on<LoadOnlineDoctorCoupons>(_onLoad);
  }

  Future<void> _onLoad(LoadOnlineDoctorCoupons event, Emitter<OnlineDoctorCouponState> emit) async {
    emit(OnlineDoctorCouponLoading());
    final result = await getCouponsUseCase(event.lang);
    result.fold(
          (failure) => emit(OnlineDoctorCouponError(failure.message)),
          (coupons) => emit(OnlineDoctorCouponLoaded(coupons)),
    );
  }
}