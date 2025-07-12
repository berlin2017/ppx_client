import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _themeBoxName = 'themeBox';
  static const _themeKey = 'themeMode';

  late Box _themeBox;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    initTheme();
  }

  Future<void> initTheme() async {
    await Hive.initFlutter();
    _themeBox = await Hive.openBox(_themeBoxName);
    final savedTheme = _themeBox.get(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.light,
      );
    }
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _themeBox.put(_themeKey, _themeMode.toString());
    notifyListeners();
  }
}