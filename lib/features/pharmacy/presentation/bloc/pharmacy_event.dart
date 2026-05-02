
import 'package:equatable/equatable.dart';

abstract class PharmacyEvent extends Equatable {
  const PharmacyEvent();
  @override List<Object> get props => [];
}

class LoadPharmacies extends PharmacyEvent {
  final int page;
  final double lat;
  final double lon;
  final String lang;
  const LoadPharmacies({required this.page, required this.lat, required this.lon, required this.lang});
  @override List<Object> get props => [page, lat, lon, lang];
}

class LoadMorePharmacies extends PharmacyEvent {}