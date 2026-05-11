import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../appurls/app_urls.dart';
import 'package:flutter/material.dart';
import '../utils/navigation.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final List<String> _noTokenPaths = [
    'login',
    'otp-verification',
  ];

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppUrls.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(AuthInterceptor(secureStorage, _noTokenPaths));
    dio.interceptors.add(LoggingInterceptor());
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final List<String> noTokenPaths;

  AuthInterceptor(this.secureStorage, this.noTokenPaths);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final shouldSkipToken = noTokenPaths.any((path) => options.path.contains(path));
    if (!shouldSkipToken) {
      final token = await secureStorage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _handleLogout();
    }
    handler.next(err);
  }

  Future<void> _handleLogout() async {
    // Clear stored session
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'user_data');
    await secureStorage.delete(key: 'user_registration_data');

    // Navigate to login and clear the whole stack
    if (navigatorKey.currentContext != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("--> ${options.method} ${options.path}");
    print("Headers: ${options.headers}");
    print("Body: ${options.data}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("<-- ${response.statusCode} ${response.requestOptions.path}");
    print("Response: ${response.data}");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("ERROR: ${err.message}");
    handler.next(err);
  }
}