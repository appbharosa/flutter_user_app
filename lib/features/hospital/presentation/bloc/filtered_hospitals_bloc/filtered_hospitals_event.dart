part of 'filtered_hospitals_bloc.dart';

abstract class FilteredHospitalsEvent extends Equatable {
  const FilteredHospitalsEvent();
  @override List<Object> get props => [];
}

class LoadFilteredHospitals extends FilteredHospitalsEvent {
  final String lang;
  final double lat;
  final double lon;
  final int catId;
  final String specialityIds;
  const LoadFilteredHospitals({
    required this.lang,
    required this.lat,
    required this.lon,
    required this.catId,
    required this.specialityIds,
  });
}