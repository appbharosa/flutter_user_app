import '../../domain/entities/ecard.dart';

class ECardModel extends ECard {
  ECardModel({
    required super.uniqueId,
    required super.toDate,
    required super.name,
    super.image,
  });

  factory ECardModel.fromJson(Map<String, dynamic> json) {
    return ECardModel(
      uniqueId: json['unique_id']?.toString(),
      toDate: json['to_date']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}