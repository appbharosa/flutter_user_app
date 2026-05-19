
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// lib/core/utils/language_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<String> getCurrentLanguage() async {
    final saved = await _storage.read(key: _languageKey);
    if (saved == null) return 'en';
    if (saved.contains('english')) return 'en';
    if (saved.contains('telugu')) return 'te';
    if (saved.contains('hindi')) return 'hi';
    return 'en';
  }
}