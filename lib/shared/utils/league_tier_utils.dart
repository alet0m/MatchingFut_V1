import 'package:flutter/material.dart';

class LeagueTierMeta {
  final String name; // Display name
  final String emoji;
  final Color color;
  const LeagueTierMeta({required this.name, required this.emoji, required this.color});
}

/// Football-themed league tiers metadata for UI
/// Keys match the `league_tier` slug from the database
const Map<String, LeagueTierMeta> kLeagueTiersMeta = {
  'pichanga': LeagueTierMeta(name: 'Pichanga', emoji: '🥾', color: Color(0xFF9E9E9E)),
  'barrio': LeagueTierMeta(name: 'Liga de Barrio', emoji: '🏡', color: Color(0xFF8BC34A)),
  'interbarrio': LeagueTierMeta(name: 'Interbarrio', emoji: '🤝', color: Color(0xFF4CAF50)),
  'comunal': LeagueTierMeta(name: 'Comunal', emoji: '🏙️', color: Color(0xFF2E7D32)),
  'regional': LeagueTierMeta(name: 'Regional', emoji: '🌍', color: Color(0xFF1B5E20)),
  'nacional': LeagueTierMeta(name: 'Nacional', emoji: '🏟️', color: Color(0xFFFF6F00)),
  'primera_b': LeagueTierMeta(name: 'Primera B', emoji: '⚪', color: Color(0xFF607D8B)),
  'primera_a': LeagueTierMeta(name: 'Primera A', emoji: '⭐', color: Color(0xFFFFC107)),
  'libertadores': LeagueTierMeta(name: 'Libertadores', emoji: '🏆', color: Color(0xFFFFD700)),
};
