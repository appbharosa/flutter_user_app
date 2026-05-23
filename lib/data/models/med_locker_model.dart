import '../../domain/entities/med_locker.dart';
import 'med_locker_image_model.dart';

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
    // The input json is the entire 'result' object from the API
    final medLockerJson = json['medlocker'] as Map<String, dynamic>;
    final imagesList = json['images'] as List? ?? [];
    final images = imagesList.map((img) => MedLockerImageModel.fromJson(img)).toList();

    return MedLockerModel(
      id: medLockerJson['id'],
      userId: medLockerJson['user_id'],
      name: medLockerJson['name'],
      alertDate: null,                     // Not provided in this response
      status: 1,                           // Default to active (no status in response)
      images: images,
    );
  }
}