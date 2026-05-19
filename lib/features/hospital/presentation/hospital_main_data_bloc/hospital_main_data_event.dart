import 'package:equatable/equatable.dart';

abstract class HospitalMainDataEvent extends Equatable {
  const HospitalMainDataEvent();
  @override List<Object> get props => [];
}

class LoadHospitalMainData extends HospitalMainDataEvent {
  final int mainDataId;
  LoadHospitalMainData(this.mainDataId);
}