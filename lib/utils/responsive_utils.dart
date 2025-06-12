import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/breakpoints.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet;

  static double getAdaptiveWidth(BuildContext context, double percentage) {
    double width = MediaQuery.of(context).size.width;
    if (width > Breakpoints.maxContentWidth) {
      width = Breakpoints.maxContentWidth;
    }
    return width * percentage;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return Breakpoints.mediumPadding;
    if (isTablet(context)) return Breakpoints.largePadding;
    return Breakpoints.extraLargePadding;
  }

  static double getWebContentWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      if (width > Breakpoints.webMaxWidth) {
        return Breakpoints.webContentWidth;
      }
      return width * 0.9;
    }
    return width;
  }

  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (kIsWeb) {
      double horizontalMargin = (MediaQuery.of(context).size.width - getWebContentWidth(context)) / 2;
      return EdgeInsets.symmetric(
        horizontal: horizontalMargin.clamp(16, 32),
        vertical: 16,
      );
    }
    return EdgeInsets.all(getResponsivePadding(context));
  }
}
