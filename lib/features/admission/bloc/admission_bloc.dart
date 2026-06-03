import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/submit_admission.dart';
import 'admission_event.dart';
import 'admission_state.dart';

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  final SubmitAdmission submitAdmission;

  AdmissionBloc({required this.submitAdmission}) : super(AdmissionInitial()) {
    on<SubmitAdmissionEvent>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitAdmissionEvent event, Emitter<AdmissionState> emit) async {
    emit(AdmissionLoading());
    try {
      await submitAdmission(event.request);
      emit(AdmissionSuccess());
    } catch (e) {
      emit(AdmissionError(e.toString()));
    }
  }
}