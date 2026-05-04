
import 'package:equatable/equatable.dart';

abstract class AddMedLockerEvent extends Equatable {
  const AddMedLockerEvent();
  @override List<Object> get props => [];
}

class AddMedLockerSubmitted extends AddMedLockerEvent {
  final String name;
  final List<String> imagePaths;
  const AddMedLockerSubmitted({required this.name, required this.imagePaths});
  @override List<Object> get props => [name, imagePaths];
}