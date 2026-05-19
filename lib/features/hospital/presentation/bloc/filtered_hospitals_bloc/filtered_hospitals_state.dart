import 'package:equatable/equatable.dart';
import '../../../../../domain/entities/hospital.dart';

abstract class FilteredHospitalsState extends Equatable {
  const FilteredHospitalsState();
  @override List<Object> get props => [];
}

class FilteredHospitalsInitial extends FilteredHospitalsState {}
class FilteredHospitalsLoading extends FilteredHospitalsState {}
class FilteredHospitalsLoaded extends FilteredHospitalsState {
  final List<Hospital> hospitals;
  const FilteredHospitalsLoaded(this.hospitals);
}
class FilteredHospitalsError extends FilteredHospitalsState {
  final String message;
  const FilteredHospitalsError(this.message);
}