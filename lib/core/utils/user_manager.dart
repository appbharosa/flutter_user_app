
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/otp_response_model.dart';

class UserManager {
  static const _storage = FlutterSecureStorage();
  static const String _userDataKey = 'user_data';

  /// Returns the stored user ID, or null if not found or parsing fails.
  static Future<int?> getUserId() async {
    final userJson = await _storage.read(key: _userDataKey);
    if (userJson == null) return null;
    try {
      final user = OtpResponseModel.fromJsonString(userJson);
      return user.id;
    } catch (e) {
      return null;
    }
  }
}