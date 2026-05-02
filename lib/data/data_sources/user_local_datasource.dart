import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/otp_response_model.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(OtpResponseModel user);
  Future<OtpResponseModel?> getUser();
  Future<void> clearUser();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage secureStorage;

  UserLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveUser(OtpResponseModel user) async {
    try {
      final jsonString = user.toJsonString();
      debugPrint(' saveUser: Writing user data to secure storage');
      debugPrint(' JSON string length: ${jsonString.length}');
      debugPrint(' User ID: ${user.id}, Name: ${user.name}, Token: ${user.accessToken.substring(0, 20)}...');
      await secureStorage.write(key: 'user_data', value: jsonString);
      debugPrint(' saveUser: Successfully saved');
    } catch (e, stack) {
      debugPrint(' saveUser: Failed to save user data: $e');
      debugPrint('StackTrace: $stack');
      rethrow;
    }
  }

  @override
  Future<OtpResponseModel?> getUser() async {
    try {
      debugPrint('🔍 getUser: Attempting to read user data');
      final userJsonString = await secureStorage.read(key: 'user_data');
      if (userJsonString == null) {
        debugPrint('⚠ getUser: No user data found (null)');
        return null;
      }
      debugPrint('📄 getUser: Raw JSON string: $userJsonString');
      final user = OtpResponseModel.fromJsonString(userJsonString);
      debugPrint(' getUser: Success - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}');
      return user;
    } catch (e, stack) {
      debugPrint(' getUser: Failed to parse user data: $e');
      debugPrint('StackTrace: $stack');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      debugPrint('🧹 clearUser: Deleting user data');
      await secureStorage.delete(key: 'user_data');
      debugPrint(' clearUser: Successfully cleared');
    } catch (e, stack) {
      debugPrint(' clearUser: Failed to clear: $e');
      debugPrint('StackTrace: $stack');
      rethrow;
    }
  }
}