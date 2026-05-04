import 'package:equatable/equatable.dart';
import '../../../../domain/entities/med_locker.dart';

abstract class AddMedLockerState extends Equatable {
  const AddMedLockerState();
  @override List<Object> get props => [];
}

class AddMedLockerInitial extends AddMedLockerState {}
class AddMedLockerLoading extends AddMedLockerState {}
class AddMedLockerSuccess extends AddMedLockerState {
  final MedLocker locker;
  const AddMedLockerSuccess(this.locker);
}
class AddMedLockerError extends AddMedLockerState {
  final String message;
  const AddMedLockerError(this.message);
}