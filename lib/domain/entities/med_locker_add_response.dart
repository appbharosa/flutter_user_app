import 'package:equatable/equatable.dart';
import 'med_locker_image.dart';

class MedLockerAddResponse extends Equatable {
  final int id;
  final String name;
  final List<MedLockerImage> images;

  const MedLockerAddResponse({
    required this.id,
    required this.name,
    required this.images,
  });

  @override
  List<Object?> get props => [id, name];
}