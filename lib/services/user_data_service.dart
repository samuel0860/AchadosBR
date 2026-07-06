import 'dart:convert';
import 'dart:io';

/// Serviço de armazenamento local para dados do usuário (salvos, histórico, alertas)
class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final List<String> _savedDealIds = [];
  final List<Map<String, dynamic>> _visitHistory = [];
  final Set<String> _alertCategories = {'eletronicos', 'moda'};
  bool _alertsEnabled = true;

  List<String> get savedDealIds => List.unmodifiable(_savedDealIds);
  List<Map<String, dynamic>> get visitHistory => List.unmodifiable(_visitHistory);
  Set<String> get alertCategories => Set.unmodifiable(_alertCategories);
  bool get alertsEnabled => _alertsEnabled;

  bool isSaved(String dealId) => _savedDealIds.contains(dealId);

  Future<void> init() async => _loadFromDisk();

  void toggleSave(String dealId) {
    if (_savedDealIds.contains(dealId)) {
      _savedDealIds.remove(dealId);
    } else {
      _savedDealIds.insert(0, dealId);
    }
    _saveToDisk();
  }

  void addVisit(String dealId, String dealTitle, String imageUrl) {
    // Remove duplicatas recentes
    _visitHistory.removeWhere((v) => v['id'] == dealId);
    _visitHistory.insert(0, {
      'id': dealId,
      'title': dealTitle,
      'imageUrl': imageUrl,
      'visitedAt': DateTime.now().toIso8601String(),
    });
    // Máximo 50 no histórico
    if (_visitHistory.length > 50) _visitHistory.removeLast();
    _saveToDisk();
  }

  void clearHistory() {
    _visitHistory.clear();
    _saveToDisk();
  }

  void toggleAlertCategory(String category) {
    if (_alertCategories.contains(category)) {
      _alertCategories.remove(category);
    } else {
      _alertCategories.add(category);
    }
    _saveToDisk();
  }

  void setAlertsEnabled(bool value) {
    _alertsEnabled = value;
    _saveToDisk();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<File> _getFile() async =>
      File('${Directory.systemTemp.path}/achados_userdata.json');

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return;
      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _savedDealIds.clear();
      _savedDealIds.addAll(List<String>.from(data['savedDealIds'] ?? []));
      _visitHistory.clear();
      _visitHistory.addAll(
        List<Map<String, dynamic>>.from(data['visitHistory'] ?? []),
      );
      _alertCategories.clear();
      _alertCategories.addAll(List<String>.from(data['alertCategories'] ?? ['eletronicos']));
      _alertsEnabled = data['alertsEnabled'] == true;
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode({
        'savedDealIds': _savedDealIds,
        'visitHistory': _visitHistory,
        'alertCategories': _alertCategories.toList(),
        'alertsEnabled': _alertsEnabled,
      }));
    } catch (_) {}
  }
}
