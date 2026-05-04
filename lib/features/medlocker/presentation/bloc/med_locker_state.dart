
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/med_locker.dart';

abstract class MedLockerState extends Equatable {
  const MedLockerState();
  @override List<Object> get props => [];
}

class MedLockerInitial extends MedLockerState {}
class MedLockerLoading extends MedLockerState {}
class MedLockerLoaded extends MedLockerState {
  final List<MedLocker> lockers;
  const MedLockerLoaded(this.lockers);
  @override List<Object> get props => [lockers];
}
class MedLockerError extends MedLockerState {
  final String message;
  const MedLockerError(this.message);
}