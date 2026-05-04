import 'package:equatable/equatable.dart';

class MedLockerImage extends Equatable {
  final int id;
  final int userId;
  final int medLockerId;
  final String imageUrl;
  final int status;

  const MedLockerImage({
    required this.id,
    required this.userId,
    required this.medLockerId,
    required this.imageUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [id, imageUrl];
}