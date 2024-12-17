import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = AppTheme.darkTheme; // Default to dark theme

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    print('toggleTheme called'); // Debug print
    if (_currentTheme.brightness == Brightness.dark) {
      _currentTheme = AppTheme.lightTheme;
      print('Switched to light theme'); // Debug print
    } else {
      _currentTheme = AppTheme.darkTheme;
      print('Switched to dark theme'); // Debug print
    }
    notifyListeners();
  }
}
