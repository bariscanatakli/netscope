import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = AppTheme.darkTheme;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme.brightness == Brightness.dark
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;
    notifyListeners();
  }
}
