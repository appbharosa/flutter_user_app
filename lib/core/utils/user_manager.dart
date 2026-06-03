import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/otp_response_model.dart';
class UserManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _freeLabUtilizedKey = 'free_lab_utilized';
  static const String _subscriptionActiveKey = 'subscription_active';
  static const String _userDataKey = 'user_data';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPlayerIdKey = 'user_player_id';
  static const String _accessTokenKey = 'access_token';

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

  static Future<void> setSubscriptionActive(bool active) async {
    await _storage.write(key: _subscriptionActiveKey, value: active.toString());
  }

  static Future<void> setFreeLabUtilized(bool utilized) async {
    await _storage.write(key: _freeLabUtilizedKey, value: utilized.toString());
  }
  /// Returns the stored user name
  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  /// Returns the stored user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Returns the stored player ID
  static Future<String?> getPlayerId() async {
    return await _storage.read(key: _userPlayerIdKey);
  }

  /// Returns the stored access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Saves the complete user data from OtpResponseModel
  static Future<void> saveUser(OtpResponseModel user) async {
    await _storage.write(key: _userDataKey, value: user.toJsonString());
    await _storage.write(key: _userNameKey, value: user.name);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userPlayerIdKey, value: user.playerId);
    await _storage.write(key: _accessTokenKey, value: user.accessToken);
  }

  /// Saves user name and email separately (useful for registration)
  static Future<void> saveUserDetails({required String name, required String email}) async {
    if (name.isNotEmpty) {
      await _storage.write(key: _userNameKey, value: name);
    }
    if (email.isNotEmpty) {
      await _storage.write(key: _userEmailKey, value: email);
    }
  }

  /// Updates only the player ID
  static Future<void> updatePlayerId(String playerId) async {
    await _storage.write(key: _userPlayerIdKey, value: playerId);

    // Also update in the stored user JSON if it exists
    final userJson = await _storage.read(key: _userDataKey);
    if (userJson != null) {
      try {
        final user = OtpResponseModel.fromJsonString(userJson);
        final updatedUser = OtpResponseModel(
          id: user.id,
          uniqueId: user.uniqueId,
          phone: user.phone,
          name: user.name,
          email: user.email,
          image: user.image,
          playerId: playerId,
          accessToken: user.accessToken,
          tokenType: user.tokenType,
          expiresIn: user.expiresIn,
        );
        await _storage.write(key: _userDataKey, value: updatedUser.toJsonString());
      } catch (e) {
        // Ignore parsing errors
      }
    }
  }

  static Future<bool> hasActiveSubscription() async {
    final value = await _storage.read(key: _subscriptionActiveKey);
    return value == 'true';
  }

  static Future<bool> isFreeLabUtilized() async {
    final value = await _storage.read(key: _freeLabUtilizedKey);
    return value == 'true';
  }

  /// Clears all user data (logout)
  static Future<void> clearUserData() async {
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userPlayerIdKey);
    await _storage.delete(key: _accessTokenKey);
  }
}