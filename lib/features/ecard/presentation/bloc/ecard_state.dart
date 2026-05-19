
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/ecard.dart';

abstract class ECardState extends Equatable {
  const ECardState();
  @override
  List<Object?> get props => [];
}

class ECardInitial extends ECardState {}

class ECardLoading extends ECardState {}

class ECardLoaded extends ECardState {
  final ECard ecard;
  const ECardLoaded(this.ecard);
  @override
  List<Object?> get props => [ecard];
}

class ECardError extends ECardState {
  final String message;
  const ECardError(this.message);
  @override
  List<Object?> get props => [message];
}