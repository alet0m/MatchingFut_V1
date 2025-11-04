import 'package:flutter/material.dart';

class AppSnack {
  static void success(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
    );
  }

  static void warning(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    // Tertiary may be undefined in some old schemes; fall back to secondary.
    final bg = scheme.tertiaryContainer;
    final fg = scheme.onTertiaryContainer;
    _show(context, message, background: bg, foreground: fg);
  }

  static void error(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
    );
  }

  static void info(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    _show(
      context,
      message,
      background: scheme.inverseSurface,
      foreground: scheme.onInverseSurface,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required Color foreground,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
