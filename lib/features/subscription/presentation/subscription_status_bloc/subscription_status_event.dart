
import 'package:equatable/equatable.dart';

abstract class SubscriptionStatusEvent extends Equatable {
  const SubscriptionStatusEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserSubscription extends SubscriptionStatusEvent {
  final String language;
  const LoadUserSubscription(this.language);
  @override
  List<Object?> get props => [language];
}