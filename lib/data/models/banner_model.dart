import '../../core/appurls/app_urls.dart';
import '../../domain/entities/banner.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.imageUrl,
    required super.position,
    required super.status,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      // Complete the full image URL using base URL
      imageUrl: '${AppUrls.imageBaseUrl}${json[' ']}',
      position: json['position'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'position': position,
      'status': status,
    };
  }
}