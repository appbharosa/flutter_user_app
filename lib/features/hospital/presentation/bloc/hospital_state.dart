

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/hospital.dart';

abstract class HospitalState extends Equatable {
  const HospitalState();
  @override List<Object> get props => [];
}

class HospitalInitial extends HospitalState {}
class HospitalLoading extends HospitalState {}
class HospitalLoaded extends HospitalState {
  final List<Hospital> hospitals;
  final bool hasMore;
  const HospitalLoaded(this.hospitals, this.hasMore);
  @override List<Object> get props => [hospitals, hasMore];
}
class HospitalError extends HospitalState {
  final String message;
  const HospitalError(this.message);
  @override List<Object> get props => [message];
}