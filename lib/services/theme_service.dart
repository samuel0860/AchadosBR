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
      case AppThemeMode.dark:
        return 'Escuro';
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.system:
        return 'Automático (sistema)';
    }
  }

  Future<void> init() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final data =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
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

  /// Retorna um caminho de arquivo que funciona tanto no emulador quanto no APK.
  /// No Android, o Flutter define TMPDIR como o diretório de cache privado do app.
  Future<File> _getFile() async {
    return _getStorageFile('achados_theme.json');
  }
}

/// Obtém um arquivo num diretório que funciona em todas as plataformas.
/// - Android APK: usa TMPDIR (diretório de cache privado definido pelo Flutter engine)
/// - iOS: usa HOME
/// - Outras: usa Directory.systemTemp
Future<File> getStorageFile(String filename) => _getStorageFile(filename);

Future<File> _getStorageFile(String filename) async {
  String dirPath;
  try {
    if (!kIsWeb && Platform.isAndroid) {
      // O Flutter engine no Android define TMPDIR para o diretório de cache privado
      // do app: /data/user/0/{package}/cache — acessível e persistente entre sessões
      dirPath = Platform.environment['TMPDIR'] ??
          Platform.environment['HOME'] ??
          Directory.systemTemp.path;
    } else if (!kIsWeb && Platform.isIOS) {
      dirPath =
          Platform.environment['HOME'] ?? Directory.systemTemp.path;
    } else {
      dirPath = Directory.systemTemp.path;
    }
  } catch (_) {
    dirPath = Directory.systemTemp.path;
  }

  try {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  } catch (_) {}

  return File('$dirPath/$filename');
}
