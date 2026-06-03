import '../../domain/entities/free_lab_report.dart';

class FreeLabReportModel extends FreeLabReport {
  FreeLabReportModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.imageUrl,
    required super.deleteStatus,
  });

  factory FreeLabReportModel.fromJson(Map<String, dynamic> json) {
    return FreeLabReportModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      imageUrl: json['image'] ?? '',
      deleteStatus: json['delete_status'] ?? 0,
    );
  }
}