import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

enum AppThemeMode { dark, light, system }

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  AppThemeMode _mode = AppThemeMode.dark;

  AppThemeMode get mode => _mode;

  String get modeLabel {
    switch (_mode) {
      case AppThemeMode.dark: return 'Escuro';
      case AppThemeMode.light: return 'Claro';
      case AppThemeMode.system: return 'Automático (sistema)';
    }
  }

  Future<void> init() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final saved = data['themeMode']?.toString();
        _mode = AppThemeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => AppThemeMode.dark,
        );
      }
    } catch (_) {}
  }

  Future<void> setMode(AppThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode({'themeMode': mode.name}));
    } catch (_) {}
  }

  Future<File> _getFile() async {
    return File('${Directory.systemTemp.path}/achados_theme.json');
  }
}
