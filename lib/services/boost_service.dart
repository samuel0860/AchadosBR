import 'package:flutter/foundation.dart';
import '../models/boost_model.dart';

/// Gerencia os impulsionamentos de produtos dos afiliados
class BoostService extends ChangeNotifier {
  static final BoostService _instance = BoostService._internal();
  factory BoostService() => _instance;
  BoostService._internal();

  final List<BoostModel> _boosts = [];

  List<BoostModel> get activeBoosts =>
      _boosts.where((b) => b.isValid).toList();

  /// Retorna true se o deal (por ID) está impulsionado
  bool isDealBoosted(String dealId) =>
      activeBoosts.any((b) => b.productId == dealId);

  /// Retorna o plano ativo para um deal
  BoostModel? boostFor(String dealId) {
    try {
      return activeBoosts.firstWhere((b) => b.productId == dealId);
    } catch (_) {
      return null;
    }
  }

  /// Simula a compra de um plano de impulsionamento
  Future<bool> purchaseBoost({
    required String productId,
    required String affiliateId,
    required BoostPlan plan,
  }) async {
    // Simula processamento de pagamento
    await Future.delayed(const Duration(milliseconds: 1500));

    // Remove boost anterior do mesmo produto (se existir)
    _boosts.removeWhere((b) => b.productId == productId);

    final now = DateTime.now();
    final boost = BoostModel(
      productId: productId,
      affiliateId: affiliateId,
      plan: plan,
      startDate: now,
      endDate: now.add(Duration(days: _daysForPlan(plan))),
      isActive: true,
    );

    _boosts.add(boost);
    notifyListeners();
    return true;
  }

  int _daysForPlan(BoostPlan plan) {
    switch (plan) {
      case BoostPlan.premium:
        return 30;
      case BoostPlan.pro:
        return 30;
      case BoostPlan.basico:
        return 7;
    }
  }

  /// Retorna IDs dos deals ordenados por prioridade de boost
  List<String> get boostedDealIds {
    final sorted = List<BoostModel>.from(activeBoosts)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return sorted.map((b) => b.productId).toList();
  }

  // Seed de demonstração (produtos já impulsionados para a demo)
  void seedDemo() {
    if (_boosts.isEmpty) {
      final now = DateTime.now();
      _boosts.addAll([
        BoostModel(
          productId: '1',
          affiliateId: 'test-afiliado-001',
          plan: BoostPlan.premium,
          startDate: now.subtract(const Duration(days: 2)),
          endDate: now.add(const Duration(days: 28)),
        ),
        BoostModel(
          productId: '3',
          affiliateId: 'test-afiliado-001',
          plan: BoostPlan.pro,
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 29)),
        ),
        BoostModel(
          productId: '5',
          affiliateId: 'test-afiliado-001',
          plan: BoostPlan.basico,
          startDate: now,
          endDate: now.add(const Duration(days: 7)),
        ),
      ]);
    }
  }
}
