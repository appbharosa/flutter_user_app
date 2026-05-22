import 'package:equatable/equatable.dart';

class OtpResponse extends Equatable {
  final int id;
  final String uniqueId;
  final String phone;
  final String name;
  final String email;
  final String image;
  final String playerId;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const OtpResponse({
    required this.id,
    required this.uniqueId,
    required this.phone,
    required this.name,
    required this.email,
    required this.image,
    required this.playerId,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  @override
  List<Object> get props => [id, accessToken];
}