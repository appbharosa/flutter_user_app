
import 'package:equatable/equatable.dart';

abstract class FreeLabSlotsEvent extends Equatable {
  const FreeLabSlotsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFreeLabSlots extends FreeLabSlotsEvent {
  final String language;
  final int packageId;
  final String? date; // optional – format "YYYY-MM-DD"

  const LoadFreeLabSlots(this.language, this.packageId, {this.date});

  @override
  List<Object?> get props => [language, packageId, date];
}