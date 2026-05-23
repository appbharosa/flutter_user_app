import '../../domain/entities/med_locker_add_response.dart';
import 'med_locker_image_model.dart';

class MedLockerAddResponseModel extends MedLockerAddResponse {
  const MedLockerAddResponseModel({
    required super.id,
    required super.name,
    required super.images,
  });

  factory MedLockerAddResponseModel.fromJson(Map<String, dynamic> json) {
    final medLockerJson = json['medlocker'] as Map<String, dynamic>;
    final imagesList = json['images'] as List? ?? [];
    final images = imagesList.map((img) => MedLockerImageModel.fromJson(img)).toList();
    return MedLockerAddResponseModel(
      id: medLockerJson['id'],
      name: medLockerJson['name'],
      images: images,
    );
  }
}