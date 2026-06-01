
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/user_subscription.dart';

abstract class SubscriptionStatusState extends Equatable {
  const SubscriptionStatusState();
  @override
  List<Object?> get props => [];
}

class SubscriptionStatusInitial extends SubscriptionStatusState {}

class SubscriptionStatusLoading extends SubscriptionStatusState {}

class SubscriptionStatusLoaded extends SubscriptionStatusState {
  final UserSubscription? subscription;
  const SubscriptionStatusLoaded(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionStatusError extends SubscriptionStatusState {
  final String message;
  const SubscriptionStatusError(this.message);
  @override
  List<Object?> get props => [message];
}