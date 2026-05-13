import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/labtest/presentation/lab_test_booking_bloc/lab_test_booking_event.dart';

import '../../../../domain/use_cases/create_lab_test_order_usecase.dart';
import 'lab_test_booking_event.dart';
import 'lab_test_booking_state.dart';

class LabTestBookingBloc extends Bloc<LabTestBookingEvent, LabTestBookingState> {
  final CreateLabTestOrderUseCase createOrderUseCase;
  LabTestBookingBloc({required this.createOrderUseCase}) : super(LabTestBookingInitial()) {
    on<BookLabTest>(_onBookLabTest);
  }

  Future<void> _onBookLabTest(BookLabTest event, Emitter<LabTestBookingState> emit) async {
    emit(LabTestBookingLoading());
    final result = await createOrderUseCase(CreateLabTestOrderParams(
      labTestId: event.labTestId,
      prescriptionPaths: event.prescriptionPaths,
      lang: event.lang,
      familyMemberId: event.familyMemberId,
      // slotId: event.slotId,
      // packageId: event.packageId,
      // personsCount: event.personsCount,
    ));
    result.fold(
          (failure) => emit(LabTestBookingError(failure.message)),
          (response) => emit(LabTestBookingSuccess(response.bookingId)),
    );
  }
}