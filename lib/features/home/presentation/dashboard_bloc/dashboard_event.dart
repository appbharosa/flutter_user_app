

import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String language;
  const LoadDashboard(this.language);
  @override
  List<Object?> get props => [language];
}