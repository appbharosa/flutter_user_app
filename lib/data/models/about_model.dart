import '../../domain/entities/about.dart';

class AboutModel extends About {
  const AboutModel({
    required super.id,
    required super.content,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      id: json['id'],
      content: json['name'] ?? '',  // API puts the text in 'name'
    );
  }
}