import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/submit_contact_us_usecase.dart';
import 'contact_us_event.dart';
import 'contact_us_state.dart';

class ContactUsBloc extends Bloc<ContactUsEvent, ContactUsState> {
  final SubmitContactUsUseCase submitContactUsUseCase;

  ContactUsBloc({required this.submitContactUsUseCase}) : super(ContactUsInitial()) {
    on<SubmitContactUs>(_onSubmitContactUs);
  }

  Future<void> _onSubmitContactUs(SubmitContactUs event, Emitter<ContactUsState> emit) async {
    emit(ContactUsLoading());
    final params = SubmitContactUsParams(
      userId: event.userId,
      name: event.name,
      email: event.email,
      mobile: event.mobile,
      message: event.message,
    );
    final result = await submitContactUsUseCase(params);
    result.fold(
          (failure) => emit(ContactUsError(failure.message)),
          (response) => emit(ContactUsSuccess(response.message)),
    );
  }
}