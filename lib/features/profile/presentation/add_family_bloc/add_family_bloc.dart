
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/add_family_member_request.dart';
import '../../../../domain/use_cases/add_family_member.dart';
import 'add_family_state.dart';
part 'add_family_event.dart';


class AddFamilyBloc extends Bloc<AddFamilyEvent, AddFamilyState> {
  final AddFamilyMemberUseCase addFamilyMemberUseCase;

  AddFamilyBloc({required this.addFamilyMemberUseCase}) : super(AddFamilyInitial()) {
    on<SubmitAddFamily>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitAddFamily event, Emitter<AddFamilyState> emit) async {
    emit(AddFamilyLoading());
    final result = await addFamilyMemberUseCase(event.request);
    result.fold(
          (failure) => emit(AddFamilyError(_mapFailureToMessage(failure))),
          (response) => emit(AddFamilySuccess(response.message)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}