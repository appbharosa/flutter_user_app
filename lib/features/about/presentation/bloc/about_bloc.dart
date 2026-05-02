import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/use_cases/get_about_usecase.dart';
import 'about_event.dart';
import 'about_state.dart';


class AboutBloc extends Bloc<AboutEvent, AboutState> {
  final GetAboutUseCase getAboutUseCase;

  AboutBloc({required this.getAboutUseCase}) : super(AboutInitial()) {
    on<FetchAbout>(_onFetchAbout);
  }

  Future<void> _onFetchAbout(FetchAbout event, Emitter<AboutState> emit) async {
    emit(AboutLoading());
    final result = await getAboutUseCase();
    result.fold(
          (failure) => emit(AboutError(failure.message)),
          (about) => emit(AboutLoaded(about)),
    );
  }
}