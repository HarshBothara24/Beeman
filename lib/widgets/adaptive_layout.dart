import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (ResponsiveUtils.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
