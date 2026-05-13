import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/get_lab_test_booking_detail_usecase.dart';
import 'lab_test_booking_fetch_detail_event.dart';
import 'lab_test_booking_fetch_detail_state.dart';


class LabTestBookingFetchDetailBloc extends Bloc<LabTestBookingFetchDetailEvent, LabTestBookingFetchDetailState> {
  final GetLabTestBookingDetailUseCase getDetailUseCase;
  LabTestBookingFetchDetailBloc({required this.getDetailUseCase}) : super(LabTestBookingFetchDetailInitial()) {
    on<LoadLabTestBookingDetail>(_onLoadBookingDetail);
  }

  Future<void> _onLoadBookingDetail(LoadLabTestBookingDetail event, Emitter<LabTestBookingFetchDetailState> emit) async {
    emit(LabTestBookingFetchDetailLoading());
    final result = await getDetailUseCase(event.bookingId);
    result.fold(
          (failure) => emit(LabTestBookingFetchDetailError(failure.message)),
          (detail) => emit(LabTestBookingFetchDetailLoaded(detail)),
    );
  }
}