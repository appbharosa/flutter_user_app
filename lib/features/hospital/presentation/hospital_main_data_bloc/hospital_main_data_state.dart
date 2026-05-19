
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital_doctor.dart';
import '../../../../domain/entities/hospital_main_data.dart';


abstract class HospitalMainDataState extends Equatable {
  const HospitalMainDataState();
  @override List<Object> get props => [];
}

class HospitalMainDataInitial extends HospitalMainDataState {}
class HospitalMainDataLoading extends HospitalMainDataState {}
class HospitalMainDataLoaded extends HospitalMainDataState {
  final HospitalMainData hospital;
  final List<HospitalDoctor> doctors;
  const HospitalMainDataLoaded(this.hospital, this.doctors);
}
class HospitalMainDataError extends HospitalMainDataState {
  final String message;
  const HospitalMainDataError(this.message);
}