import 'dart:io';

abstract class MedLockerEvent {}

class LoadMedLockers extends MedLockerEvent {}

class LoadMedLockerDetail extends MedLockerEvent {
  final int id;
  LoadMedLockerDetail(this.id);
}

class AddMedLocker extends MedLockerEvent {
  final String name;
  final List<File> images;
  AddMedLocker(this.name, this.images);
}