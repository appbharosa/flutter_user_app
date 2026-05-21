import 'package:equatable/equatable.dart';
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String language;
  const LoadNotifications(this.language);
  @override
  List<Object?> get props => [language];
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;
  final String language;
  const MarkNotificationAsRead(this.notificationId, this.language);
  @override
  List<Object?> get props => [notificationId, language];
}
class MarkAllNotificationsAsRead extends NotificationEvent {
  final String language;
  const MarkAllNotificationsAsRead(this.language);
  @override
  List<Object?> get props => [language];
}