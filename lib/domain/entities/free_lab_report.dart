class FreeLabReport {
  final int id;
  final int userId;
  final String type;
  final String imageUrl; 
  final int deleteStatus;

  FreeLabReport({
    required this.id,
    required this.userId,
    required this.type,
    required this.imageUrl,
    required this.deleteStatus,
  });
}