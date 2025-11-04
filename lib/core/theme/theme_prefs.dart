import 'package:flutter/material.dart';

class ThemePrefs {
  final String seedHex;
  final String accentHex;
  final String mode; // 'system' | 'light' | 'dark'
  final String style; // 'default' | 'amoled'

  const ThemePrefs({
    required this.seedHex,
    required this.accentHex,
    required this.mode,
    this.style = 'default',
  });

  factory ThemePrefs.defaults() => const ThemePrefs(
    seedHex: '#2E7D32',
    accentHex: '#FF6F00',
    mode: 'system',
    style: 'default',
  );

  factory ThemePrefs.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ThemePrefs.defaults();
    String normalize(String? hex, String fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      if (!hex.startsWith('#')) return '#$hex';
      return hex;
    }

    final style = (map['style'] as String?)?.toLowerCase();
    return ThemePrefs(
      seedHex: normalize(map['seed'] as String?, '#2E7D32'),
      accentHex: normalize(map['accent'] as String?, '#FF6F00'),
      mode: (map['mode'] as String?)?.toLowerCase() ?? 'system',
      style: (style == 'amoled') ? 'amoled' : 'default',
    );
  }

  Map<String, dynamic> toMap() => {
    'seed': seedHex,
    'accent': accentHex,
    'mode': mode,
    'style': style,
  };

  Color get seedColor => _colorFromHex(seedHex);
  Color get accentColor => _colorFromHex(accentHex);

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    String clean = hex.replaceAll('#', '');
    if (clean.length == 6) buffer.write('ff');
    buffer.write(clean);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
