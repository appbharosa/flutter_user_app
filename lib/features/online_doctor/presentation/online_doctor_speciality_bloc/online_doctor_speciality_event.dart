
import 'package:equatable/equatable.dart';


abstract class OnlineDoctorSpecialityEvent extends Equatable {
  const OnlineDoctorSpecialityEvent();
  @override List<Object> get props => [];
}

class LoadOnlineDoctorSpecialities extends OnlineDoctorSpecialityEvent {
  final String lang;
  const LoadOnlineDoctorSpecialities(this.lang);
  @override List<Object> get props => [lang];
}