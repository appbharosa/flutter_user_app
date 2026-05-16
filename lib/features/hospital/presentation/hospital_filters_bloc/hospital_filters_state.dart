
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/hospital_filter_category.dart';

abstract class HospitalFiltersState extends Equatable {
  const HospitalFiltersState();
  @override List<Object> get props => [];
}

class HospitalFiltersInitial extends HospitalFiltersState {}
class HospitalFiltersLoading extends HospitalFiltersState {}
class HospitalFiltersLoaded extends HospitalFiltersState {
  final List<HospitalFilterCategory> categories;
  const HospitalFiltersLoaded(this.categories);
  @override List<Object> get props => [categories];
}
class HospitalFiltersError extends HospitalFiltersState {
  final String message;
  const HospitalFiltersError(this.message);
  @override List<Object> get props => [message];
}