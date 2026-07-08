import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'theme_service.dart' show getStorageFile;

class AppConfigService extends ChangeNotifier {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  bool _hasSeenOnboarding = false;

  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<File> _getFile() => getStorageFile('app_config.json');

  Future<void> init() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        _hasSeenOnboarding = data['hasSeenOnboarding'] ?? false;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    try {
      final file = await _getFile();
      final data = {'hasSeenOnboarding': true};
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}
