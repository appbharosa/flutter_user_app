import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/use_cases/get_lab_coupons_usecase.dart';
import 'lab_coupon_list_event.dart';
import 'lab_coupon_list_state.dart';

class LabCouponListBloc extends Bloc<LabCouponListEvent, LabCouponListState> {
  final GetLabCouponsUseCase getCouponsUseCase;
  LabCouponListBloc({required this.getCouponsUseCase}) : super(LabCouponListInitial()) {
    on<LoadLabCoupons>(_onLoadCoupons);
  }

  Future<void> _onLoadCoupons(LoadLabCoupons event, Emitter<LabCouponListState> emit) async {
    emit(LabCouponListLoading());
    final result = await getCouponsUseCase();
    result.fold(
          (failure) => emit(LabCouponListError(failure.message)),
          (coupons) => emit(LabCouponListLoaded(coupons)),
    );
  }
}