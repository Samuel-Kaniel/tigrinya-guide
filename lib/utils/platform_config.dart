import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class for platform-specific configurations
class PlatformConfig {
  /// Check if the app is running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if the app is running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if the app is running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if the app is running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if the app is running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if the app is running on the web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on a mobile device
  static bool get isMobile => isIOS || isAndroid;

  /// Check if the app is running on a desktop device
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Get the appropriate value based on platform
  static T getValueForPlatform<T>({
    required T defaultValue,
    T? iOS,
    T? android,
    T? macOS,
    T? windows,
    T? linux,
    T? web,
  }) {
    if (isIOS && iOS != null) return iOS;
    if (isAndroid && android != null) return android;
    if (isMacOS && macOS != null) return macOS;
    if (isWindows && windows != null) return windows;
    if (isLinux && linux != null) return linux;
    if (isWeb && web != null) return web;
    return defaultValue;
  }
}
