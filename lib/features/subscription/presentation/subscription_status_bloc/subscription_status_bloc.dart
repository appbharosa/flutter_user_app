import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/subscription/presentation/subscription_status_bloc/subscription_status_event.dart';
import 'package:user/features/subscription/presentation/subscription_status_bloc/subscription_status_state.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/use_cases/get_user_subscription.dart';


class SubscriptionStatusBloc extends Bloc<SubscriptionStatusEvent, SubscriptionStatusState> {
  final GetUserSubscriptionUseCase getUserSubscriptionUseCase;

  SubscriptionStatusBloc({required this.getUserSubscriptionUseCase})
      : super(SubscriptionStatusInitial()) {
    on<LoadUserSubscription>(_onLoadUserSubscription);
  }

  Future<void> _onLoadUserSubscription(LoadUserSubscription event, Emitter<SubscriptionStatusState> emit) async {
    emit(SubscriptionStatusLoading());
    final result = await getUserSubscriptionUseCase(event.language);
    result.fold(
          (failure) => emit(SubscriptionStatusError(_mapFailureToMessage(failure))),
          (subscription) => emit(SubscriptionStatusLoaded(subscription)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}