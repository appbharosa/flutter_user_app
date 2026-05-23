

import '../../../../domain/entities/med_locker_add_response.dart';
import '../../../../domain/entities/med_locker_detail.dart';
import '../../../../domain/entities/med_locker_list_item.dart';

abstract class MedLockerState {}

class MedLockerInitial extends MedLockerState {}

// List states
class MedLockerLoading extends MedLockerState {}
class MedLockerListLoaded extends MedLockerState {
  final List<MedLockerListItem> lockers;
  MedLockerListLoaded(this.lockers);
}

// Detail states
class MedLockerDetailLoading extends MedLockerState {}
class MedLockerDetailLoaded extends MedLockerState {
  final MedLockerDetail detail;
  MedLockerDetailLoaded(this.detail);
}

// Add states
class MedLockerAdding extends MedLockerState {}
class MedLockerAddSuccess extends MedLockerState {
  final MedLockerAddResponse response;
  MedLockerAddSuccess(this.response);
}

// Error
class MedLockerError extends MedLockerState {
  final String message;
  MedLockerError(this.message);
}