

import 'package:equatable/equatable.dart';

abstract class OnlineDoctorEvent extends Equatable {
  const OnlineDoctorEvent();
  @override List<Object> get props => [];
}

class LoadOnlineDoctors extends OnlineDoctorEvent {
  final int page;
  final String lang;
  final int? specialityId;
  const LoadOnlineDoctors({required this.page, required this.lang, this.specialityId});
}

class LoadMoreOnlineDoctors extends OnlineDoctorEvent {}
class ChangeSpeciality extends OnlineDoctorEvent {
  final int? specialityId;
  const ChangeSpeciality(this.specialityId);
}