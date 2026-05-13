import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/lab_test_booking_fetch_item.dart';
import '../../../../domain/use_cases/get_completed_lab_test_bookings_usecase.dart';
import '../../../../domain/use_cases/get_ongoing_lab_test_bookings_usecase.dart';
import 'lab_test_booking_fetch_list_event.dart';
import 'lab_test_booking_fetch_list_state.dart';

class LabTestBookingFetchListBloc extends Bloc<LabTestBookingFetchListEvent, LabTestBookingFetchListState> {
  final GetOngoingLabTestBookingsUseCase getOngoingUseCase;
  final GetCompletedLabTestBookingsUseCase getCompletedUseCase;

  List<LabTestBookingFetchItem> _ongoing = [];
  List<LabTestBookingFetchItem> _completed = [];
  int _currentOngoingPage = 1;
  int _currentCompletedPage = 1;
  bool _hasMoreOngoing = true;
  bool _hasMoreCompleted = true;
  bool _isLoadingMoreOngoing = false;
  bool _isLoadingMoreCompleted = false;
  static const int _perPage = 10;
  int _selectedTab = 0;

  LabTestBookingFetchListBloc({
    required this.getOngoingUseCase,
    required this.getCompletedUseCase,
  }) : super(LabTestBookingFetchListInitial()) {
    on<LoadOngoingLabTestBookings>(_onLoadOngoing);
    on<LoadCompletedLabTestBookings>(_onLoadCompleted);
    on<LoadMoreOngoingLabTestBookings>(_onLoadMoreOngoing);
    on<LoadMoreCompletedLabTestBookings>(_onLoadMoreCompleted);
    on<SelectLabTestBookingTab>(_onSelectTab);
  }

  Future<void> _onLoadOngoing(LoadOngoingLabTestBookings event, Emitter<LabTestBookingFetchListState> emit) async {
    _ongoing = [];
    _currentOngoingPage = 1;
    _hasMoreOngoing = true;
    await _fetchOngoing(emit);
  }

  Future<void> _onLoadCompleted(LoadCompletedLabTestBookings event, Emitter<LabTestBookingFetchListState> emit) async {
    print("🚀 _onLoadCompleted triggered");
    _completed = [];
    _currentCompletedPage = 1;
    _hasMoreCompleted = true;
    await _fetchCompleted(emit);
  }

  Future<void> _onLoadMoreOngoing(LoadMoreOngoingLabTestBookings event, Emitter<LabTestBookingFetchListState> emit) async {
    if (!_hasMoreOngoing || _isLoadingMoreOngoing) return;
    _isLoadingMoreOngoing = true;
    await _fetchOngoing(emit);
    _isLoadingMoreOngoing = false;
  }

  Future<void> _onLoadMoreCompleted(LoadMoreCompletedLabTestBookings event, Emitter<LabTestBookingFetchListState> emit) async {
    if (!_hasMoreCompleted || _isLoadingMoreCompleted) return;
    _isLoadingMoreCompleted = true;
    await _fetchCompleted(emit);
    _isLoadingMoreCompleted = false;
  }

  Future<void> _fetchOngoing(Emitter<LabTestBookingFetchListState> emit) async {
    final result = await getOngoingUseCase(GetOngoingLabTestBookingsParams(page: _currentOngoingPage, perPage: _perPage));
    result.fold(
          (failure) => emit(LabTestBookingFetchListError(failure.message)),
          (newList) {
        if (newList.isEmpty) {
          _hasMoreOngoing = false;
        } else {
          _ongoing.addAll(newList);
          _currentOngoingPage++;
          _hasMoreOngoing = newList.length == _perPage;
        }
        _emitLoaded(emit);
      },
    );
  }


  Future<void> _fetchCompleted(Emitter<LabTestBookingFetchListState> emit) async {
    print("📞 _fetchCompleted called, page=$_currentCompletedPage, perPage=$_perPage");
    final result = await getCompletedUseCase(GetCompletedLabTestBookingsParams(page: _currentCompletedPage, perPage: _perPage));
    result.fold(
          (failure) {
        print("❌ _fetchCompleted error: ${failure.message}");
        emit(LabTestBookingFetchListError(failure.message));
      },
          (newList) {
        print("✅ _fetchCompleted success, received ${newList.length} items");
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

  void _emitLoaded(Emitter<LabTestBookingFetchListState> emit) {
    emit(LabTestBookingFetchListLoaded(
      ongoingList: List.from(_ongoing),
      completedList: List.from(_completed),
      selectedTab: _selectedTab,
      hasMoreOngoing: _hasMoreOngoing,
      hasMoreCompleted: _hasMoreCompleted,
    ));
  }

  void _onSelectTab(SelectLabTestBookingTab event, Emitter<LabTestBookingFetchListState> emit) {
    _selectedTab = event.index;
    if (state is LabTestBookingFetchListLoaded) {
      final currentState = state as LabTestBookingFetchListLoaded;
      emit(currentState.copyWith(selectedTab: _selectedTab));
    } else {
      _emitLoaded(emit);
    }
  }
}