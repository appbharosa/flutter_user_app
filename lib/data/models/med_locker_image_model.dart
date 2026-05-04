import '../../domain/entities/med_locker_image.dart';

class MedLockerImageModel extends MedLockerImage {
  const MedLockerImageModel({
    required super.id,
    required super.userId,
    required super.medLockerId,
    required super.imageUrl,
    required super.status,
  });

  factory MedLockerImageModel.fromJson(Map<String, dynamic> json) {
    return MedLockerImageModel(
      id: json['id'],
      userId: json['user_id'],
      medLockerId: json['med_locker_id'],
      imageUrl: json['image'],
      status: json['status'],
    );
  }
}