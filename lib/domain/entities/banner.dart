import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final int id;
  final String imageUrl;
  final String position;
  final int status;

  const Banner({
    required this.id,
    required this.imageUrl,
    required this.position,
    required this.status,
  });

  @override
  List<Object> get props => [id, imageUrl, position, status];
}