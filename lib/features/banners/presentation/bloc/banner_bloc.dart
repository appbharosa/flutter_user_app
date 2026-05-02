import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/banner.dart';
import '../../../../domain/use_cases/get_banners_usecase.dart';
import 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final GetBannersUseCase getBannersUseCase;

  BannerBloc({required this.getBannersUseCase}) : super(BannerInitial()) {
    on<FetchBanners>(_onFetchBanners);
  }

  Future<void> _onFetchBanners(FetchBanners event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    final result = await getBannersUseCase();
    result.fold(
          (failure) => emit(BannerError(failure.message)),
          (banners) => emit(BannerLoaded(banners)),
    );
  }
}