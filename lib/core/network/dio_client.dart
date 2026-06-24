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
      connectTimeout: const Duration(seconds: 70),
      receiveTimeout: const Duration(seconds: 70),
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _handleLogout();
      // Dummy response to prevent error propagation
      return handler.resolve(Response(
        requestOptions: err.requestOptions,
        statusCode: 200,
        data: {'status': 401, 'message': 'Unauthorized, redirecting'},
      ));
    }
    handler.next(err);
  }

  Future<void> _handleLogout() async {
    await secureStorage.deleteAll();

    // Retry up to 5 times, waiting 200ms between attempts
    for (int attempt = 0; attempt < 5; attempt++) {
      if (navigatorKey.currentContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        });
        return; // Success
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    // Still null after retries – log a warning
    print('❌ Could not navigate to Login – navigatorKey.context still null after 5 attempts');
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