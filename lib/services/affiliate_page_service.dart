import 'dart:convert';
import 'dart:io';
import '../models/affiliate_page_model.dart';

/// Persiste e recupera as configurações da página pública do afiliado
class AffiliatePageService {

  // Cache em memória por affiliateId
  static final Map<String, AffiliatePageModel> _cache = {};

  static Future<String> _filePath(String affiliateId) async {
    final dir = Directory.systemTemp;
    return '${dir.path}/achados_affiliate_${affiliateId}_page.json';
  }

  Future<AffiliatePageModel> getPage(String affiliateId, String name) async {
    if (_cache.containsKey(affiliateId)) {
      return _cache[affiliateId]!;
    }
    try {
      final path = await _filePath(affiliateId);
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final model = AffiliatePageModel.fromJson(
            jsonDecode(content) as Map<String, dynamic>);
        _cache[affiliateId] = model;
        return model;
      }
    } catch (_) {}
    // Padr\u00e3o
    final defaults = AffiliatePageModel(
      affiliateId: affiliateId,
      displayName: name,
    );
    _cache[affiliateId] = defaults;
    return defaults;
  }

  Future<void> savePage(AffiliatePageModel model) async {
    _cache[model.affiliateId] = model;
    try {
      final path = await _filePath(model.affiliateId);
      final file = File(path);
      await file.writeAsString(jsonEncode(model.toJson()));
    } catch (_) {}
  }
}
