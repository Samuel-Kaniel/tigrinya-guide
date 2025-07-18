import 'package:flutter/material.dart';

/// Helper class for responsive design
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Get the appropriate value based on screen size
  static T getValueForScreenType<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get a responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getValueForScreenType(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get a responsive font size based on screen size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize, {
    double? minFontSize,
    double? maxFontSize,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375; // Base on iPhone 8 width

    double responsiveFontSize = baseFontSize * scaleFactor;

    if (minFontSize != null && responsiveFontSize < minFontSize) {
      return minFontSize;
    }

    if (maxFontSize != null && responsiveFontSize > maxFontSize) {
      return maxFontSize;
    }

    return responsiveFontSize;
  }
}
