
import 'package:equatable/equatable.dart';

abstract class HospitalEvent extends Equatable {
  const HospitalEvent();
  @override List<Object> get props => [];
}

class LoadHospitals extends HospitalEvent {
  final int page;
  final double lat;
  final double lon;
  final String lang;
  const LoadHospitals({required this.page, required this.lat, required this.lon, required this.lang});
  @override List<Object> get props => [page, lat, lon, lang];
}

class LoadMoreHospitals extends HospitalEvent {}

class LoadHospitalsWithFilters extends HospitalEvent {
  final int page;
  final double lat;
  final double lon;
  final String lang;
  final String specialityIds;
  LoadHospitalsWithFilters({
    required this.page,
    required this.lat,
    required this.lon,
    required this.lang,
    required this.specialityIds,
  });
}

class LoadMoreHospitalsWithFilters extends HospitalEvent {
  final String specialityIds;
  LoadMoreHospitalsWithFilters({required this.specialityIds});
}