import '../../domain/entities/notification_item.dart';

class NotificationItemModel extends NotificationItem {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required super.message,
    required super.readStatus,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      readStatus: int.tryParse(json['read_status'].toString()) ?? 0,
    );
  }
}