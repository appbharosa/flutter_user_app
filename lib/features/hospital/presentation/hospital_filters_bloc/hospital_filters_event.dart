import 'package:equatable/equatable.dart';

abstract class HospitalFiltersEvent extends Equatable {
  const HospitalFiltersEvent();
  @override List<Object> get props => [];
}

class LoadHospitalFilters extends HospitalFiltersEvent {}