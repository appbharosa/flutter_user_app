import 'dart:convert';

import 'package:user/domain/entities/otp_response.dart';
import 'package:equatable/equatable.dart';

class OtpResponseModel extends OtpResponse {
  const OtpResponseModel({
    required super.id,
    required super.uniqueId,
    required super.phone,
    required super.name,
    required super.email,
    required super.image,
    required super.playerId,
    required super.accessToken,
    required super.tokenType,
    required super.expiresIn,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      id: json['id'],
      uniqueId: json['unique_id'] ?? '',
      phone: json['phone'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      playerId: json['player_id'] ?? '',
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  /// Convert model to JSON for local storage
  String toJsonString() {
    return jsonEncode({
      'id': id,
      'unique_id': uniqueId,
      'phone': phone,
      'name': name,
      'email': email,
      'image': image,
      'player_id': playerId,
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    });
  }
  factory OtpResponseModel.fromJsonString(String jsonString) {
    return OtpResponseModel.fromJson(jsonDecode(jsonString));
  }
}