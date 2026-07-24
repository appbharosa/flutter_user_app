import 'package:equatable/equatable.dart';

abstract class HospitalMainDataEvent extends Equatable {
  const HospitalMainDataEvent();
  @override List<Object> get props => [];
}

class LoadHospitalMainData extends HospitalMainDataEvent {
  final int mainDataId;
  final String lang;
  LoadHospitalMainData(this.mainDataId, this.lang);
}