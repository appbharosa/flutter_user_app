import '../../domain/entities/med_locker_list_item.dart';
import 'med_locker_image_model.dart';

class MedLockerListItemModel extends MedLockerListItem {
  const MedLockerListItemModel({
    required super.id,
    required super.userId,
    required super.name,
    super.alertDate,
    required super.status,
    required super.images,
  });

  factory MedLockerListItemModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    final images = imagesList.map((img) => MedLockerImageModel.fromJson(img)).toList();
    return MedLockerListItemModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      alertDate: json['alert_date'],
      status: json['status'],
      images: images,
    );
  }
}