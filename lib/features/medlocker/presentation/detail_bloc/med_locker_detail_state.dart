

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/med_locker.dart';

abstract class MedLockerDetailState extends Equatable {
  const MedLockerDetailState();
  @override List<Object> get props => [];
}

class MedLockerDetailInitial extends MedLockerDetailState {}
class MedLockerDetailLoading extends MedLockerDetailState {}
class MedLockerDetailLoaded extends MedLockerDetailState {
  final MedLocker locker;
  const MedLockerDetailLoaded(this.locker);
  @override List<Object> get props => [locker];
}
class MedLockerDetailError extends MedLockerDetailState {
  final String message;
  const MedLockerDetailError(this.message);
}