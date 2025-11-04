import 'package:flutter/material.dart';

/// Breakpoints tailored for mobile-first design
/// xs: very small phones (<360)
/// sm: small phones (360-480)
/// md: regular/large phones (480-600)
/// lg: large phones / small tablets (>=600)
enum AppBreakpoint { xs, sm, md, lg }

class Responsive {
  static AppBreakpoint breakpointOf(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return AppBreakpoint.xs;
    if (w < 480) return AppBreakpoint.sm;
    if (w < 600) return AppBreakpoint.md;
    return AppBreakpoint.lg;
  }
}

extension ResponsiveContext on BuildContext {
  AppBreakpoint get bp => Responsive.breakpointOf(this);

  /// Returns a value depending on breakpoint.
  /// Provide at least xs; others fall back to the previous smaller value.
  double responsiveDouble({
    required double xs,
    double? sm,
    double? md,
    double? lg,
  }) {
    final b = bp;
    switch (b) {
      case AppBreakpoint.xs:
        return xs;
      case AppBreakpoint.sm:
        return sm ?? xs;
      case AppBreakpoint.md:
        return md ?? sm ?? xs;
      case AppBreakpoint.lg:
        return lg ?? md ?? sm ?? xs;
    }
  }

  EdgeInsets responsiveInsets({
    required EdgeInsets xs,
    EdgeInsets? sm,
    EdgeInsets? md,
    EdgeInsets? lg,
  }) {
    final b = bp;
    switch (b) {
      case AppBreakpoint.xs:
        return xs;
      case AppBreakpoint.sm:
        return sm ?? xs;
      case AppBreakpoint.md:
        return md ?? sm ?? xs;
      case AppBreakpoint.lg:
        return lg ?? md ?? sm ?? xs;
    }
  }
}

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, AppBreakpoint breakpoint);

class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final b = Responsive.breakpointOf(context);
    return builder(context, b);
  }
}
