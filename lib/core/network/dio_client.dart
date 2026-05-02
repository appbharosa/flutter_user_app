import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../appurls/app_urls.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // List of API paths that do NOT require an access token
  final List<String> _noTokenPaths = [
    'login',        // send OTP endpoint
    'otp-verification', // verify OTP endpoint (if it doesn't need token)
    // add other public endpoints here
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

// ========== Auth Interceptor ==========
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final List<String> noTokenPaths;

  AuthInterceptor(this.secureStorage, this.noTokenPaths);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if the request path matches any of the no‑token paths
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
    // Handle 401 Unauthorized globally
    if (err.response?.statusCode == 401) {
      secureStorage.delete(key: 'access_token');
      secureStorage.delete(key: 'user_data');
      // Optional: add a stream/event to notify app about logout
    }
    handler.next(err);
  }
}

// ========== Logging Interceptor (optional) ==========
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