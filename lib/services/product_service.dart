import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/affiliate_product.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<AffiliateProduct> _products = [];
  bool _loaded = false;

  List<AffiliateProduct> get allProducts => List.unmodifiable(_products);

  List<AffiliateProduct> getByAffiliate(String affiliateId) =>
      _products.where((p) => p.affiliateId == affiliateId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<AffiliateProduct> getActiveByAffiliate(String affiliateId) =>
      getByAffiliate(affiliateId).where((p) => p.isActive).toList();

  Future<void> init() async {
    if (_loaded) return;
    await _loadFromDisk();
    _loaded = true;
  }

  Future<AffiliateProduct> addProduct(AffiliateProduct product) async {
    _products.insert(0, product);
    await _saveToDisk();
    notifyListeners();
    return product;
  }

  Future<void> updateProduct(AffiliateProduct updated) async {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _products[idx] = updated;
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> toggleActive(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      _products[idx] = _products[idx].copyWith(isActive: !_products[idx].isActive);
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await _saveToDisk();
    notifyListeners();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<File> _getFile() async {
    final dir = Directory.systemTemp;
    return File('${dir.path}/achados_products.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      _products.clear();
      _products.addAll(
        data.map((e) => AffiliateProduct.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      await file.writeAsString(
        jsonEncode(_products.map((p) => p.toJson()).toList()),
      );
    } catch (_) {}
  }
}
