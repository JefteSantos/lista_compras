import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  ThemeProvider()
      : _isDark =
            HiveService.obterConfiguracao<bool>('tema_escuro') ?? false;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggle() async {
    _isDark = !_isDark;
    await HiveService.salvarConfiguracao('tema_escuro', _isDark);
    notifyListeners();
  }
}
