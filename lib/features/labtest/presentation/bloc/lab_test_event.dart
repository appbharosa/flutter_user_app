
import 'package:equatable/equatable.dart';

abstract class LabTestEvent extends Equatable {
  const LabTestEvent();
  @override List<Object> get props => [];
}

class LoadLabTests extends LabTestEvent {
  final int page;
  final double lat;
  final double lon;
  final String lang;
  const LoadLabTests({required this.page, required this.lat, required this.lon, required this.lang});
  @override List<Object> get props => [page, lat, lon, lang];
}

class LoadMoreLabTests extends LabTestEvent {}