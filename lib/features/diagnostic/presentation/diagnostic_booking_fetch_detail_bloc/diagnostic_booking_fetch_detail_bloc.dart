import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/get_booking_fetch_detail_usecase.dart';
import 'diagnostic_booking_fetch_detail_event.dart';
import 'diagnostic_booking_fetch_detail_state.dart';


class DiagnosticBookingFetchDetailBloc extends Bloc<DiagnosticBookingFetchDetailEvent, DiagnosticBookingFetchDetailState> {
  final GetBookingFetchDetailUseCase getDetailUseCase;
  DiagnosticBookingFetchDetailBloc({required this.getDetailUseCase}) : super(DiagnosticBookingFetchDetailInitial()) {
    on<LoadFetchBookingDetail>(_onLoadBookingDetail);
  }

  Future<void> _onLoadBookingDetail(LoadFetchBookingDetail event, Emitter<DiagnosticBookingFetchDetailState> emit) async {
    emit(DiagnosticBookingFetchDetailLoading());
    final result = await getDetailUseCase(event.bookingId);
    result.fold(
          (failure) => emit(DiagnosticBookingFetchDetailError(failure.message)),
          (detail) => emit(DiagnosticBookingFetchDetailLoaded(detail)),
    );
  }
}