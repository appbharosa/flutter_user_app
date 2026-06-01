import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/free_lab_slot.dart';

abstract class FreeLabSlotsState extends Equatable {
  const FreeLabSlotsState();
  @override
  List<Object?> get props => [];
}

class FreeLabSlotsInitial extends FreeLabSlotsState {}

class FreeLabSlotsLoading extends FreeLabSlotsState {}

class FreeLabSlotsLoaded extends FreeLabSlotsState {
  final FreeLabSlotResponse slots;
  const FreeLabSlotsLoaded(this.slots);
  @override
  List<Object?> get props => [slots];
}

class FreeLabSlotsError extends FreeLabSlotsState {
  final String message;
  const FreeLabSlotsError(this.message);
  @override
  List<Object?> get props => [message];
}