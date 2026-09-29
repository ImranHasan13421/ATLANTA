import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available accent color presets for ATLANTA.
enum AtlantaAccent {
  red,
  orange,
  purple,
  gold,
  green,
  gray,
  blue,
}

class AccentPreset {
  final AtlantaAccent accent;
  final String label;
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final Color neon;

  const AccentPreset({
    required this.accent,
    required this.label,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.neon,
  });
}

/// Global Theme & Accent Controller for Atlanta.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();

  ThemeController._internal() {
    _loadFromPrefs();
  }

  static const String _prefKey = 'atlanta_accent_color';

  static const Map<AtlantaAccent, AccentPreset> presets = {
    AtlantaAccent.red: AccentPreset(
      accent: AtlantaAccent.red,
      label: 'Red',
      primary: Color(0xFFEF4444),
      primaryLight: Color(0xFFF87171),
      secondary: Color(0xFF991B1B),
      neon: Color(0xFFFF3B5C),
    ),
    AtlantaAccent.orange: AccentPreset(
      accent: AtlantaAccent.orange,
      label: 'Orange',
      primary: Color(0xFFF97316),
      primaryLight: Color(0xFFFB923C),
      secondary: Color(0xFF9A3412),
      neon: Color(0xFFFF9E43),
    ),
    AtlantaAccent.purple: AccentPreset(
      accent: AtlantaAccent.purple,
      label: 'Purple',
      primary: Color(0xFFA855F7),
      primaryLight: Color(0xFFC084FC),
      secondary: Color(0xFF6B21A8),
      neon: Color(0xFFE879F9),
    ),
    AtlantaAccent.gold: AccentPreset(
      accent: AtlantaAccent.gold,
      label: 'Gold',
      primary: Color(0xFFEAB308),
      primaryLight: Color(0xFFFDE047),
      secondary: Color(0xFF854D0E),
      neon: Color(0xFFFFD700),
    ),
    AtlantaAccent.green: AccentPreset(
      accent: AtlantaAccent.green,
      label: 'Green',
      primary: Color(0xFF22C55E),
      primaryLight: Color(0xFF4ADE80),
      secondary: Color(0xFF166534),
      neon: Color(0xFF00FF88),
    ),
    AtlantaAccent.gray: AccentPreset(
      accent: AtlantaAccent.gray,
      label: 'Gray',
      primary: Color(0xFF94A3B8),
      primaryLight: Color(0xFFCBD5E1),
      secondary: Color(0xFF475569),
      neon: Color(0xFFE2E8F0),
    ),
    AtlantaAccent.blue: AccentPreset(
      accent: AtlantaAccent.blue,
      label: 'Blue',
      primary: Color(0xFF1D6FE8),
      primaryLight: Color(0xFF4D9BFF),
      secondary: Color(0xFF2F2E98),
      neon: Color(0xFF00F0FF),
    ),
  };

  AtlantaAccent _currentAccent = AtlantaAccent.blue;

  AtlantaAccent get currentAccent => _currentAccent;
  AccentPreset get currentPreset => presets[_currentAccent] ?? presets[AtlantaAccent.blue]!;

  Color get primary => currentPreset.primary;
  Color get primaryLight => currentPreset.primaryLight;
  Color get secondary => currentPreset.secondary;
  Color get neon => currentPreset.neon;

  Color get primaryGlow => primary.withValues(alpha: 0.22);
  Color get primaryGlowStrong => primary.withValues(alpha: 0.45);
  Color get orbGlow => primary.withValues(alpha: 0.40);
  Color get orbCore => primaryLight;
  Color get orbInner => primary;
  Color get orbOuter => secondary;
  Color get navActive => primary;
  Color get navActiveBackground => primary.withValues(alpha: 0.18);
  Color get borderFocus => primary;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        final match = AtlantaAccent.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AtlantaAccent.blue,
        );
        if (match != _currentAccent) {
          _currentAccent = match;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> setAccent(AtlantaAccent accent) async {
    if (_currentAccent == accent) return;
    _currentAccent = accent;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, accent.name);
    } catch (_) {}
  }
}
