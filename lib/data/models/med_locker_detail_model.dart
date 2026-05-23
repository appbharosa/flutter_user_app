import '../../domain/entities/med_locker_detail.dart';
import 'med_locker_image_model.dart';

class MedLockerDetailModel extends MedLockerDetail {
  const MedLockerDetailModel({
    required super.id,
    required super.userId,
    required super.name,
    super.alertDate,
    required super.status,
    required super.images,
  });

  factory MedLockerDetailModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    final images = imagesList.map((img) => MedLockerImageModel.fromJson(img)).toList();
    return MedLockerDetailModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      alertDate: json['alert_date'],
      status: json['status'],
      images: images,
    );
  }
}