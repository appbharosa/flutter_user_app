import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/use_cases/get_family_members_usecase.dart';
import 'family_members_event.dart';
import 'family_members_state.dart';


class FamilyMembersBloc extends Bloc<FamilyMembersEvent, FamilyMembersState> {
  final GetFamilyMembersUseCase getFamilyMembersUseCase;
  FamilyMembersBloc({required this.getFamilyMembersUseCase}) : super(FamilyMembersInitial()) {
    on<LoadFamilyMembers>(_onLoadFamilyMembers);
  }

  Future<void> _onLoadFamilyMembers(LoadFamilyMembers event, Emitter<FamilyMembersState> emit) async {
    emit(FamilyMembersLoading());
    final result = await getFamilyMembersUseCase();
    result.fold(
          (failure) => emit(FamilyMembersError(failure.message)),
          (members) => emit(FamilyMembersLoaded(members)),
    );
  }
}