
import 'package:equatable/equatable.dart';

abstract class FreeLabSlotsEvent extends Equatable {
  const FreeLabSlotsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFreeLabSlots extends FreeLabSlotsEvent {
  final String language;
  final int packageId;
  const LoadFreeLabSlots(this.language, this.packageId);
  @override
  List<Object?> get props => [language, packageId];
}