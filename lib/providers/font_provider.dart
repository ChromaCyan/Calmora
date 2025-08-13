import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider with ChangeNotifier {
  String _selectedFont = 'Roboto';
  double _scaleFactor = 1.0;

  String get selectedFont => _selectedFont;
  double get scaleFactor => _scaleFactor;

  FontProvider() {
    _loadFont();
  }

  Future<void> _loadFont() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString('font') ?? 'Roboto';
    _scaleFactor = prefs.getDouble('fontScale') ?? 1.0;
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _selectedFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font', font);
    notifyListeners();
  }

  Future<void> setScaleFactor(double factor) async {
    _scaleFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', factor);
    notifyListeners();
  }
}
