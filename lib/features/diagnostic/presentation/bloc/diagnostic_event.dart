

import 'package:equatable/equatable.dart';

abstract class DiagnosticEvent extends Equatable {
  const DiagnosticEvent();
  @override List<Object> get props => [];
}

class LoadDiagnostics extends DiagnosticEvent {
  final int page;
  final double lat;
  final double lon;
  final String lang;
  const LoadDiagnostics({required this.page, required this.lat, required this.lon, required this.lang});
  @override List<Object> get props => [page, lat, lon, lang];
}

class LoadMoreDiagnostics extends DiagnosticEvent {}