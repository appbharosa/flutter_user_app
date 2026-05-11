import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/domain/use_cases/get_completed_fetch_bookings_usecase.dart';

import '../../../../domain/entities/diagnostic_booking_fetch_item.dart';
import '../../../../domain/use_cases/get_booking_fetch_detail_usecase.dart';
import '../../../../domain/use_cases/get_ongoing_fetch_bookings_usecase.dart';
import 'diagnostic_booking_fetch_list_event.dart';
import 'diagnostic_booking_fetch_list_state.dart';




class DiagnosticBookingFetchListBloc extends Bloc<DiagnosticBookingFetchListEvent, DiagnosticBookingFetchListState> {
  final GetOngoingFetchBookingsUseCase getOngoingUseCase;
  final GetCompletedFetchBookingsUseCase getCompletedUseCase;

  List<DiagnosticBookingFetchItem> _ongoing = [];
  List<DiagnosticBookingFetchItem> _completed = [];
  int _currentOngoingPage = 1;
  int _currentCompletedPage = 1;
  bool _hasMoreOngoing = true;
  bool _hasMoreCompleted = true;
  static const int _perPage = 10;
  int _selectedTab = 0;

  DiagnosticBookingFetchListBloc({
    required this.getOngoingUseCase,
    required this.getCompletedUseCase,
  }) : super(DiagnosticBookingFetchListInitial()) {
    on<LoadOngoingFetchBookings>(_onLoadOngoing);
    on<LoadCompletedFetchBookings>(_onLoadCompleted);
    on<LoadMoreOngoingFetchBookings>(_onLoadMoreOngoing);
    on<LoadMoreCompletedFetchBookings>(_onLoadMoreCompleted);
    on<SelectFetchBookingTab>(_onSelectTab);
  }

  Future<void> _onLoadOngoing(LoadOngoingFetchBookings event, Emitter<DiagnosticBookingFetchListState> emit) async {
    if (state is DiagnosticBookingFetchListLoading) return;
    emit(DiagnosticBookingFetchListLoading());
    _ongoing = [];
    _currentOngoingPage = 1;
    _hasMoreOngoing = true;
    await _fetchOngoing(emit);
  }

  Future<void> _onLoadCompleted(LoadCompletedFetchBookings event, Emitter<DiagnosticBookingFetchListState> emit) async {
    if (state is DiagnosticBookingFetchListLoading) return;
    emit(DiagnosticBookingFetchListLoading());
    _completed = [];
    _currentCompletedPage = 1;
    _hasMoreCompleted = true;
    await _fetchCompleted(emit);
  }

  Future<void> _onLoadMoreOngoing(LoadMoreOngoingFetchBookings event, Emitter<DiagnosticBookingFetchListState> emit) async {
    if (!_hasMoreOngoing || state is DiagnosticBookingFetchListLoading) return;
    await _fetchOngoing(emit);
  }

  Future<void> _onLoadMoreCompleted(LoadMoreCompletedFetchBookings event, Emitter<DiagnosticBookingFetchListState> emit) async {
    if (!_hasMoreCompleted || state is DiagnosticBookingFetchListLoading) return;
    await _fetchCompleted(emit);
  }

  Future<void> _fetchOngoing(Emitter<DiagnosticBookingFetchListState> emit) async {
    final result = await getOngoingUseCase(GetOngoingFetchBookingsParams(page: _currentOngoingPage, perPage: _perPage));
    result.fold(
          (failure) => emit(DiagnosticBookingFetchListError(failure.message)),
          (newList) {
        if (newList.isEmpty) _hasMoreOngoing = false;
        else {
          _ongoing.addAll(newList);
          _currentOngoingPage++;
          _hasMoreOngoing = newList.length == _perPage;
        }
        _emitLoaded(emit);
      },
    );
  }

  Future<void> _fetchCompleted(Emitter<DiagnosticBookingFetchListState> emit) async {
    final result = await getCompletedUseCase(GetCompletedFetchBookingsParams(page: _currentCompletedPage, perPage: _perPage));
    result.fold(
          (failure) => emit(DiagnosticBookingFetchListError(failure.message)),
          (newList) {
        if (newList.isEmpty) _hasMoreCompleted = false;
        else {
          _completed.addAll(newList);
          _currentCompletedPage++;
          _hasMoreCompleted = newList.length == _perPage;
        }
        _emitLoaded(emit);
      },
    );
  }

  void _emitLoaded(Emitter<DiagnosticBookingFetchListState> emit) {
    emit(DiagnosticBookingFetchListLoaded(
      ongoingList: List.from(_ongoing),
      completedList: List.from(_completed),
      selectedTab: _selectedTab,
      hasMoreOngoing: _hasMoreOngoing,
      hasMoreCompleted: _hasMoreCompleted,
    ));
  }

  void _onSelectTab(SelectFetchBookingTab event, Emitter<DiagnosticBookingFetchListState> emit) {
    _selectedTab = event.index;
    if (state is DiagnosticBookingFetchListLoaded) {
      final currentState = state as DiagnosticBookingFetchListLoaded;
      emit(DiagnosticBookingFetchListLoaded(
        ongoingList: currentState.ongoingList,
        completedList: currentState.completedList,
        selectedTab: _selectedTab,
        hasMoreOngoing: _hasMoreOngoing,
        hasMoreCompleted: _hasMoreCompleted,
      ));
    }
  }
}