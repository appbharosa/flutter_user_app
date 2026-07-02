import 'package:flutter/material.dart';

import '../../main.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Navigate to a new screen and remove all previous routes
  void pushAndRemoveUntil(Widget page) {
    // Use a post-frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => page),
              (route) => false,
        );
      } else {
        // If context is still null, retry after a short delay
        _retryNavigation(page);
      }
    });
  }

  void _retryNavigation(Widget page, {int attempts = 0}) {
    const maxAttempts = 10;
    if (attempts >= maxAttempts) {
      debugPrint('❌ Could not navigate to Login – max attempts reached');
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => page),
              (route) => false,
        );
      } else {
        _retryNavigation(page, attempts: attempts + 1);
      }
    });
  }
}