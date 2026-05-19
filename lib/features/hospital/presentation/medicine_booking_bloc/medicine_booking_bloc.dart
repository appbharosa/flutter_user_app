import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/book_medicine_usecase.dart';
import 'medicine_booking_event.dart';
import 'medicine_booking_state.dart';


class MedicineBookingBloc extends Bloc<MedicineBookingEvent, MedicineBookingState> {
  final BookMedicineUseCase bookMedicineUseCase;
  MedicineBookingBloc({required this.bookMedicineUseCase}) : super(MedicineBookingInitial()) {
    on<SubmitMedicineBooking>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitMedicineBooking event, Emitter<MedicineBookingState> emit) async {
    emit(MedicineBookingLoading());
    final result = await bookMedicineUseCase(BookMedicineParams(
      mainDataId: event.mainDataId,
      orderType: event.orderType,
      addressId: event.addressId,
      imagePaths: event.imagePaths,
    ));
    result.fold(
          (failure) => emit(MedicineBookingError(failure.message)),
          (message) => emit(MedicineBookingSuccess(message)),
    );
  }
}