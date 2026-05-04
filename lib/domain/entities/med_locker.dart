import 'package:equatable/equatable.dart';
import 'med_locker_image.dart';

class MedLocker extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String? alertDate;
  final int status;
  final List<MedLockerImage> images;

  const MedLocker({
    required this.id,
    required this.userId,
    required this.name,
    this.alertDate,
    required this.status,
    this.images = const [],
  });

  @override
  List<Object?> get props => [id, name];
}