class NotificationItem {
  final int id;
  final String title;
  final String message;
  final int readStatus; // 0 = unread, 1 = read

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.readStatus,
  });
}