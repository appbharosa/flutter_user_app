import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:user/features/subscription/presentation/bloc/subscription_state.dart';

import '../../../../domain/use_cases/get_subscription_plans_usecase.dart';


class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;

  SubscriptionBloc({required this.getSubscriptionPlansUseCase}) : super(SubscriptionInitial()) {
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
  }

  Future<void> _onLoadSubscriptionPlans(LoadSubscriptionPlans event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    final result = await getSubscriptionPlansUseCase();
    result.fold(
          (failure) => emit(SubscriptionError(failure.message)),
          (plans) => emit(SubscriptionLoaded(plans)),
    );
  }
}