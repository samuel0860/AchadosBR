import 'dart:convert';
import 'dart:io';
import '../models/affiliate_page_model.dart';
import 'theme_service.dart' show getStorageFile;

/// Persiste e recupera as configurações da página pública do afiliado
class AffiliatePageService {

  // Cache em memória por affiliateId
  static final Map<String, AffiliatePageModel> _cache = {};

  static Future<File> _getFile(String affiliateId) =>
      getStorageFile('achados_affiliate_${affiliateId}_page.json');

  Future<AffiliatePageModel> getPage(String affiliateId, String name) async {
    if (_cache.containsKey(affiliateId)) {
      return _cache[affiliateId]!;
    }
    try {
      final file = await _getFile(affiliateId);
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
      final file = await _getFile(model.affiliateId);
      await file.writeAsString(jsonEncode(model.toJson()));
    } catch (_) {}
  }
}
