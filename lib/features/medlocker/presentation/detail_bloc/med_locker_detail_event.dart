
import 'package:equatable/equatable.dart';

abstract class MedLockerDetailEvent extends Equatable {
  const MedLockerDetailEvent();
  @override List<Object> get props => [];
}

class LoadMedLockerDetail extends MedLockerDetailEvent {
  final int id;
  const LoadMedLockerDetail(this.id);
  @override List<Object> get props => [id];
}