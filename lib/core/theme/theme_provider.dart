import 'package:flutter/material.dart';
import 'package:aurora/core/storage.dart';

class ThemeProvider extends ChangeNotifier {
  int _themeIndex = 0;

  int get themeIndex => _themeIndex;

  ThemeData get theme {
    switch (_themeIndex) {
      case 0: return _lightTheme1;
      case 1: return _lightTheme2;
      case 2: return _darkTheme1;
      case 3: return _darkTheme2;
      default: return _lightTheme1;
    }
  }

  Future<void> init() async {
    _themeIndex = await Storage.getThemeIndex();
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    _themeIndex = index;
    await Storage.saveThemeIndex(index);
    notifyListeners();
  }

  static ThemeData _lightTheme1 = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF6366F1),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6),
      surface: Colors.white,
    ),
  );

  static ThemeData _lightTheme2 = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF06B6D4),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF06B6D4),
      secondary: const Color(0xFF0EA5E9),
      surface: Colors.white,
    ),
  );

  static ThemeData _darkTheme1 = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF6366F1),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6),
      surface: const Color(0xFF1E1E2E),
    ),
  );

  static ThemeData _darkTheme2 = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF06B6D4),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF06B6D4),
      secondary: const Color(0xFF0EA5E9),
      surface: const Color(0xFF1E1E2E),
    ),
  );
}
