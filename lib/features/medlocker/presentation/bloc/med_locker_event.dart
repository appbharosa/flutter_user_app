import 'package:equatable/equatable.dart';

abstract class MedLockerEvent extends Equatable {
  const MedLockerEvent();
  @override List<Object> get props => [];
}

class LoadMedLockers extends MedLockerEvent {}