import '../../domain/entities/med_locker.dart';
import 'med_locker_image_model.dart';

class MedLockerModel extends MedLocker {
  const MedLockerModel({
    required super.id,
    required super.userId,
    required super.name,
    super.alertDate,
    required super.status,
    required super.images,
  });

  factory MedLockerModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    final images = imagesList.map((img) => MedLockerImageModel.fromJson(img)).toList();
    return MedLockerModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      alertDate: json['alert_date'],
      status: json['status'],
      images: images,
    );
  }
}