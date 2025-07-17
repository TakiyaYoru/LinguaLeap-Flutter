// lib/core/utils/platform_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:4001'; // Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:4001'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:4001'; // iOS simulator
    } else {
      return 'http://localhost:4001'; // Desktop
    }
  }
  
  static String getGraphQLEndpoint() {
    return '${getBackendUrl()}/graphql';
  }
  
  static String getHealthCheckUrl() {
    return '${getBackendUrl()}/health';
  }
} 